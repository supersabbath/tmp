//
//  WSResource.m
//
//  Created by Csaba Tűz on 2014.02.22..
//  Copyright (c) 2014 All rights reserved.
//

#import "BaseWebServiceResource.h"
#import "WebServiceAdapter_internal.h"

#import "WebServiceResource+CacheManager.h"

#import "RequestManager.h"

#import "Logging.h"

typedef RequestHandle *(^CacheStateReadyBlock)(CacheState state, id cachedObject, NSError * error);

@interface RequestHandle()

@property (assign, nonatomic) id owner;

@end

@implementation RequestHandle

+ (RequestHandle *)requestHandleForOperation:(RKObjectRequestOperation *)operation WithResource:(BaseWebServiceResource *)resource
{
    RequestHandle * handle = [[RequestHandle alloc] init];
    handle.resource = resource;
    handle.wsAdapter = resource.wsAdapter;
    handle.operation = operation;
    return handle;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        CFUUIDRef theUUID = CFUUIDCreate(NULL);
        CFStringRef string = CFUUIDCreateString(NULL, theUUID);
        CFRelease(theUUID);
        NSString * uuid =  (__bridge NSString *)string;
        
        self.requestId = uuid;
        
        CFRelease(string);
    }
    return self;
}

- (void)setResource:(BaseWebServiceResource *)resource
{
    _resource = resource;
    self.wsAdapter = resource.wsAdapter;
}

+ (id<NSCopying>)groupKeyForOwner:(id)owner
{
    return [owner description];
}

+ (void)cancelAllRequestsOwnedBy:(id)owner
{
    [[RequestManager instance] cancelAllRequestsInGroup:[RequestHandle groupKeyForOwner:owner]];
}

- (void)own:(id)newOwner
{
    if (self.owner)
    {
        [[RequestManager instance] removeRequest:self fromGroup:[RequestHandle groupKeyForOwner:self.owner]];
    }
    
    self.owner = newOwner;
    
    [[RequestManager instance] addRequest:self toGroup:[RequestHandle groupKeyForOwner:self.owner]];
}

@end

@interface BaseWebServiceResource()
{
    dispatch_semaphore_t cacheStateCheckSemaphore;
    
    NSInteger queuePriority;
}

@property (readwrite, weak, nonatomic) WebServiceAdapter * wsAdapter;

@property (nonatomic, strong) NSMutableDictionary *fetchQueues;

@property (retain, nonatomic) NSMutableDictionary *cacheRequestOperations;

@end

@implementation BaseWebServiceResource

- (id)initWithWSAdapter:(WebServiceAdapter *)wsAdapter {
    self = [super init];
    if (self) {
        self.wsAdapter = wsAdapter;
        
        NSInteger defaultExpirationTime = 60;
        if ([self respondsToSelector:@selector(defaultCacheExpirationTime)])
        {
            defaultExpirationTime = [(id<CachedResource>)self defaultCacheExpirationTime];
        }
        
        
        NSString *persistenceKey = [NSString stringWithFormat:@"BaseWebServiceResource_%@", NSStringFromClass([self class])];
        self.cacheProvider = [[ESCacheWebServiceCache alloc] initWithPersistenceKey:persistenceKey defaultExpirationTime:defaultExpirationTime];
        //self.cacheProvider = [[NSMutableDictionaryWebServiceCache alloc] initWithDefaultExpirationTime:defaultExpirationTime];
        
        self.fetchQueues = [NSMutableDictionary dictionary];
        
        cacheStateCheckSemaphore = dispatch_semaphore_create(1);
        
        self.cacheRequestOperations = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    self.fetchQueues = nil;
    self.wsAdapter = nil;
    self.cacheRequestOperations = nil;
}

@end

@implementation BaseWebServiceResource(CacheHandling)

/*! Returns the queue of blocks to invoke for an object with a given key.
 *  When multiple components request the same object, they'll get enqueued
 *  to be called once the state of the data is determined.
 *
 *  Until the outcome of a cache query operation is uncertain (e.g. because we're
 *  in the middle of fetching the resource), the callbacks are sitting in this queue.
 *
 *  If the parameter 'addIfNew' is true, a new queue will be created if not existing already.
 *  Otherwise nil is returned in this case.
 */
- (NSMutableArray *)queueForKey:(NSString *)key addIfNew:(BOOL)addIfNew
{
    NSMutableArray * queue = nil;
    @synchronized(self)
    {
        queue = [self.fetchQueues valueForKey:key];
    }
    if (queue == nil && addIfNew)
    {
        queue = [NSMutableArray new];
        @synchronized(self)
        {
            [self.fetchQueues setObject:queue forKey:key];
        }
    }
    return queue;
}

- (void)invokeBlockOnMainThread:(void(^)())block
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

- (void)invokeReadyBlockNowOnMainThread:(CacheStateReadyBlock)readyBlock withCachedObject:(id)cachedObject expired:(BOOL)expired error:(NSError *)error isLoading:(BOOL)loading
{
    void(^opBlock)(void) = ^{
        [self invokeReadyBlockNowOnCurrentThread:readyBlock withCachedObject:cachedObject expired:expired error:error isLoading:loading];
    };
    [self invokeBlockOnMainThread:opBlock];
}

- (id)invokeReadyBlockNowOnCurrentThread:(CacheStateReadyBlock)readyBlock withCachedObject:(id)cachedObject expired:(BOOL)expired error:(NSError *)error isLoading:(BOOL)loading
{
    DLog(@"Invoking ready block");
    CacheState state = CacheStateUnknown;
    if (expired)
    {
        state |= CacheStateExpired;
    }
    if (loading)
    {
        state |= CacheStateLoading;
    }
    if (cachedObject != nil)
    {
        state |= CacheStateAvailable;
    }
    if (error != nil)
    {
        state |= CacheStateFailed;
    }
    
    return readyBlock(state, cachedObject, error);
}

- (void)cacheStateForKey:(NSString *) key onReady:(CacheStateReadyBlock)readyBlock
{
    // If nothing to invoke in the end, we simply return.
    if (!readyBlock) return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        id cachedObject = [self.cacheProvider objectForKey:key];
        
        BOOL expired = [self.cacheProvider expirationTimeReachedForItemWithKey:key];
        DLog(@"%@", expired ? @"Expired" : @"Available in cache");
        BOOL loading = NO;
        
        {
            NSMutableArray * queue = [self queueForKey:key addIfNew:NO];
            
            if (queue)
            {
                // Someone is already waiting for the cache state to be determined.
                // That someone must have received
                [queue addObject:readyBlock];
                loading = YES;
            }
        }
        
        [self invokeReadyBlockNowOnCurrentThread:readyBlock withCachedObject:cachedObject expired:expired error:nil isLoading:loading];
    });
}

- (BOOL)startDataFetchingForKey:(NSString *)key onReady:(CacheStateReadyBlock)readyBlock
{
    BOOL shouldFetch = YES;
    {
        NSMutableArray * queue = [self queueForKey:key addIfNew:YES];
        if ([queue count] > 0)
        {
            shouldFetch = NO;
        }
        DLog(@"%@: Starting data fetching now for queue: %@", key, queue);
        [queue addObject:readyBlock];
    }
    return shouldFetch;
}

- (void)completedDataFetchingForKey:(NSString *)key request:(id)request result:(id)result error:(NSError *)error
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (result && (([result respondsToSelector:@selector(shouldCache)] && [result shouldCache])
            || ([result respondsToSelector:@selector(shouldCache:)] && [result shouldCache:request])))
        {
            if ([result respondsToSelector:@selector(cacheExpiration:)])
            {
                [self.cacheProvider setObject:result forKey:key withTimeStamp:[[NSDate date] timeIntervalSince1970] withExpirationInterval:[result cacheExpiration:request]];
            }
            else if ([result respondsToSelector:@selector(cacheExpiration)])
            {
                [self.cacheProvider setObject:result forKey:key withTimeStamp:[[NSDate date] timeIntervalSince1970] withExpirationInterval:[result cacheExpiration]];
            }
            else
            {
                [self.cacheProvider setObject:result forKey:key withTimeStamp:[[NSDate date] timeIntervalSince1970]];
            }
        }
        NSArray *blocksToCall;
        //dispatch_semaphore_wait(cacheStateCheckSemaphore, DISPATCH_TIME_FOREVER);
        {
            NSMutableArray * queue = [self queueForKey:key addIfNew:NO];
            
            if (queue)
            {
                blocksToCall = queue;
            }
            @synchronized(self)
            {
                [self.fetchQueues removeObjectForKey:key];
            }
        }
        //dispatch_semaphore_signal(cacheStateCheckSemaphore);
        
        id cachedObject = result;
        BOOL expired = NO;
        if (([result respondsToSelector:@selector(shouldCache)] && [result shouldCache]) || ([result respondsToSelector:@selector(shouldCache:)] &&[result shouldCache:request]))
        {
            cachedObject = [self.cacheProvider objectForKey:key];
        
            expired = [self.cacheProvider expirationTimeReachedForItemWithKey:key];
            DLog(@"%@", expired ? @"Expired" : @"Available in cache");
        }
        
        @synchronized(self.cacheRequestOperations)
        {
            [self.cacheRequestOperations removeObjectForKey:key];
        }
        
        for (CacheStateReadyBlock block in blocksToCall)
        {
            [self invokeReadyBlockNowOnCurrentThread:block withCachedObject:cachedObject expired:expired error:error isLoading:NO];
        }
    });
}

@end

@implementation BaseWebServiceResource(ObjectLoading)

/*! Creates a reusable block, which will get called all the time the cache state of an object changes.
 *  Possible outcomes:
 *
 *  1. The object was not available, but fetching it failed the last time we tried.
 *  In this case the sequence is abandoned, and the failure block is called for the request.
 *§
 *  2. The object is available in the cache, but it was expired.
 *
 *  In this case we call the success block with the old data, but we also go to the backend
 *  for an update.
 *
 *  3. The object is available in the cache, and it's not expired.
 *  
 *  In this case we invoke the success block, and return.
 * 
 *  4. The object is not available in the cache, and no one is currently fetching it.
 *  
 *  In this case we initiate a call to the backend ourselves.
 *
 *  5. The object is not available in the cache, but someone else is already fetching it.
 *
 *  In this case we stand back doing nothing, and wait until we get invoked again when loading finished.
 */
- (CacheStateReadyBlock)readyBlockForResponseClass:(Class)clazz
                                           request:(BaseWebServiceModel *)request
                                       pathPattern:(NSString *)pathPattern
                                        parameters:(NSDictionary *)parameters
                                           keyPath:(NSString *)keyPath
                                       forCacheKey:(NSString *)cacheKey
                                         onSuccess:(void(^)(id))success
                                         onFailure:(FailureBlock)failure
                                     requestHandle:(RequestHandle *)handle
{
    NSAssert(cacheKey != nil, @"Error: 'cacheKey' cannot be nil at this point.");
    
    __block __weak CacheStateReadyBlock weak_readyBlock;
    CacheStateReadyBlock readyBlock;
    weak_readyBlock = readyBlock = ^RequestHandle* (CacheState state, id cachedObject, NSError *error) {
        if (state & CacheStateFailed)
        {
            // If Failed, we invoke failure block.
            DLog(@"%@: Last fetch operation failed, so we invoke failure.", cacheKey);
            if (failure)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(error);
                });
            }
            @synchronized(self.cacheRequestOperations)
            {
                [self.cacheRequestOperations removeObjectForKey:cacheKey];
            }
        }
        else
        {
            // If not failed, we investigate cache state further.
            if (state & CacheStateExpired || !(state & CacheStateAvailable))
            {
                // But of it's not available, or expired, we try to fetch it.
                if (state & CacheStateLoading)
                {
                    DLog(@"%@: Someone is already loading, we will be invoked again. Doing nothing else now.", cacheKey);
                    @synchronized(self.cacheRequestOperations)
                    {
                        RequestHandle * request = [self.cacheRequestOperations valueForKey:cacheKey];
                        for (NSString * key in self.cacheRequestOperations)
                        {
                            RequestHandle * req = [self.cacheRequestOperations objectForKey:key];
                            if (req == request)
                            {
                                [req.operation setQueuePriority:NSOperationQueuePriorityVeryHigh];
                            }
                            else
                            {
                                [req.operation setQueuePriority:NSOperationQueuePriorityNormal];
                            }
                        }
                        
                    }
                }
                else
                {
                    DLog(@"%@: Not available in cache, and not fetchin yet. Initiate fetching.", cacheKey);
                    if ([self startDataFetchingForKey:cacheKey onReady:weak_readyBlock])
                    {
                        [self internalGETObjectResponseClass:clazz request:request forPathPattern:pathPattern parameters:parameters keyPath:keyPath respDescriptors:nil onSuccess:^(id result) {
                            [self completedDataFetchingForKey:cacheKey request:request result:result error:nil];
                        } onFailure:^(NSError *error) {
                            [self completedDataFetchingForKey:cacheKey request:request result:nil error:error];
                        } requestHandle:handle];
                        @synchronized(self.cacheRequestOperations)
                        {
                            [self.cacheRequestOperations setObject:handle forKey:cacheKey];
                            for (NSString * key in self.cacheRequestOperations)
                            {
                                RequestHandle * req = [self.cacheRequestOperations objectForKey:key];
                                if (req == handle)
                                {
                                    [req.operation setQueuePriority:NSOperationQueuePriorityVeryHigh];
                                }
                                else
                                {
                                    [req.operation setQueuePriority:NSOperationQueuePriorityNormal];
                                }
                            }
                        }
                    }
                }
            }
            else if (state & CacheStateAvailable)
            {
                if (state & CacheStateAvailable)
                {
                    // If data is available in the cache, call success block anyway.
                    DLog(@"%@: Available in cache, calling success block just in case.", cacheKey);
                    if (success)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            success(cachedObject);
                        });
                    }
                }
            }
        }
        return nil;
    };
    return readyBlock;
}

- (RequestHandle *)GETObjectResponseClass:(Class)clazz request:(BaseWebServiceModel *)model forPathPattern:(NSString *)pathPattern parameters:(NSDictionary *)parameters keyPath:(NSString *)keyPath respDescriptors:(NSArray *)responseDescriptors onSuccess:(void(^)(id result))success onFailure:(FailureBlock)failureBlock
{

    RequestHandle *handle = [self obtainRequestHandle];
    
    BOOL shouldTryCache = self.cacheProvider != nil && [clazz conformsToProtocol:@protocol(CacheableModel)];
    
    if (shouldTryCache)
    {
        DLog(@"Object is cacheable");
        NSString *itemId = [clazz uniqueId:model];
        NSString *cacheKey = nil;
        if (itemId != nil)
        {
            // In case this object is cacheable, and a unique ID is assigned to it, we dispatch a task of checking availability on object cache.
            cacheKey = [self cacheKeyForClass:clazz itemIdentifier:itemId];
        }
        if (itemId == nil || cacheKey == nil)
        {
            DLog(@"Warning! Cacheable model has no unique ID, cannot use cache");
            [self internalGETObjectResponseClass:clazz request:model forPathPattern:pathPattern parameters:parameters keyPath:keyPath respDescriptors:responseDescriptors onSuccess:success onFailure:failureBlock requestHandle:handle];
        }
        else
        {
            CacheStateReadyBlock readyBlock = [self readyBlockForResponseClass:clazz request:model pathPattern:pathPattern parameters:parameters keyPath:keyPath forCacheKey:cacheKey onSuccess:success onFailure:failureBlock requestHandle:handle];
            
            [self cacheStateForKey:cacheKey onReady:readyBlock];
        }
    }
    else
    {
        [self internalGETObjectResponseClass:clazz request:model forPathPattern:pathPattern parameters:parameters keyPath:keyPath respDescriptors:responseDescriptors onSuccess:success onFailure:failureBlock requestHandle:handle];
    }
    return handle;
}

- (void)handleCookies:(RKObjectRequestOperation *)operation
{
    NSHTTPURLResponse *response = operation.HTTPRequestOperation.response;
    NSArray * cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:response.allHeaderFields forURL:response.URL];
    for (NSHTTPCookie *cookie in cookies)
    {
        [self.wsAdapter addCookie:cookie previousOwner:nil];
    }
}

- (void)requestWithMethod:(RKRequestMethod)method responseClass:(Class)clazz body:(id)payload forPathPattern:(NSString *)pathPattern parameters:(NSDictionary *)parameters keyPath:(NSString *)keyPath respDescriptors:(NSArray *)respDescriptors onSuccess:(void(^)(id result))success onFailure:(FailureBlock)failureBlock requestHandle:(RequestHandle *)handle
{
    if (payload != nil && ![payload isKindOfClass:[BaseWebServiceModel class]])
    {
        NSAssert(0, @"Payload has to be BaseWebServiceModel");
    }
    if (![clazz isSubclassOfClass:[BaseWebServiceModel class]])
    {
        NSAssert(0, @"Response class has to be BaseWebServiceModel");
    }

    NSDictionary *interpolatedParameters = nil;
    
    NSString * path = pathPattern;
    if (payload != nil)
    {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:pathPattern];
        path = [pathMatcher pathFromObject:payload addingEscapes:YES interpolatedParameters:&interpolatedParameters];
    }
    
    NSString * absolutePath = path;
    
    if (![path hasPrefix:@"http://"] && ![path hasPrefix:@"https://"])
    {
        absolutePath = [[self.wsAdapter.baseURL absoluteString] stringByAppendingString:path == nil ? @"" : path];
    }
    
    NSMutableURLRequest *request = nil;
    RKRequestDescriptor * requestDescriptor = nil;
    @synchronized(self.wsAdapter.objectManager)
    {
        if (payload && [[payload class] inverseMapping] != nil)
        {
            requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[[payload class] inverseMapping] objectClass:[payload class] rootKeyPath:nil method:method];
            [self.wsAdapter.objectManager addRequestDescriptor:requestDescriptor];
        }
        request = [self.wsAdapter.objectManager requestWithObject:payload method:method path:absolutePath parameters:parameters];
        if (payload && [[payload class] inverseMapping] != nil)
        {
            [self.wsAdapter.objectManager removeRequestDescriptor:requestDescriptor];
            requestDescriptor = nil;
        }
    }
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [request setTimeoutInterval:self.wsAdapter.defaultRequestTimeout];
    
    if (payload && [payload conformsToProtocol:@protocol(PayloadConfigurer)])
    {
        [payload configurePayloadForRequest:request params:parameters];
    }
    

     DLog(@"%@", request.URL.absoluteString);
    if (respDescriptors == nil)
    {
        RKResponseDescriptor *descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[clazz mapping] method:method pathPattern:nil keyPath:keyPath statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        respDescriptors = @[descriptor];
    }
    
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:respDescriptors ];
    
   
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        TLog(@"%@", [operation.HTTPRequestOperation responseString]);
        [self handleCookies:operation];
        if (success)
        {
            BaseWebServiceModel * result = [clazz finalMappingResult:mappingResult];
            result.responseHeaders = [operation.HTTPRequestOperation.response allHeaderFields];
            success(result);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DLog(@"%@", [operation.HTTPRequestOperation responseString]);
        if (failureBlock)
            failureBlock(error);
    }];
    
    [operation.HTTPRequestOperation setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse) {
        if(redirectResponse){
            NSMutableURLRequest *r = [connection.originalRequest mutableCopy]; // original request
            [r setURL: [request URL]];
            return r;
        }
        else {
            return request;
        }
    }];
    
    operation.HTTPRequestOperation.credential = self.wsAdapter.defaultCredential;
    
    handle.operation = operation;
    
    [self.wsAdapter enqueueOperation:operation];
}

- (RequestHandle *)obtainRequestHandle
{
    
    RequestHandle * handle = [[RequestHandle alloc] init];
    handle.resource = self;
    
    return handle;
}

- (void)internalGETObjectResponseClass:(Class)clazz request:(BaseWebServiceModel *)request forPathPattern:(NSString *)pathPattern parameters:(NSDictionary *)parameters keyPath:(NSString *)keyPath respDescriptors:(NSArray *)responseDescriptors onSuccess:(void(^)(id result))success onFailure:(FailureBlock)failureBlock requestHandle:(RequestHandle *)handle
{
    [self requestWithMethod:RKRequestMethodGET responseClass:clazz body:request forPathPattern:pathPattern parameters:parameters keyPath:keyPath respDescriptors:responseDescriptors onSuccess:success onFailure:failureBlock requestHandle:handle];
}

- (RequestHandle *)POSTObjectResponseClass:(Class)clazz request:(BaseWebServiceModel *)model forPathPattern:(NSString *)pathPattern parameters:(NSDictionary *)parameters keyPath:(NSString *)keyPath respDescriptors:(NSArray *)responseDescriptors onSuccess:(void(^)(id result))success onFailure:(FailureBlock)failureBlock
{
    RequestHandle *handle = [self obtainRequestHandle];
    [self requestWithMethod:RKRequestMethodPOST responseClass:clazz body:model forPathPattern:pathPattern parameters:parameters keyPath:keyPath respDescriptors:responseDescriptors onSuccess:success onFailure:failureBlock requestHandle:handle];
    return handle;
}

- (RequestHandle *)DELETEObjectResponseClass:(Class)clazz request:(BaseWebServiceModel *)model forPathPattern:(NSString *)pathPattern parameters:(NSDictionary *)parameters keyPath:(NSString *)keyPath respDescriptors:(NSArray *)responseDescriptors onSuccess:(void(^)(id result))success onFailure:(FailureBlock)failureBlock
{
    RequestHandle *handle = [self obtainRequestHandle];
    [self requestWithMethod:RKRequestMethodDELETE responseClass:clazz body:model forPathPattern:pathPattern parameters:parameters keyPath:keyPath respDescriptors:responseDescriptors onSuccess:success onFailure:failureBlock requestHandle:handle];
    return handle;
}

- (RequestHandle *)PUTObjectResponseClass:(Class)clazz request:(NSObject<RequestMappable> *)model forPathPattern:(NSString *)pathPattern parameters:(NSDictionary *)parameters keyPath:(NSString *)keyPath respDescriptors:(NSArray *)responseDescriptors onSuccess:(void(^)(id result))success onFailure:(FailureBlock)failureBlock
{
    RequestHandle *handle = [self obtainRequestHandle];
    [self requestWithMethod:RKRequestMethodPUT responseClass:clazz body:model forPathPattern:pathPattern parameters:parameters keyPath:keyPath respDescriptors:responseDescriptors onSuccess:success onFailure:failureBlock requestHandle:handle];
    return handle;
}

@end

@implementation BaseWebServiceResource(RouteEditor)

- (void)setResponseDescriptorForClass:(Class)clazz pathPattern:(NSString *)pathPattern method:(RKRequestMethod)method keyPath:(NSString *)keyPath
{
    NSAssert([clazz isSubclassOfClass:[BaseWebServiceModel class]], @"Class %@ is not a valid BaseWebServiceModel", clazz);
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[clazz mapping]
                                                                                            method:method
                                                                                       pathPattern:pathPattern
                                                                                           keyPath:keyPath
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [self.wsAdapter.objectManager addResponseDescriptor:responseDescriptor];
}

- (void)setGETMapping:(Class)clazz forPathPattern:(NSString *)pathPattern keyPath:(NSString *)keyPath
{
    [self setResponseDescriptorForClass:clazz pathPattern:pathPattern method:RKRequestMethodGET keyPath:keyPath];
}

- (void)setPOSTMapping:(Class)clazz forPathPattern:(NSString *)pathPattern keyPath:(NSString *)keyPath
{
    [self setResponseDescriptorForClass:clazz pathPattern:pathPattern method:RKRequestMethodPOST keyPath:keyPath];
}

- (void)setGETMapping:(Class)clazz forPathPattern:(NSString *)pathPattern
{
    [self setGETMapping:clazz forPathPattern:pathPattern keyPath:nil];
}

- (void)setPOSTMapping:(Class)clazz forPathPattern:(NSString *)pathPattern
{
    [self setPOSTMapping:clazz forPathPattern:pathPattern keyPath:nil];
}

@end

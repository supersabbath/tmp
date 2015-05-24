//
//  WSResource.h
//
//  Created by Csaba Tűz on 2014.02.22..
//  Copyright (c) 2014 All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebServiceAdapter.h"
#import "BaseWebServiceModel.h"
#import "WebServiceComponent.h"

#define pageLimit 10

#pragma mark - Block helpers

/**
 Helper macro, which allows `BaseWebServiceResource` subclasses
 to define Success blocks for the type of objects they work with.
 
 Recommended placement: In the headers of `BaseWebServiceResource` subclasses
 
 OR
 
 In case of widely used response types (which should be uncommon) can be placed
 in the header of `WebServiceAdapter` subclass.
 */
#define SUCCESS_BLOCK(type) \
typedef void(^type ## SuccessBlock)(type * result)

/**
 General failure block of requests. The `userInfo` property contains the 
 possible `RKMappingResult` in case of when the error response is also a domain object.
 */
typedef void(^FailureBlock)(NSError *error);

/**
 `BaseWebServiceResource` subclasses should implement this protocol, if they
 work with cacheable data.
 
 Each `BaseWebServiceResource` has a separate cache, which can be configured
 independently of each other.
 
 ## Notes
 
 On one hand, implementing this protocol should be responsible for enabling
 caching on the given resource.
 
 On the other hand, the protocol methods will allow to specify fallbacks
 for cases, when caching settings are not determined by the models in question.
 */
@protocol CachedResource

/**
 In case of a common default expiration time for all the requests in the `BaseWebServiceResource`.
 */
- (NSInteger)defaultCacheExpirationTime;

/**
 In case of a global caching logic for all the requests in the `BaseWebServiceResource`.
 */
@optional
- (BOOL)shouldCacheEntity:(id)entity;

@end

/**
 When a query is made to the cache, the result will be one of the states in the
 `CacheState` enum. Appropriate action is taken depending on the current state.
 */
typedef NS_ENUM(NSUInteger, CacheState) {
    /**
     Neutral flag, if this is the value, we can say nothing.
     This value indicates weirdness.
     */
    CacheStateUnknown   = 0,
    /**
     The requested key is found in the cache and non-expired.
     */
    CacheStateAvailable = 1,
    /**
     The request key is found in the cache, but is expired. A refetching
     will be initiated.
     
     @warning In this case, the success blocks are called twice. First with the expired model (on a better than nothing basis).
     */
    CacheStateExpired   = 1<<1,
    /**
     The requested key is not available in the cache, and is loading.
     
     The request is put on hold, until response arrives, or ongoing
     request fails. Appropriate blocks are called when we're done loading.
     */
    CacheStateLoading  = 1<<2,
    /**
     The requested key is not available in the cache, and last fetch attempt
     failed.
     
     The retry responsibility is passed to the user of the `BaseWebServiceResource`.
     */
    CacheStateFailed   = 1<<3,
    /**
     The corresponding operation was cancelled. We need to fail.
     */
    CacheStateCancelled = 1<<4
};

/**
 `RequestHandle` is encapsulating various info about a given (possibly long) request
 to a backend.
 
 By using `RequestManager`, these requests can be grouped, or cancelled.
 */
@interface RequestHandle : NSObject

/**
 An arbitrary object which owns this request. 
 
 Usually a `UIViewController`, or possibly a `UIView` is a nice choice.
 */
@property (assign, nonatomic, readonly) id owner;

/**
 A uniform unique identifier of this request. Useful for loging and backtracking.
 */
@property (retain, nonatomic) NSString * requestId;
/**
 The `BaseWebServiceResource` instance which started this requests.
 */
@property (weak, nonatomic) BaseWebServiceResource * resource;
/**
 The `WebServiceAdapter` which is the root node of the `WebServiceComponent` tree of `resource`.
 */
@property (weak, nonatomic) WebServiceAdapter * wsAdapter;

/**
 The `RKObjectRequestOperation` which encapsulates the HTTP request and object mapping.
 */
@property (retain, nonatomic) NSOperation * operation;

/**
 Returns a new `RequestHandle` instance for a given `AFHTTPRequestOperation` and
 `BaseWebServiceResource`.
 */
+ (RequestHandle *)requestHandleForOperation:(AFHTTPRequestOperation *)operation WithResource:(BaseWebServiceResource *)resource;

/**
 Syntax helper to cancel all requests owned by `owner`. 
 
 @param owner The object which owns requests to be cancelled.
 */
+ (void)cancelAllRequestsOwnedBy:(id)owner;

/**
 Syntax helper to take ownership of this `RequestHandle`, and with it the request operation.
 
 If an old owner was present, the request is first deowned, then it is assigned to the new owner.
 If the new owner is `nil`, the request will be unowned without warning or error.
 */
- (void)own:(id)newOwner;

@end

/*!
 *  Organizing class to represent a certain portion of the functionality of an
 *  BaseWebServiceAdapter instance.
 *
 *  A Resource should represent a logical unit. Note the mac
 */
@interface BaseWebServiceResource : WebServiceComponent

@property (readonly, weak, nonatomic) WebServiceAdapter * wsAdapter;

- (id)initWithWSAdapter:(WebServiceAdapter *)wsAdapter;

@end

/*!
 *  Organizing category to define methods for invoking the Web Service
 *  endpoints using the supported HTTP methods.
 *  These methods are wrappers around standard RestKit workflow, in order
 *  to remove most of the boilerplate code corresponding to these calls,
 *  while also killing redundancy.
 */
@interface BaseWebServiceResource(ObjectLoading)

- (RequestHandle *)GETObjectResponseClass:(Class)clazz request:(BaseWebServiceModel *)model forPathPattern:(NSString *)pathPattern parameters:(NSDictionary *)parameters keyPath:(NSString *)keyPath respDescriptors:(NSArray *)responseDescriptors onSuccess:(void(^)(id result))success onFailure:(FailureBlock)failureBlock;

- (RequestHandle *)POSTObjectResponseClass:(Class)clazz request:(BaseWebServiceModel *)model forPathPattern:(NSString *)pathPattern parameters:(NSDictionary *)parameters keyPath:(NSString *)keyPath respDescriptors:(NSArray *)responseDescriptors onSuccess:(void(^)(id result))success onFailure:(FailureBlock)failureBlock;

- (RequestHandle *)PUTObjectResponseClass:(Class)clazz request:(BaseWebServiceModel *)model forPathPattern:(NSString *)pathPattern parameters:(NSDictionary *)parameters keyPath:(NSString *)keyPath respDescriptors:(NSArray *)responseDescriptors onSuccess:(void(^)(id result))success onFailure:(FailureBlock)failureBlock;

- (RequestHandle *)DELETEObjectResponseClass:(Class)clazz request:(BaseWebServiceModel *)model forPathPattern:(NSString *)pathPattern parameters:(NSDictionary *)parameters keyPath:(NSString *)keyPath respDescriptors:(NSArray *)responseDescriptors onSuccess:(void(^)(id result))success onFailure:(FailureBlock)failureBlock;

@end

/*!
 *  For very well defined RESTful web services, the default Router functionality
 *  of RestKit might be invoked.
 *  Unfortunately many Web Services do not conform to these rules, and thus the
 *  RestKit router is not able to map the resource paths correctly.
 *  Using the Router is a secondary feature of BaseWebServiceResource.
 *
 *  For now stick to explicit object mapping descriptors per request, for which the
 *  category 'ObjectMapping' provides the necessary convenience methods.
 */
@interface BaseWebServiceResource(RouteEditor)

- (void)setGETMapping:(Class)clazz forPathPattern:(NSString *)pathPattern keyPath:(NSString *)keyPath;
- (void)setGETMapping:(Class)clazz forPathPattern:(NSString *)pathPattern;

- (void)setPOSTMapping:(Class)clazz forPathPattern:(NSString *)pathPattern keyPath:(NSString *)keyPath;
- (void)setPOSTMapping:(Class)clazz forPathPattern:(NSString *)pathPattern;

@end

#import "RequestManager.h"

#import "Logging.h"

#import "BaseWebServiceResource.h"

#import "SynthesizeSingleton.h"

@interface RequestManager()

@property (retain, nonatomic) NSMutableDictionary * requestGroups;

@end


@implementation RequestManager

SYNTHESIZE_SINGLETON_FOR_CLASS(RequestManager);

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.requestGroups = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSMutableArray *)requestGroup:(id<NSCopying>)groupKey
{
    NSMutableArray * requests;
    @synchronized(self)
    {
        requests = [self.requestGroups objectForKey:groupKey];
        if (requests == nil)
        {
            requests = [NSMutableArray array];
        }
        [self.requestGroups setObject:requests forKey:groupKey];
    }
    return requests;
}

- (void)removeGroup:(id<NSCopying>)groupKey
{
    @synchronized(self)
    {
        [self.requestGroups removeObjectForKey:groupKey];
    }
}

- (void)cleanUpGroup:(id<NSCopying>)groupKey
{
    NSMutableArray * requests = [self requestGroup:groupKey];
    @synchronized(requests)
    {
        int i = 0;
        for (RequestHandle *r in [requests copy])
        {
            if (r.operation.isCancelled || r.operation.isFinished)
            {
                [requests removeObject:r];
                ++i;
            }
        }
        if (i > 0)
        {
            TLog(@"Evicted %d cancelled requests", i);
        }
        
        if ([requests count] == 0)
        {
            [self removeGroup:groupKey];
            TLog(@"Group '%@' is empty, evicting group.", groupKey);
        }
    }
}

- (void)removeRequest:(RequestHandle *)request fromGroup:(id<NSCopying>)groupKey
{
    NSMutableArray * requests = [self requestGroup:groupKey];
    @synchronized(requests)
    {
        [requests removeObject:request];
    }
}

- (void)addRequest:(RequestHandle *)request toGroup:(id<NSCopying>)groupKey
{
    NSMutableArray * requests = [self requestGroup:groupKey];
    @synchronized(requests)
    {
        [requests addObject:request];
    }
}

- (void)cancelAllRequestsInGroup:(id<NSCopying>)groupKey
{
    [self cleanUpGroup:groupKey];
    
    NSMutableArray * requests = [self requestGroup:groupKey];
    @synchronized(requests)
    {
        TLog(@"Cancelling %lu requests in group %@:", (unsigned long)[requests count], groupKey);
        for (RequestHandle *r in requests)
        {
            [r.operation cancel];
        }
        
        [self cleanUpGroup:groupKey];
    }
}

@end

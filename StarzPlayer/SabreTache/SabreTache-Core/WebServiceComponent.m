//
//  BaseWebServiceComponent.m
//
//  Created by Csaba Tűz on 2014.03.05..
//  Copyright (c) 2014 All rights reserved.
//

#import "WebServiceComponent.h"
#import "BaseWebServiceResource.h"

@interface WebServiceComponent()

@property (retain, nonatomic) NSMutableDictionary *resources;

@end

@implementation WebServiceComponent

- (id)init
{
    self = [super init];
    if (self)
    {
        self.resources = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerResource:(Class)clazz {
    NSAssert([clazz isSubclassOfClass:[BaseWebServiceResource class]], @"Class %@ is not a valid BaseWebServiceResource", clazz);
    @synchronized(clazz) {
        if ([self.resources objectForKey:(id<NSCopying>)clazz] != nil) return;
        
        BaseWebServiceResource *resource;
        WebServiceAdapter *wsAdapter = nil;
        if ([self respondsToSelector:@selector(wsAdapter)])
        {
            wsAdapter = [self performSelector:@selector(wsAdapter)];
        } else if ([self isKindOfClass:[WebServiceAdapter class]])
        {
            wsAdapter = (WebServiceAdapter *)self;
        }
        resource = [(BaseWebServiceResource *)[clazz alloc] initWithWSAdapter:wsAdapter];
        
        [self.resources setObject:resource forKey:(id<NSCopying>)clazz];
    }
}

- (BaseWebServiceResource *)resource:(Class)clazz {
    @synchronized(clazz) {
        BaseWebServiceResource *res = [self.resources objectForKey:(id<NSCopying>)clazz];
        if (res == nil) {
            [self registerResource:clazz];
        }
        return [self.resources objectForKey:(id<NSCopying>)clazz];
    }
}

@end

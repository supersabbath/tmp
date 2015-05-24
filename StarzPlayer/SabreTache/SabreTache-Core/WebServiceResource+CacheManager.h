//
//  WebServiceResource+CacheManager.h
//
//  Created by Csaba Tűz on 2014.03.02..
//  Copyright (c) 2014 All rights reserved.
//

#import "BaseWebServiceResource.h"
#import "ProtocolProperties.h"
#import "GeneralCache.h"

@interface ESCacheWebServiceCache : NSObject<GeneralCache>

- (id)initWithPersistenceKey:(NSString *)persistenceKey defaultExpirationTime:(NSTimeInterval)defaultExpirationTime;

@end

@interface NSMutableDictionaryWebServiceCache : NSObject<GeneralCache>

- (id)initWithDefaultExpirationTime:(NSTimeInterval)defaultExpirationTime;

@end

@interface NSCacheWebServiceCache : NSObject<GeneralCache>

- (id)initWithDefaultExpirationTime:(NSTimeInterval)defaultExpirationTime;

@end

@interface BaseWebServiceResource (CacheManager)

CATEGORY_PROPERTY(id<GeneralCache>, cacheProvider);

- (NSString*) cacheKeyForClass:(Class) class itemIdentifier:(NSString *)itemIdentifier;

- (void)invalidateCacheForClass:(Class)class itemIdentifier:(NSString *)itemIdentifier;

- (void)invalidateAllCache;

@end

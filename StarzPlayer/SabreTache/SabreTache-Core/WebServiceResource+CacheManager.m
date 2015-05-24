//
//  BaseWebServiceResource+CacheManager.m
//
//  Created by Csaba Tűz on 2014.03.02..
//  Copyright (c) 2014 All rights reserved.
//

#import "WebServiceResource+CacheManager.h"
#import "ESCache.h"
#import "Logging.h"
#import "Macros.h"

static NSString *const kDash                        = @"-";
static NSString *const kCacheKeysPredicateFormat    = @"SELF contains[cd] %@";

@interface CacheAtom : NSObject<NSCoding>

@property (strong, nonatomic) id<NSCoding> payload;

@property (assign, nonatomic) NSTimeInterval created;

@property (assign, nonatomic) NSTimeInterval expires;

- (instancetype)initWithPayload:(id<NSCoding>)payload
     withCreationTime:(NSTimeInterval)created
            expiresIn:(NSTimeInterval)timeToLive;

@end

@implementation CacheAtom

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.payload = [aDecoder decodeObjectForKey:@"payload"];
        self.created = [[aDecoder decodeObjectForKey:@"created"] doubleValue];
        self.expires = [[aDecoder decodeObjectForKey:@"expires"] doubleValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.payload forKey:@"payload"];
    [aCoder encodeObject:@(self.created) forKey:@"created"];
    [aCoder encodeObject:@(self.expires) forKey:@"expires"];
}

- (instancetype)initWithPayload:(id)payload withCreationTime:(NSTimeInterval)created expiresIn:(NSTimeInterval)timeToLive
{
    self = [super init];
    if (self)
    {
        _payload = payload;
        _created = created;
        _expires = created + timeToLive;
    }
    return self;
}

- (BOOL)hasExpired
{
    NSDate *now = [NSDate date];
    return [now compare:[NSDate dateWithTimeIntervalSince1970:self.expires]] == NSOrderedDescending;
}

- (void)resurrect
{
     NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    self.expires -= self.created; self.expires += now;
    self.created = now;
}

- (NSString *) description
{
    return [ NSString stringWithFormat: @"Value: %@, timeStamp: %f, expirtationTime: %f", _payload, _created, _expires ];
}

@end

@interface ESCacheWebServiceCache()

@property (assign, nonatomic) NSTimeInterval defaultExpirationTime;

@property (retain, nonatomic) ESCache *internalCache;

@end

@implementation ESCacheWebServiceCache

- (id)initWithPersistenceKey:(NSString *)persistenceKey defaultExpirationTime:(NSTimeInterval)defaultExpirationTime
{
    self = [super init];
    if (self)
    {
        NSError *error;
        self.internalCache = [[ESCache alloc] initWithName:persistenceKey error:&error];
        self.defaultExpirationTime = defaultExpirationTime;
    }
    return self;
}

- (void)setObject:(id<NSCoding>)anObject forKey:(NSString *)key
{
    [self setObject:anObject forKey:key
      withTimeStamp:[[NSDate date] timeIntervalSince1970] withExpirationInterval:self.defaultExpirationTime];
}

- (void)setObject:(id<NSCoding>)anObject forKey:(NSString *)key withTimeStamp:(NSTimeInterval)timeStamp
{
    [self setObject:anObject forKey:key withTimeStamp:timeStamp withExpirationInterval:self.defaultExpirationTime];
}

- (void)setObject:(id<NSCoding>)anObject forKey:(NSString *)key withTimeStamp:(NSTimeInterval)timeStamp withExpirationInterval:(NSTimeInterval)specificExpirationInterval
{
    if (anObject != nil && key != nil)
    {
        CacheAtom * current;
        current = [self.internalCache objectForKey:key];
        
        if ((current) && [(id)current.payload isEqual:anObject])
        {
            current.created = timeStamp;
            current.expires = timeStamp + specificExpirationInterval;
            current.payload = anObject;
        }
        else
        {
            current = [[CacheAtom alloc] initWithPayload:anObject
                                        withCreationTime:timeStamp
                                               expiresIn:specificExpirationInterval];
        }
        [self.internalCache setObject:current forKey:key];
    }
}

- (id<NSCoding>)objectForKey:(NSString *)key
{
    CacheAtom * a;
    a = [self.internalCache objectForKey:key];
    if (a.payload == nil)
    {
        WLog(@"Cached object with empty payload in Cache!!!!");
        [self clearObjectForKey:key];
    }
    return a.payload;
}

- (void)clearObjectForKey:(NSString *)key
{
    [self.internalCache removeObjectForKey:key];
}

- (void)clearAllObjects
{
    [self.internalCache removeAllObjects];
}

- (BOOL)expirationTimeReachedForItemWithKey:(NSString *)key
{
    CacheAtom * a = [self.internalCache objectForKey:key];
    if (a == nil || a.payload == nil)
    {
        [self clearObjectForKey:key];
        return NO;
    }
    DLog(@"%d", [a hasExpired]);
    return [a hasExpired];
}

- (void)reactivateCacheForKey:(NSString *)key
{
    CacheAtom * a = [self.internalCache objectForKey:key];
    [a resurrect];
    [self.internalCache setObject:a forKey:key];
}

- (NSTimeInterval)timeStampForCachedItemWithKey:(NSString *)key
{
    CacheAtom * a = [self.internalCache objectForKey:key];
    return a.created;
}

@end


@interface NSMutableDictionaryWebServiceCache()

@property (assign, nonatomic) NSTimeInterval defaultExpirationTime;

@property (retain, nonatomic) NSMutableDictionary *internalCache;

@end

@implementation NSMutableDictionaryWebServiceCache

- (id)initWithDefaultExpirationTime:(NSTimeInterval)defaultExpirationTime
{
    self = [super init];
    if (self)
    {
        self.internalCache = [NSMutableDictionary dictionary];
        self.defaultExpirationTime = defaultExpirationTime;
    }
    return self;
}

- (void)setObject:(id<NSCoding>)anObject forKey:(NSString *)key
{
    [self setObject:anObject forKey:key
          withTimeStamp:[[NSDate date] timeIntervalSince1970] withExpirationInterval:self.defaultExpirationTime];
}

- (void)setObject:(id<NSCoding>)anObject forKey:(NSString *)key withTimeStamp:(NSTimeInterval)timeStamp
{
    [self setObject:anObject forKey:key withTimeStamp:timeStamp withExpirationInterval:self.defaultExpirationTime];
}

- (void)setObject:(id<NSCoding>)anObject forKey:(NSString *)key withTimeStamp:(NSTimeInterval)timeStamp withExpirationInterval:(NSTimeInterval)specificExpirationInterval
{
    if (anObject != nil && key != nil)
    {
        CacheAtom * current;
        current = [self.internalCache objectForKey:key];
        
        if ((current) && [(id)current.payload isEqual:anObject])
        {
            current.created = timeStamp;
            current.expires = timeStamp + specificExpirationInterval;
            current.payload = anObject;
        }
        else
        {
            current = [[CacheAtom alloc] initWithPayload:anObject
                                        withCreationTime:timeStamp
                                               expiresIn:specificExpirationInterval];
        }
        [self.internalCache setObject:current forKey:key];
    }
}

- (id<NSCoding>)objectForKey:(NSString *)key
{
    CacheAtom * a;
    a = [self.internalCache objectForKey:key];
    if (a.payload == nil)
    {
       WLog(@"Cached object with empty payload in Cache!!!!");
        [self clearObjectForKey:key];
    }
    return a.payload;
}

- (void)clearObjectForKey:(NSString *)key
{
    [self.internalCache removeObjectForKey:key];
}

- (void)clearAllObjects
{
    [self.internalCache removeAllObjects];
}

- (BOOL)expirationTimeReachedForItemWithKey:(NSString *)key
{
    CacheAtom * a = [self.internalCache objectForKey:key];
    if (a == nil || a.payload == nil)
    {
        [self clearObjectForKey:key];
        return NO;
    }
    DLog(@"%d", [a hasExpired]);
    return [a hasExpired];
}

- (void)reactivateCacheForKey:(NSString *)key
{
    CacheAtom * a = [self.internalCache objectForKey:key];
    [a resurrect];
    [self.internalCache setObject:a forKey:key];
}

- (NSTimeInterval)timeStampForCachedItemWithKey:(NSString *)key
{
    CacheAtom * a = [self.internalCache objectForKey:key];
    return a.created;
}

@end

@interface NSCacheWebServiceCache()

@property (assign, nonatomic) NSTimeInterval defaultExpirationTime;

@property (retain, nonatomic) NSCache *internalCache;

@end

@implementation NSCacheWebServiceCache

- (id)initWithDefaultExpirationTime:(NSTimeInterval)defaultExpirationTime
{
    self = [super init];
    if (self)
    {
        self.internalCache = [[NSCache alloc] init];
        self.defaultExpirationTime = defaultExpirationTime;
    }
    return self;
}

- (void)setObject:(id<NSCoding>)anObject forKey:(NSString *)key
{
    [self setObject:anObject forKey:key
      withTimeStamp:[[NSDate date] timeIntervalSince1970] withExpirationInterval:self.defaultExpirationTime];
}

- (void)setObject:(id<NSCoding>)anObject forKey:(NSString *)key withTimeStamp:(NSTimeInterval)timeStamp
{
    [self setObject:anObject forKey:key withTimeStamp:timeStamp withExpirationInterval:self.defaultExpirationTime];
}

- (void)setObject:(id<NSCoding>)anObject forKey:(NSString *)key withTimeStamp:(NSTimeInterval)timeStamp withExpirationInterval:(NSTimeInterval)specificExpirationInterval
{
    if (anObject != nil && key != nil)
    {
        CacheAtom * current;
        current = [self.internalCache objectForKey:key];
        
        if ((current) && [(id)current.payload isEqual:anObject])
        {
            current.created = timeStamp;
            current.expires = timeStamp + specificExpirationInterval;
            current.payload = anObject;
        }
        else
        {
            current = [[CacheAtom alloc] initWithPayload:anObject
                                        withCreationTime:timeStamp
                                               expiresIn:specificExpirationInterval];
        }
        [self.internalCache setObject:current forKey:key];
    }
}

- (id<NSCoding>)objectForKey:(NSString *)key
{
    CacheAtom * a;
    a = [self.internalCache objectForKey:key];
    if (a.payload == nil)
    {
        WLog(@"Cached object with empty payload in Cache!!!!");
        [self clearObjectForKey:key];
    }
    return a.payload;
}

- (void)clearObjectForKey:(NSString *)key
{
    [self.internalCache removeObjectForKey:key];
}

- (void)clearAllObjects
{
    [self.internalCache removeAllObjects];
}

- (BOOL)expirationTimeReachedForItemWithKey:(NSString *)key
{
    CacheAtom * a = [self.internalCache objectForKey:key];
    if (a == nil || a.payload == nil)
    {
        [self clearObjectForKey:key];
        return NO;
    }
    DLog(@"%d", [a hasExpired]);
    return [a hasExpired];
}

- (void)reactivateCacheForKey:(NSString *)key
{
    CacheAtom * a = [self.internalCache objectForKey:key];
    [a resurrect];
    [self.internalCache setObject:a forKey:key];
}

- (NSTimeInterval)timeStampForCachedItemWithKey:(NSString *)key
{
    CacheAtom * a = [self.internalCache objectForKey:key];
    return a.created;
}

@end

@implementation BaseWebServiceResource (CacheManager)

SYNTHESIZE_CATEGORY_PROPERTY(cacheProvider, nil);

+ (NSString *)base64String:(NSString *)str
{
    NSData *theData = [str dataUsingEncoding: NSASCIIStringEncoding];
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

- (NSString*) cacheKeyForClass: (Class) class itemIdentifier: (NSString *) itemIdentifier
{
    if( !class || !itemIdentifier )
    {
        return nil;
    }
    
    NSString *returnValue = [ [ NSStringFromClass( class ) stringByAppendingString: kDash ] stringByAppendingString: itemIdentifier ];
    if (iOSVersion >= 7.0)
    {
        return [ [ returnValue dataUsingEncoding: NSUTF8StringEncoding ] base64EncodedStringWithOptions: 0 ];
    }
    else
    {
        return [[self class] base64String:returnValue];
    }
}

- (void)invalidateCacheForClass:(Class)class itemIdentifier:(NSString *)itemIdentifier
{
    [self.cacheProvider clearObjectForKey:[self cacheKeyForClass:class itemIdentifier:itemIdentifier]];
}

- (void)invalidateAllCache
{
    [self.cacheProvider clearAllObjects];
}

@end

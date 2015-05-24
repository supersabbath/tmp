
#import <Foundation/Foundation.h>


@protocol GeneralCache

-(void) setObject: (id<NSCoding>) anObject forKey: (NSString *) key;

-(void) setObject: (id<NSCoding>) anObject forKey: (NSString *) key withTimeStamp: (NSTimeInterval) timeStamp;

-(void) setObject: (id<NSCoding>) anObject forKey: (NSString *) key withTimeStamp: (NSTimeInterval) timeStamp withExpirationInterval: (NSTimeInterval) specificExpirationInterval;

-(id<NSCoding>) objectForKey: (NSString *) key;

-(BOOL) expirationTimeReachedForItemWithKey: (NSString *) key;

- (NSTimeInterval) timeStampForCachedItemWithKey: (NSString *) key;

-(void) reactivateCacheForKey: (NSString *) key;

-(void) clearObjectForKey: (NSString *) key;

-(void) clearAllObjects;

@end

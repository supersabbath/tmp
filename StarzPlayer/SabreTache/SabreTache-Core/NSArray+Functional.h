#import <Foundation/Foundation.h>

@interface NSArray (Functional)

- (NSArray *)transform:(id(^)(id))block;

@end

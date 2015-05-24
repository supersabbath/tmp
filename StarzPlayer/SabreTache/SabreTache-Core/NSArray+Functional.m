#import "NSArray+Functional.h"

@implementation NSArray (Functional)

- (NSArray *)transform:(id(^)(id))block
{
    NSMutableArray*result=[NSMutableArray array];
    for(id x in self){
        id n = block(x);
        if (n)
        {
            [result addObject:block(x)];
        }
    }
    return result;
}

@end

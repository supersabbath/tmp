#import "AbstractClassUtils.h"


@implementation AbstractUtils

+ (id)abstractMethod:(SEL)selector
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(selector)]
                                 userInfo:nil];
}

@end

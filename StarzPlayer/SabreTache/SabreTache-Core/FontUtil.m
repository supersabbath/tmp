#import "FontUtil.h"

#import "SynthesizeSingleton.h"

@interface FontUtil()

@property (retain, nonatomic) NSMutableDictionary *definitions;

@end

@implementation FontUtil

SYNTHESIZE_SINGLETON_FOR_CLASS(FontUtil)

+ (void)registerFont:(UIFont *)font forKey:(NSString *)key
{
    @synchronized([FontUtil instance])
    {
        if ([FontUtil instance].definitions == nil)
        {
            [FontUtil instance].definitions = [NSMutableDictionary dictionary];
        }
        NSAssert(font != nil, @"Tried to set nil font for key: %@", key);
        [[FontUtil instance].definitions setObject:font forKey:key];
    }
}

+ (UIFont *)fontWithKey:(NSString *)key {
    UIFont * font = [[FontUtil instance].definitions objectForKey:key];
    return font;
    
}


@end

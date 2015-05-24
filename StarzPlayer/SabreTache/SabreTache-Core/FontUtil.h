#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "Macros.h"
//#import "FontUtil_CMFonts.h"

#define FONT_ID_DEF(fontId) \
extern NSString * const fontId;

#define FONT_ID_DECLARE(fontId) \
NSString * const fontId = @STRINGIFY(fontId);

#define FONT_REG(fontId, fontName, fontSize) \
DLog(@"%s", fontName);\
[FontUtil registerFont:[UIFont fontWithName:@fontName size:fontSize] forKey:fontId];

@interface FontUtil : NSObject

+ (FontUtil *)instance;

+ (void)registerFont:(UIFont *)font forKey:(NSString *)key;

+ (UIFont *)fontWithKey:(NSString *)key;

@end
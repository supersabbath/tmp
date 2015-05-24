#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AttributedTextUtils : NSObject

+ (NSAttributedString *)attributedStringWithText:(NSString *)original color:(UIColor *)color font:(UIFont *)font lineSpacing:(CGFloat)lineSpacing paragraphSpacing:(CGFloat)paragraphSpacing textAlignment:(NSTextAlignment)textAlignment;

+ (NSAttributedString *)attributedStringWithText:(NSString *)original color:(UIColor *)textColor font:(UIFont *)font lineSpacing:(CGFloat)lineSpacing paragraphSpacing:(CGFloat)paragraphSpacing;

@end

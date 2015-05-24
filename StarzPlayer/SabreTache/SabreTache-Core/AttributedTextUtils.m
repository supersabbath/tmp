#import "AttributedTextUtils.h"

@implementation AttributedTextUtils

+ (NSAttributedString *)attributedStringWithText:(NSString *)original color:(UIColor *)textColor font:(UIFont *)font lineSpacing:(CGFloat)lineSpacing paragraphSpacing:(CGFloat)paragraphSpacing
{
    return [self attributedStringWithText:original color:textColor font:font lineSpacing:lineSpacing paragraphSpacing:paragraphSpacing];
}

+ (NSAttributedString *)attributedStringWithText:(NSString *)original color:(UIColor *)color font:(UIFont *)font lineSpacing:(CGFloat)lineSpacing paragraphSpacing:(CGFloat)paragraphSpacing textAlignment:(NSTextAlignment)textAlignment
{
    if (original == nil) return [[NSAttributedString alloc] init];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpacing;
    paragraphStyle.paragraphSpacing = paragraphSpacing;
    paragraphStyle.alignment = textAlignment;
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    if (font)
    {
        attributes[NSFontAttributeName] = font;
    }
    if (color)
    {
        attributes[NSForegroundColorAttributeName] = color;
    }
    
    return [[NSAttributedString alloc] initWithString:original attributes:attributes];
}

@end

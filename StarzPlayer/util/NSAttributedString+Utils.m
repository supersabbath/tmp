//
//  NSAttributedString+Utils.m
//  Starz
//
//  Created by Tüz Csaba on 28/10/14.
//  Copyright (c) 2014 accedo. All rights reserved.
//

#import "NSAttributedString+Utils.h"

@implementation NSAttributedString(Utils)

+ (NSMutableAttributedString *)withString:(NSString *)string
{
    return [NSMutableAttributedString withString:string];
}
+ (NSMutableAttributedString *)withStringNeutral:(NSString *)string
{
    return [NSMutableAttributedString withStringNeutral:string];
}

+ (NSMutableAttributedString *)withStringCentered:(NSString *)string
{
    return [NSMutableAttributedString withStringCentered:string];
}
@end

@implementation NSMutableAttributedString(Utils)

+ (NSMutableAttributedString *)withString:(NSString *)string
{
    NSMutableAttributedString * s = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle * parStyle = [[NSMutableParagraphStyle alloc] init];
    parStyle.alignment = LEFTTORIGHTLANG ? NSTextAlignmentLeft : NSTextAlignmentRight;
    
    s = [s withParagraphStyle:parStyle];
    return s;
}

+ (NSMutableAttributedString *)withStringNeutral:(NSString *)string
{
    NSMutableAttributedString * s = [[NSMutableAttributedString alloc] initWithString:string];
    return s;
}

+ (NSMutableAttributedString *)withStringCentered:(NSString *)string
{
    NSMutableAttributedString * s = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle * parStyle = [[NSMutableParagraphStyle alloc] init];
    parStyle.alignment = NSTextAlignmentCenter;
    
    s = [s withParagraphStyle:parStyle];
    return s;
}

- (NSMutableAttributedString *)withTracking:(double)tracking
{
    if (![ACGetLanguage isEqualToString:@"ar"])
    {
        [self addAttribute:NSKernAttributeName value:@(tracking) range:NSMakeRange(0, [self length])];
    }
    return self;
}

- (NSMutableAttributedString *)withParagraphStyle:(NSMutableParagraphStyle *)parStyle
{
    if (parStyle.alignment != NSTextAlignmentCenter)
    {
        parStyle.alignment = LEFTTORIGHTLANG ? NSTextAlignmentLeft : NSTextAlignmentRight;
    }
    [self addAttribute:NSParagraphStyleAttributeName value:parStyle range:NSMakeRange(0, [self length])];
    return self;
}

- (NSMutableAttributedString *)withFont:(UIFont *)font
{
    [self addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [self length])];
    return self;
}

- (NSMutableAttributedString *)withColor:(UIColor *)color
{
    [self addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [self length])];
    return self;
}

@end

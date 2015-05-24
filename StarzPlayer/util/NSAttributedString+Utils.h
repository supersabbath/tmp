//
//  NSAttributedString+Utils.h
//  Starz
//
//  Created by Tüz Csaba on 28/10/14.
//  Copyright (c) 2014 accedo. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import <SabreTache-Core/Macros.h>
//#import <SabreTache-Core/LanguageManager.h>

// NSForegroundColorAttributeName
// NSFontAttributeName
// NSKernAttributeName (tracking)

@interface NSAttributedString(Utils)

+ (NSMutableAttributedString *)withString:(NSString *)string;
+ (NSMutableAttributedString *)withStringNeutral:(NSString *)string;
+ (NSMutableAttributedString *)withStringCentered:(NSString *)string;

@end

@interface NSMutableAttributedString(Utils)

+ (NSMutableAttributedString *)withString:(NSString *)string;
+ (NSMutableAttributedString *)withStringNeutral:(NSString *)string;
+ (NSMutableAttributedString *)withStringCentered:(NSString *)string;

- (NSMutableAttributedString *)withParagraphStyle:(NSMutableParagraphStyle *)parStyle;
- (NSMutableAttributedString *)withFont:(UIFont *)font;
- (NSMutableAttributedString *)withTracking:(double)tracking;
- (NSMutableAttributedString *)withColor:(UIColor *)color;

@end

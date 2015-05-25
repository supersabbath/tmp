//
//  UIColor+Extension.h
//  Filmnet
//
//  Created by Istvan Kolcze on 12/02/14.
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import  "Macros.h"

#define APP_COLOR(r, g, b, a) static dispatch_once_t onceToken; \
static UIColor *color = nil; \
dispatch_once(&onceToken, ^{ \
    color = RGBA(r, g, b, a); \
}); \
return color;

/*! UIColor class extension for colors used in the Parsifal Starz IOS application
 *  to avoid duplicate instantiations.
 */
@interface UIColor (PSColors)

#pragma mark - Base colors

+ (UIColor *)PSColorW;
+ (UIColor *)PSColorK;
+ (UIColor *)PSColorK1; // Background
+ (UIColor *)PSColorC1; // Titles in between module "STARZ PLAY SELECTION"
+ (UIColor *)PSColorC2;

#pragma mark - Player colors

+ (UIColor *)PSColorC3;
+ (UIColor *)PSColorC4;
+ (UIColor *)PSColorC5;

#pragma mark - Special colors

+ (UIColor *)PSColorV;
+ (UIColor *)PSColorV2;

#pragma mark - Kids colors

+ (UIColor *)PSColorR2;
+ (UIColor *)PSColorOr;
+ (UIColor *)PSColorY;
+ (UIColor *)PSColorG;

#pragma mark - Error colors

+ (UIColor *)PSColorR;

#pragma mark - Kid's Gradient Colors

+ (UIColor *) PSKidGradientStartColor;
+ (UIColor *) PSKidGradientEndColor;

@end

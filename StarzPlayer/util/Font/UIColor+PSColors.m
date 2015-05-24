//
//  UIColor+Extension.m
//  Filmnet
//
//  Created by Istvan Kolcze on 12/02/14.
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//

#import "UIColor+PSColors.h"

//TODO: Fix all warnings (check design PSD for color values)

@implementation UIColor (PSColors)

#pragma mark - Base colors

+ (UIColor *)PSColorW
{
    return [UIColor whiteColor];
}

+ (UIColor *)PSColorK {
    return [UIColor blackColor];
}

+ (UIColor *)PSColorK1 {

    //13 13 13
    APP_COLOR(0x0D, 0x0D, 0x0D, 1)
}

+ (UIColor *)PSColorC1 {

    APP_COLOR(0xFE, 0xFD, 0xF5, 1)
}

+ (UIColor *)PSColorC2 {
    APP_COLOR(0xF2, 0xF1, 0xE6, 1)
}

#pragma mark - Player colors

+ (UIColor *)PSColorC3
{
    APP_COLOR(0xD8, 0xCD, 0xB0, 1)
}

+ (UIColor *)PSColorC4
{
    APP_COLOR(0x84, 0x77, 0x58, 1);
}

+ (UIColor *)PSColorC5
{
    APP_COLOR(0x2C, 0x28, 0x1D, 1);
}

#pragma mark - Special colors

+ (UIColor *)PSColorV
{
    APP_COLOR(0x52, 0x49, 0x65, 1);
}

+ (UIColor *)PSColorV2
{
    APP_COLOR(0x2D, 0x28, 0x37, 1);
}

#pragma mark - Kids colors

+ (UIColor *)PSColorR2
{
    APP_COLOR(0xFF, 0x26, 0x26, 1);
}

+ (UIColor *)PSColorOr
{
    APP_COLOR(0xFF, 0x93, 0x26, 1);
}

+ (UIColor *)PSColorY
{
    APP_COLOR(0xD2, 0xFF, 0x4D, 1);
}

+ (UIColor *)PSColorG
{
    APP_COLOR(0x4D, 0xFF, 0xA6, 1);
}

#pragma mark - Error Colours

+ (UIColor *)PSColorR
{
    APP_COLOR(0xFF, 0x45, 0x5D, 1);
}

#pragma mark - Kid's Gradient Colors
+ (UIColor *) PSKidGradientStartColor
{
    APP_COLOR(0xBD, 0x5a, 0x03, 1);
}

+ (UIColor *) PSKidGradientEndColor
{
    APP_COLOR(0x1E, 0x4c, 0x5f, 1);
}
@end

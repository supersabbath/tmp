//
//  UIImageUtil.m
//  Starz
//
//  Created by Balint Halasz on 1/26/15.
//  Copyright (c) 2015 accedo. All rights reserved.
//

#import "UIImageUtil.h"

@implementation UIImageUtil

+ (UIImage *)imageScaled:(UIImage*)image scale:(CGFloat)scale withInterpolationQuality:(CGInterpolationQuality)quality
{
    UIGraphicsBeginImageContextWithOptions(image.size, YES, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, quality);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end

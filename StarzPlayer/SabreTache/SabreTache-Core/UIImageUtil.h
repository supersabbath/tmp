//
//  UIImageUtil.h
//  Starz
//
//  Created by Balint Halasz on 1/26/15.
//  Copyright (c) 2015 accedo. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface UIImageUtil : NSObject

+ (UIImage *)imageScaled:(UIImage*)image scale:(CGFloat)scale withInterpolationQuality:(CGInterpolationQuality)quality;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end

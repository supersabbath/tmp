//
//  UIButton+Utils.h
//  Starz
//
//  Created by Tüz Csaba on 21/11/14.
//  Copyright (c) 2014 accedo. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface UIButton (Utils)

- (void)setProvidedAssetAsBackgroundImage:(NSString *)asset;
- (void)setProvidedAssetAsImage:(NSString *)asset;

 

#pragma mark - Static utility methods

+ (NSMutableAttributedString *)buttonAttributedString:(NSString *)text;

@end

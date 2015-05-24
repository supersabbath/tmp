//
//  UIProgressView+Utils.m
//  Starz
//
//  Created by Tüz Csaba on 13/01/15.
//  Copyright (c) 2015 accedo. All rights reserved.
//

#import "UIProgressView+Utils.h"

#import "UIColor+PSColors.h"

@implementation UIProgressView (Utils)

- (void)makePSIPhoneStyle
{
    self.progressTintColor = [UIColor PSColorW];
    self.trackTintColor = [UIColor colorWithRed:0.263 green:0.286 blue:0.302 alpha:1];
    [self setBackgroundColor:[UIColor clearColor]];
    self.layer.borderColor = [self.trackTintColor CGColor];
    self.layer.borderWidth = 1;
    self.layer.cornerRadius = 4.0;
}

@end

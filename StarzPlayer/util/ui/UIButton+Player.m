//
//  UIButton+Utils.m
//  Starz
//
//  Created by Tüz Csaba on 21/11/14.
//  Copyright (c) 2014 accedo. All rights reserved.
//

#import "UIButton+Player.h"

 

@implementation UIButton (Player)

- (void)setProvidedAssetAsBackgroundImage:(NSString *)asset
{
    UIImage * resizableNormal = [[UIImage imageNamed:[NSString stringWithFormat:@"%@n.png", asset]] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    UIImage * resizableDisabled = [[UIImage imageNamed:[NSString stringWithFormat:@"%@d.png", asset]] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    UIImage * resizablePressed = [[UIImage imageNamed:[NSString stringWithFormat:@"%@p.png", asset]] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [self setBackgroundImage:resizableNormal forState:UIControlStateNormal];
    [self setBackgroundImage:resizablePressed forState:UIControlStateSelected];
    [self setBackgroundImage:resizableDisabled forState:UIControlStateDisabled];
    [self setBackgroundImage:resizablePressed forState:UIControlStateHighlighted];
}

- (void) setProvidedAssetAsImage:(NSString *)asset
{
    UIImage * resizableNormal = [UIImage imageNamed:[NSString stringWithFormat:@"%@n.png", asset]];
    UIImage * resizableDisabled = [UIImage imageNamed:[NSString stringWithFormat:@"%@d.png", asset]];
    UIImage * resizablePressed = [UIImage imageNamed:[NSString stringWithFormat:@"%@p.png", asset]];
    [self setImage:resizableNormal forState:UIControlStateNormal];
    [self setImage:resizableDisabled forState:UIControlStateDisabled];
    [self setImage:resizablePressed forState:UIControlStateHighlighted];
    [self setBackgroundImage:resizablePressed forState:UIControlStateSelected];
}

@end

//
//  UILabel+Utils.m
//  Starz
//
//  Created by Tüz Csaba on 28/10/14.
//  Copyright (c) 2014 accedo. All rights reserved.
//

#import "UILabel+Utils.h"

@implementation UILabel(Utils)

- (CGFloat)minimalHeightForWidth:(CGFloat)w
{
    CGFloat s = 0;
    if (self.attributedText)
    {
        s = [self.attributedText boundingRectWithSize:CGSizeMake(w, 9999) options:NSStringDrawingUsesLineFragmentOrigin
                                                        context:nil].size.height;
    }
    else
    {
        s = [self.text boundingRectWithSize:CGSizeMake(w, 9999) options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:nil
                                              context:nil].size.height;
    }
    return s;
}

@end

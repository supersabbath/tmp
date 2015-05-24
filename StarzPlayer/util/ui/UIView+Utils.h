//
//  UIView+Utils.h
//  Starz
//
//  Created by Tüz Csaba on 29/10/14.
//  Copyright (c) 2014 accedo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView(Utils)

+ (void)animate:(void (^)(void))animation withKeyboard:(NSNotification *)keyboardNotif inView:(UIView *)view;

@end

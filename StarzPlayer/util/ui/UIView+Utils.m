//
//  UIView+Utils.m
//  Starz
//
//  Created by Tüz Csaba on 29/10/14.
//  Copyright (c) 2014 accedo. All rights reserved.
//

#import "UIView+Utils.h"

@implementation UIView(Utils)

+ (void)animate:(void (^)(void))animation withKeyboard:(NSNotification *)keyboardNotif inView:(UIView *)view {
    if (!animation || !keyboardNotif || !view || ![NSThread isMainThread]) {
        return;
    }
    
    [UIView beginAnimations:nil context:NULL];
    
    [UIView setAnimationDuration:[keyboardNotif.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[keyboardNotif.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES]; animation();
    [view layoutIfNeeded];
    
    [UIView commitAnimations];
}

@end

//
//  UIBlockAlertView.h
//  Filmnet
//
//  Created by Csaba Tűz on 2014.04.08..
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBlockAlertView : UIAlertView<UIAlertViewDelegate>

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message
                 handlerBlock:(void(^)(NSInteger buttonIndex))handler
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ...;

@end

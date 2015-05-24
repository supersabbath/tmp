//
//  UIAlertViewHelper.h
//  Filmnet
//
//  Created by Csaba Tűz on 2014.03.28..
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIAlertViewHelper : NSObject

+ (void)confirmationAlertWithTitle:(NSString *)title message:(NSString *)message onYes:(void(^)(void))yesBlock onNo:(void(^)(void))noBlock;

+ (void)notificationAlertWithTitle:(NSString *)title message:(NSString *)message onDone:(void(^)(void))doneBlock;

@end

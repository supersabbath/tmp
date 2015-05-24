//
//  UIViewController+InfoMessage.h
//  SabreTache-Core
//
//  Created by Tüz Csaba on 10/03/15.
//  Copyright (c) 2015 Accedo Broadband AB. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ProtocolProperties.h"

typedef NS_ENUM(NSInteger, InfoMessageAlignment)
{
    InfoMessageAlignmentTop = 1,
    InfoMessageAlignmentBottom = 2
};

@interface UIViewController (InfoMessage)

CATEGORY_PROPERTY(UIView *, infoView);

- (void)showInfoMessage:(NSString *)message;
- (void)showInfoMessage:(NSString *)message alignment:(InfoMessageAlignment)alignment;

- (void)showAttributedInfoMessage:(NSAttributedString *)message;
- (void)showAttributedInfoMessage:(NSAttributedString *)message alignment:(InfoMessageAlignment)alignment;

@end

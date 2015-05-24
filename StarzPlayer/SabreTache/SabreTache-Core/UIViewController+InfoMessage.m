//
//  UIViewController+InfoMessage.m
//  SabreTache-Core
//
//  Created by Tüz Csaba on 10/03/15.
//  Copyright (c) 2015 Accedo Broadband AB. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "UIViewController+InfoMessage.h"

#import "FontUtil.h"

static NSInteger const InfoMessageLabelTag = 987;

@implementation UIViewController (InfoMessage)

SYNTHESIZE_CATEGORY_PROPERTY(infoView, nil);

- (void)createInfoView
{
    if (self.infoView == nil)
    {
        self.infoView = [[UIView alloc] init];
        self.infoView.alpha = 0.0;
        CGRect f = self.infoView.frame;
        f.size.height = 30;
        f.size.width = 50;
        self.infoView.frame = f;
        
        UILabel * label = [[UILabel alloc] init];
        label.tag = InfoMessageLabelTag;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        [self.infoView addSubview:label];
        label.frame = self.infoView.bounds;
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        label.textAlignment = NSTextAlignmentCenter;
        
        [self.view addSubview:self.infoView];
        self.infoView.backgroundColor = [UIColor blackColor];
        self.infoView.hidden = YES;
    }
}

- (void)animateInfoView
{
    [self.view bringSubviewToFront:self.infoView];
    
    self.infoView.hidden = NO;
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.infoView.alpha = 1.0;
    } completion:^(BOOL finished) {
        if (finished)
        {
            [UIView animateWithDuration:2.0 delay:2.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.infoView.alpha = 0.0;
            } completion:^(BOOL finished) {
                if (finished)
                    self.infoView.hidden = YES;
            }];
        }
    }];
}

- (void)updateInfoViewWithText:(NSString *)message forAlignment:(InfoMessageAlignment)alignment
{
    UILabel * label = (UILabel *)[self.infoView viewWithTag:InfoMessageLabelTag];
    label.text = message;
    [self resizeLabel:label forAlignment:alignment];
}

- (void)updateInfoViewWithAttributedText:(NSAttributedString *)message forAlignment:(InfoMessageAlignment)alignment
{
    UILabel * label = (UILabel *)[self.infoView viewWithTag:InfoMessageLabelTag];
    label.attributedText = message;
    [self resizeLabel:label forAlignment:alignment];
}

- (void)resizeLabel:(UILabel *)label forAlignment:(InfoMessageAlignment)alignment
{
    [label sizeToFit];
    
    CGRect f = self.infoView.frame;
    f.size.width = self.view.bounds.size.width;
    f.origin.x = 0;
    switch (alignment)
    {
        case InfoMessageAlignmentBottom:
            f.origin.y = self.view.bounds.size.height - f.size.height;
            break;
        case InfoMessageAlignmentTop:
            f.origin.y = 0;
            break;
    }
    self.infoView.frame = f;
    label.frame = self.infoView.bounds;
}

- (void)showInfoMessage:(NSString *)message alignment:(InfoMessageAlignment)alignment
{
    [self createInfoView];
    
    [self updateInfoViewWithText:message forAlignment:alignment];
    
    [self animateInfoView];
}

- (void)showInfoMessage:(NSString *)message
{
    [self showInfoMessage:message alignment:InfoMessageAlignmentTop];
}

- (void)showAttributedInfoMessage:(NSAttributedString *)message alignment:(InfoMessageAlignment)alignment
{
    [self createInfoView];
    
    [self updateInfoViewWithAttributedText:message forAlignment:alignment];
    
    [self animateInfoView];
}

- (void)showAttributedInfoMessage:(NSAttributedString *)message
{
    [self showAttributedInfoMessage:message alignment:InfoMessageAlignmentTop];
}

@end

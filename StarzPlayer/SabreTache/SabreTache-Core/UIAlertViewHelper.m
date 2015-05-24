//
//  UIAlertViewHelper.m
//  Filmnet
//
//  Created by Csaba Tűz on 2014.03.28..
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//

#import "UIAlertViewHelper.h"
#import "LanguageManager.h"

#import "UIBlockAlertView.h"

@interface AccedoAlertViewDelegate : NSObject<UIAlertViewDelegate>

@property (copy, nonatomic) void(^handlerBlock)(int buttonIndex);

- (instancetype)initWithHandlerBlock:(void(^)(int buttonIndex))handlerBlock;

@end

@implementation AccedoAlertViewDelegate

- (instancetype)initWithHandlerBlock:(void(^)(int buttonIndex))handlerBlock
{
    self = [super init];
    if (self)
    {
        self.handlerBlock = handlerBlock;
    }
    return self;
}

@end

@implementation UIAlertViewHelper

+ (void)confirmationAlertWithTitle:(NSString *)title message:(NSString *)message onYes:(void(^)(void))yesBlock onNo:(void(^)(void))noBlock
{
    UIAlertView *alert = [[UIBlockAlertView alloc] initWithTitle:title message:message handlerBlock:^(NSInteger buttonIndex) {
        switch(buttonIndex)
        {
            case 0:
                if (noBlock)
                    noBlock();
                break;
            case 1:
                if (yesBlock)
                    yesBlock();
                break;
        }
    } cancelButtonTitle:ACLocalizedString(@"dict_settings_no") otherButtonTitles:ACLocalizedString(@"dict_settings_yes"), nil];

    [alert show];
}


+ (void)notificationAlertWithTitle:(NSString *)title message:(NSString *)message onDone:(void(^)(void))doneBlock
{
    UIAlertView *alert = [[UIBlockAlertView alloc] initWithTitle:title message:message handlerBlock:^(NSInteger buttonIndex) {
        if (doneBlock)
            doneBlock();
    } cancelButtonTitle:ACLocalizedString(@"key_OK") otherButtonTitles:nil];
     [alert show];
    
}

@end

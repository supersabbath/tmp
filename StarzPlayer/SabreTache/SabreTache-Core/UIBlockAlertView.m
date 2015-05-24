//
//  UIBlockAlertView.m
//  Filmnet
//
//  Created by Csaba Tűz on 2014.04.08..
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//

#import "UIBlockAlertView.h"

@interface UIBlockAlertView()

@property (copy, nonatomic) void(^handler)(NSInteger buttonIndex);

@end

@implementation UIBlockAlertView

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message
                 handlerBlock:(void(^)(NSInteger buttonIndex))handler
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [super init];
    if (self)
    {
        [self setTitle:title];
        [self setMessage:message];
        self.delegate = self;
        self.handler = handler;
        [self addButtonWithTitle:cancelButtonTitle];
        if (otherButtonTitles)
        {
            va_list args;
            va_start(args, otherButtonTitles);
            for (NSString * title = otherButtonTitles; title != nil; title = va_arg(args, NSString*))
            {
                [self addButtonWithTitle:title];
            }
            va_end(args);
        }
    }
    return self;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (self.handler)
    {
        self.handler(buttonIndex);
    }
}

@end

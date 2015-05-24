//
//  ExternalDisplayManager.m
//  Filmnet
//
//  Created by Tüz Csaba on 06/08/14.
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//

#import "ExternalDisplayManager.h"

#import <SabreTache-Core/SynthesizeSingleton.h>

@implementation ExternalDisplayManager

SYNTHESIZE_SINGLETON_FOR_CLASS(ExternalDisplayManager)

- (id)initWithDelegate:(id<DisplayManagerDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        self.delegate = delegate;
        
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    [self checkForExistingScreenAndInitializeIfPresent];
    [self setUpScreenConnectionNotificationHandlers];
}

- (void)checkForExistingScreenAndInitializeIfPresent
{
    if ([[UIScreen screens] count] > 1)
    {
        // Get the screen object that represents the external display.
        UIScreen *secondScreen = [[UIScreen screens] objectAtIndex:1];
        // Get the screen's bounds so that you can create a window of the correct size.
        CGRect screenBounds = secondScreen.bounds;
        
        self.secondWindow = [[UIWindow alloc] initWithFrame:screenBounds];
        self.secondWindow.screen = secondScreen;
        
        self.secondWindow.rootViewController = self.externalScreenRootController;
        
        self.secondWindow.hidden = NO;
                
        self.isConnected = YES;
        
        if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(displayManager:didConnectWindow:)])
        {
            [self.delegate displayManager:self didConnectWindow:self.secondWindow];
        }
    }
}

- (void)setUpScreenConnectionNotificationHandlers
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(handleScreenDidConnectNotification:)
                   name:UIScreenDidConnectNotification object:nil];
    [center addObserver:self selector:@selector(handleScreenDidDisconnectNotification:)
                   name:UIScreenDidDisconnectNotification object:nil];
}

- (void)handleScreenDidConnectNotification:(NSNotification*)aNotification
{
    UIScreen *newScreen = [aNotification object];
    CGRect screenBounds = newScreen.bounds;
    
    if (!self.secondWindow)
    {
        self.secondWindow = [[UIWindow alloc] initWithFrame:screenBounds];
        self.secondWindow.screen = newScreen;
        
        self.secondWindow.rootViewController = self.externalScreenRootController;
        
        self.secondWindow.hidden = NO;
        
        self.isConnected = YES;
        
        if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(displayManager:didConnectWindow:)])
        {
            [self.delegate displayManager:self didConnectWindow:self.secondWindow];
        }
    }
}

- (void)setExternalScreenRootController:(UIViewController *)externalScreenRootController
{
    _externalScreenRootController = externalScreenRootController;
    if (self.secondWindow)
    {
        self.secondWindow.rootViewController = self.externalScreenRootController;
    }
}

- (void)handleScreenDidDisconnectNotification:(NSNotification*)aNotification
{
    if (self.secondWindow)
    {
        // Hide and then delete the window.
        self.secondWindow.hidden = YES;
        self.secondWindow = nil;
        
        self.isConnected = NO;
        
        if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(displayManager:didDisconnectWindow:)])
        {
            [self.delegate displayManager:self didDisconnectWindow:nil];
        }
    }
    
}

@end

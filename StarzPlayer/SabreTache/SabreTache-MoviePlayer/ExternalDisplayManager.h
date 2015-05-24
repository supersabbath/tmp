//
//  ExternalDisplayManager.h
//  Filmnet
//
//  Created by Tüz Csaba on 06/08/14.
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class ExternalDisplayManager;

@protocol DisplayManagerDelegate

@optional
- (void)displayManager:(ExternalDisplayManager *)manager didConnectWindow:(UIWindow *)window;
- (void)displayManager:(ExternalDisplayManager *)manager willDisconnectWindow:(UIWindow *)window;

- (void)displayManager:(ExternalDisplayManager *)manager didDisconnectWindow:(UIWindow *)window;

@end

@interface ExternalDisplayManager : NSObject

- (id)initWithDelegate:(id<DisplayManagerDelegate>)delegate;

- (void)initialize;

@property (assign, nonatomic) id<DisplayManagerDelegate> delegate;

@property (retain, nonatomic) UIViewController * externalScreenRootController;
@property (retain, nonatomic) UIWindow * secondWindow;

@property (assign, nonatomic) BOOL isConnected;

+ (ExternalDisplayManager *)instance;

@end

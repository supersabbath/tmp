//
//  AbstractCustomControlCell.h
//  Filmnet
//
//  Created by Csaba Tűz on 2014.04.29..
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ProtocolProperties.h"

/** 
 `CustomControlCell` is a general cell protocol to be used, when the
 cell's functionality is complicated enough to be delegated to a
 separate UIViewController.
 */
@protocol CustomControlCell

/**
 Asks the `CustomControlCell` to attach its managed `UIViewController` to the 
 passed `controller`.
 
 Your implementation must take care, that the managed controller becomes attached
 to the `UIViewController` hierarchy of the passed `controller` instance.
 
 The implementation should consider, and handle situations, when the managed
 controller is already attached to another controller, or the same as the method
 was invoked with.
 */
- (void)attachToViewController:(UIViewController*)controller;

/**
 Asks the `CustomControlCell` for an instance of the managed `UIViewController`.
 
 Your implementation has to instantiate a new controller, and return it.
 */
- (UIViewController *)customControl;

@end

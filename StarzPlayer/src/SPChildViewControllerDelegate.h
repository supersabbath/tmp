//
//  SPChildViewControllerDelegate.h
//  StarzPlayer
//
//  Created by Fernando Canon on 26/05/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#ifndef StarzPlayer_SPChildViewControllerDelegate_h
#define StarzPlayer_SPChildViewControllerDelegate_h

typedef NS_ENUM(NSInteger, PSPlayerMessage) {
    PSPlayerMessageMute,
    PSPlayerMessageUnMute
};


/*
 This protocol must be use by the children view controllers to create their delegate
 */
@protocol SPChildViewControllerDelegate <NSObject>

/*
 childViewController:(UIViewController*) viewController didCompleteActionWithMessage:(NSString*) message
 Should message the SPPlayerViewController instances, that informs that the actions has been performed and is done
 */
-(void) childViewController:(UIViewController*) viewController didCompleteActionWithMessage:(PSPlayerMessage) messageType;

@end
#endif

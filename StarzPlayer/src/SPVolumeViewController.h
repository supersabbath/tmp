//
//  SPVolumeViewController.h
//  StarzPlayer
//
//  Created by Fernando Canon on 23/05/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPChildViewControllerDelegate.h"



@interface SPVolumeViewController : UIViewController 

@property (nonatomic, weak) id <SPChildViewControllerDelegate> delegate;

- (void) updateVolumeLevel;
- (IBAction) mutePlayer:(id)sender;
@end


//
//  ExternalDisplayViewController.h
//  Filmnet
//
//  Created by Tüz Csaba on 10/08/14.
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExternalDisplayViewController : UIViewController

@property (retain) IBOutlet UILabel  * subtitleLabel;

+ (ExternalDisplayViewController *)instance;
+ (void)resetVCInstance;

- (void)updateUIForSubtitle:(NSString *)subtitle;

@end

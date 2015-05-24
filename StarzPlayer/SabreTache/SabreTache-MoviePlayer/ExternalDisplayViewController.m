//
//  ExternalDisplayViewController.m
//  Filmnet
//
//  Created by Tüz Csaba on 10/08/14.
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//

#import "ExternalDisplayViewController.h"

#import <SabreTache-Core/Macros.h>

@interface ExternalDisplayViewController ()

@end

@implementation ExternalDisplayViewController

SYNTHESIZE_SINGLETON_VC(ExternalDisplayViewController, @"ExternalDisplayViewController")

- (void)updateUIForSubtitle:(NSString *)subtitle {
    if (subtitle != nil)
    {
        self.subtitleLabel.text = subtitle;
    }else{
        self.subtitleLabel.text = @"";
    }
}

@end

//
//  UINavigationController+PSNavigationController.m
//  Starz
//
//  Created by Tüz Csaba on 13/01/15.
//  Copyright (c) 2015 accedo. All rights reserved.
//

#import "UINavigationController+PSNavigationController.h"

@implementation UINavigationController (PSNavigationController)

-(BOOL)shouldAutorotate
{
    return [self.topViewController shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

@end

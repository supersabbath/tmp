//
//  PSUITools.m
//  Parsifal
//
//  Created by Halasz Balint on 7/21/14.
//  Copyright (c) 2014 accedo. All rights reserved.
//

#import <MBProgressHUD.h>
#import "UIColor+PSColors.h"
@implementation PSUITools


+(void) showYellowLoadingIndicatorInView:(UIView*) view{

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.color = [UIColor PSColorK1];
    hud.activityIndicatorColor = [UIColor PSColorC3];
    hud.removeFromSuperViewOnHide = YES;
}

+ (void)showLoadingIndicatorInView:(UIView *)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.color = [UIColor blackColor];
    hud.removeFromSuperViewOnHide = YES;
}

+ (void)hideLoadingIndicatorInView:(UIView *)view
{
    [MBProgressHUD hideAllHUDsForView:view animated:YES];
}
@end

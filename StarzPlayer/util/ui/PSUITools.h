//
//  PSUITools.h
//  Parsifal
//
//  Created by Halasz Balint on 7/21/14.
//  Copyright (c) 2014 accedo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LOADING_BEGINS(view) [PSUITools showLoadingIndicatorInView:view];
#define LOADING_ENDS(view) [PSUITools hideLoadingIndicatorInView:view];
#define YELLOW_LOADIN_BEGINS(view) [PSUITools showYellowLoadingIndicatorInView:view];

@interface PSUITools : NSObject

+ (void) showLoadingIndicatorInView:(UIView*)view;

+ (void) hideLoadingIndicatorInView:(UIView*)view;

+(void) showYellowLoadingIndicatorInView:(UIView*) view;
@end

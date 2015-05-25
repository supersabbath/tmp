//
//  PSContainerView.m
//  StarzPlayer
//
//  Created by Fernando Canon on 25/05/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import "PSContainerView.h"



@interface PSContainerView ()
{
    NSNumber * displayed;
}

@end


@implementation PSContainerView

- (instancetype)init
{
    self = [super init];
    if (self) {
        displayed = @YES;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
           displayed = @YES;
    }
    return self;
}

-(BOOL) isDisplayed
{
    return [displayed  isEqual: @YES];
}


-(void) setDisplayStatus:(BOOL) isDisplayed
{
    
    displayed = [NSNumber numberWithBool:isDisplayed];
    
    if (isDisplayed == YES)
    {
        [self showViewContainer];
    } else {
        [self hideViewContainer];
    }
}


#pragma mark -
#pragma mark UI Actions
/*
 */
-(void) hideViewContainer
{
    [UIView animateWithDuration:0.8 animations:^{
        self.alpha = 0.0f;
    }];
}


-(void) showViewContainer
{
    [UIView animateWithDuration:0.8 animations:^{
        self.alpha = 1.0;
    }];
}
@end

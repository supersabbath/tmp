//
//  PSContainerView.m
//  StarzPlayer
//
//  Created by Fernando Canon on 25/05/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import "SPContainerView.h"



@interface SPContainerView ()
{
    NSNumber * displayed;
}

@end


@implementation SPContainerView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.displayed = @NO;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
           self.displayed = @NO;
        
    }
    return self;
}

-(void) setDisplayed:(NSNumber*) value
{
    displayed = value;
    if ([self isDisplayed])
    {
        [self showViewContainer];
    
    }else{
        [self hideViewContainer];
    }
    
}


-(BOOL) isDisplayed
{
    return [displayed  isEqual: @YES];
}


-(void) setDisplayStatusNonAnimated:(BOOL) isDisplayed
{
    displayed = [NSNumber numberWithBool:isDisplayed];
}


-(void) setDisplayStatus:(BOOL) isDisplayed
{
    self.displayed = [NSNumber numberWithBool:isDisplayed];

}


#pragma mark -
#pragma mark UI Actions
/*
 */
-(void) hideViewContainer
{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.0f;
      
    }];

}


-(void) showViewContainer
{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1.0;
      
    }];
}
@end

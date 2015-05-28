//
//  PSContainerView.h
//  StarzPlayer
//
//  Created by Fernando Canon on 25/05/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPContainerView : UIView

-(BOOL) isDisplayed;


/**  changeDisplayStatusWithBolean.
 @param isDisplayed  A NSNumber with a boolean value
 */
-(void) setDisplayStatus:(BOOL) isDisplayed;
@end

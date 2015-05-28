//
//  SPPlayerViewControllerDelegate.h
//  StarzPlayer
//
//  Created by Fernando Canon on 26/05/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#ifndef StarzPlayer_SPPlayerViewControllerDelegate_h
#define StarzPlayer_SPPlayerViewControllerDelegate_h
@class SPPlayerViewController;
@class PTSVideoItem;
 


@protocol SPPlayerViewControllerDelegate <NSObject>

-(void) playerViewController:(SPPlayerViewController*) playerVC didLoadWithVideoItem:(PTSVideoItem*) item;

/*
  Called when Adobe's player notifications are received
 */
-(void) playerViewController:(SPPlayerViewController*) playerVC changePlaybackStatus:(PTMediaPlayerStatus) status;

/*
 Called before dissmising the player View
 */
-(void) playerViewControllerWillDissmissed:(SPPlayerViewController *)playerVC ;

-(void) playerViewControllerReadyToBeDissmissed:(SPPlayerViewController *)playerVC ;
@end

@protocol SPPlayerViewControllerViewDataSource <NSObject>

/* Must provide a view to add in the view hierarchy of the player*/
-(UIView*) playerViewController:(SPPlayerViewController*) playerVC viewForEpisodeSelectorForVideoItem:(PTSVideoItem*) item;

/* Must return view for the postPlay Scenario*/
-(UIView*) playerViewController:(SPPlayerViewController*) playerVC  viewToDisplayAfterVideoPlayback:(PTSVideoItem*) item;
@end



#endif

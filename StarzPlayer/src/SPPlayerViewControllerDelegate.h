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
@class PTMediaError;

@class DRMError;


@protocol SPPlayerViewControllerDelegate <NSObject>

@optional
-(void) playerViewController:(SPPlayerViewController*) playerVC didLoadWithVideoItem:(PTSVideoItem*) item;

/*
  Called when Adobe's player notifications are received
 */
@optional
-(void) playerViewController:(SPPlayerViewController*) playerVC changePlaybackStatus:(PTMediaPlayerStatus) status;

/*
 Called before dissmising the player View. Prepare the view for removing the player from the view hierachy. After calling this method
 playerViewControllerReadyToBeDissmissed: will be called
 */
@optional
-(void) playerViewControllerWillDissmissed:(SPPlayerViewController *)playerVC ;

/*
  Remove the player from view .. or release it 
 */
@optional
-(void) playerViewControllerReadyToBeDissmissed:(SPPlayerViewController *)playerVC ;

/* All the drm error willbe log here*/
@optional
-(void) playerViewController:(SPPlayerViewController *)playerVC willStopDueDRMError:(DRMError *)error;

-(void) playerViewController:(SPPlayerViewController *)playerVC willStopDuePTMediaError:(PTMediaError*)error;
@end

@protocol SPPlayerViewControllerAddableViews <NSObject>
@optional
-(UIView*) addableViewShow;
@optional
-(UIView*) addableViewHide;
@end



@protocol SPPlayerViewControllerViewDataSource <NSObject>

/* Must provide a view to add in the view hierarchy of the player*/
-(id<SPPlayerViewControllerAddableViews>) playerViewController:(SPPlayerViewController*) playerVC viewForEpisodeSelectorForVideoItem:(PTSVideoItem*) item;

/* Must return view for the postPlay Scenario*/
-(UIView*) playerViewController:(SPPlayerViewController*) playerVC  viewToDisplayAfterVideoPlayback:(PTSVideoItem*) item;
@end



#endif

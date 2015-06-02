//
//  SPPlayerViewController.h
//  StarzPlayer
//
//  Created by Fernando Canon on 18/05/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPPlayerControlView.h"
#import "MetadataTableViewController.h"
#import "SPChildViewControllerDelegate.h"

#import "SPPlayerViewControllerDelegate.h"

@class SPContainerView;
@class PTSVideoItem;
@class SPPlayerUIStyle;
/*
    Notfication Types .. Objects registered to these notifications must implement SPPlayerControllerObserverProtocol
 */
FOUNDATION_EXPORT NSString *const SPPlayerChangeContentNotification;
FOUNDATION_EXPORT NSString *const SPPlayerDidLoadNotification;
FOUNDATION_EXPORT NSString *const SPPlayerStatusPlayingNotification;

FOUNDATION_EXPORT NSString *const SPPlayerTimeElapset5SecondsNotification;
FOUNDATION_EXPORT NSString *const SPPlayerStatusPausedNotification;
FOUNDATION_EXPORT NSString *const SPPlayerStatusStoppedNotification;
FOUNDATION_EXPORT NSString *const SPPlayerStatusCompletedNotification;
FOUNDATION_EXPORT NSString *const SPPPlayerStatusErrorNotification;
FOUNDATION_EXPORT NSString *const SPPlayerWillStopNotification;

@interface SPPlayerViewController : UIViewController <SPPlayerControlViewDelegate, UITableViewDelegate ,MetadataTableViewControllerDelegate, SPChildViewControllerDelegate>

/*currentItem Video playable item*/
@property (nonatomic, strong) PTSVideoItem *currentItem ;
/* DataSource Will provide views that are not included in the player view controller .. such as the Episode Selector*/
@property (nonatomic, weak) id <SPPlayerViewControllerViewDataSource> dataSource;   // see SPPlayerViewControllerDelegate.h
@property (nonatomic, weak) id <SPPlayerViewControllerDelegate> delgate;            // see SPPlayerViewControllerDelegate.h


/*  initWithVideoItem:(PTSVideoItem *) videoItem andStyle:(SPPlayerUIStyle*) uiStyle
 
 @param videoItem PTSVideoItem's objects contains all the metadata needed for the receiver to been able to playback
 
 @return Player viewcontroller
 @see PTSVideoItem:
 @warning *Warning:* Use initWithVideoItem: for initialization .. don 't use the super class methods
 */
-(instancetype) initWithVideoItem:(PTSVideoItem *) videoItem andStyle:(SPPlayerUIStyle*) uiStyle;


/*Playback Public Actions*/
- (void) playVideo:(PTSVideoItem *)item;
- (void) playCurrentVideo;

// See also SPPlayerChangeContentNotification

//- (void) resize;
- (void) stopVideo;
- (void) pauseVideo;
- (void) resumeVideo;
 
@end


@interface SPPlayerViewController (TEST)

@property (nonatomic, weak) IBOutlet SPPlayerControlView *controlView;

@end

@protocol SPPlayerControllerObserverProtocol <NSObject>

/**
 * Protocol which defines an interface on which the movie player can notify an implementor
 * of this protocol of certain lifecycle events.
 *
 * Its use can be for various reasons, e.g. implementing analytics reacting to various events
 * in the player's lifetime.
 */

/** Called by `PTMoviePlayerController` right before it starts loading the original resource. */
@required
- (void)moviePlayerDidLoad:(id<SPPlayerControllerObserverProtocol>)moviePlayerController;

/** Called after playback is initiated for the first time, but before buffering is done. */
@required
- (void)moviePlayerDidStartPlay:(id<SPPlayerControllerObserverProtocol>)moviePlayerController;

/** Called when buffering started */
@optional
- (void)moviePlayerDidStartBuffering:(id<SPPlayerControllerObserverProtocol>)moviePlayerController;

/** Called after buffering completed */
@required
- (void)moviePlayerDidFinishBuffering:(id<SPPlayerControllerObserverProtocol>)moviePlayerController;

/** Called when Stop event occurs */
@required
- (void)moviePlayerDidPause:(id<SPPlayerControllerObserverProtocol>)moviePlayerController;

/** Called when Resume event occurs */
//- (void)moviePlayerDidResume:(id<SPPlayerControllerObserverProtocol>)moviePlayerController;

/** Called when Stop event occurs */
@required
- (void)moviePlayerDidStop:(id<SPPlayerControllerObserverProtocol>)moviePlayerController;

/** Called when an error occured which needs to be reported to analytics API */
@required
- (void)moviePlayer:(id<SPPlayerControllerObserverProtocol>)moviePlayerController didErrorOccur:(NSError *)err;

/** Called when playback is done. Classe that implement this method should Stop Observing when called */
@required
- (void)moviePlayerDidFinishPlayback:(id<SPPlayerControllerObserverProtocol>)moviePlayerController;
/** Called right before normal Stop event will occur */
@optional
- (void)moviePlayerWillStop:(id<SPPlayerControllerObserverProtocol>)moviePlayerController;

@end




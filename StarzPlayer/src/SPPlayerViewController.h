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
#import "SPPlayerControllerObserverProtocol.h"

@class SPContainerView;
@class PTSVideoItem;
@class SPPlayerUIStyle;

#define POST_VIEW_TAG 518
#define EPISODE_VIEW_TAG 778


@interface SPPlayerViewController : UIViewController <SPPlayerControlViewDelegate, UITableViewDelegate ,MetadataTableViewControllerDelegate, SPChildViewControllerDelegate>

/* Adobe Player*/
@property (nonatomic, strong) PTMediaPlayer *player;
/*currentItem Video playable item*/
@property (nonatomic, strong) PTSVideoItem *currentItem ;
/* DataSource Will provide views that are not included in the player view controller .. such as the Episode Selector*/
@property (nonatomic, weak) id <SPPlayerViewControllerViewDataSource> dataSource;   // see SPPlayerViewControllerDelegate.h
@property (nonatomic, weak) id <SPPlayerViewControllerDelegate> delgate;            // see SPPlayerViewControllerDelegate.h


/*  initWithVideoItem: ideoItem andStyle:
 
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

/* Prepares the player for a new playable item .. removes the postplayback view and episode selector view */
-(void) refreshPlayerForNewPlaybackItem:(PTSVideoItem *)item;


/*Concurrency could call this method*/
- (IBAction) closePlayer:(id)sender;
@end


@interface SPPlayerViewController (TEST)

@property (nonatomic, weak) IBOutlet SPPlayerControlView *controlsContainerView;

@end








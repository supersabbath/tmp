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


@interface SPPlayerViewController : UIViewController <SPPlayerControlViewDelegate, UITableViewDelegate ,MetadataTableViewControllerDelegate, SPChildViewControllerDelegate>

/*currentItem Video playable item*/
@property (nonatomic, strong) PTSVideoItem *currentItem ;
/* DataSource Will provide views that are not included in the player view controller .. such as the Episode Selector*/
@property (nonatomic, weak) id <SPPlayerViewControllerViewDataSource> dataSource;   // see SPPlayerViewControllerDelegate.h
@property (nonatomic, weak) id <SPPlayerViewControllerDelegate> delgate;            // see SPPlayerViewControllerDelegate.h


/*Initialization*/
-(instancetype) initWithVideoItem:(PTSVideoItem *) videoItem andStyle:(SPPlayerUIStyle*) uiStyle;

/*Playback Public Actions*/
- (void) playVideo:(PTSVideoItem *)item;
- (void) resize;
- (void) stopVideo;
- (void) pauseVideo;
- (void) resumeVideo;
 
@end


@interface SPPlayerViewController (TEST)

@property (nonatomic, weak) IBOutlet SPPlayerControlView *controlView;

@end


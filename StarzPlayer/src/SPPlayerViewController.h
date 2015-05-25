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

@class PSContainerView;
@class PTSVideoItem;

@interface SPPlayerViewController : UIViewController <SPPlayerControlViewDelegate, UITableViewDelegate ,MetadataTableViewControllerDelegate>

@property (nonatomic, strong) PTSVideoItem *currentItem ;

@property (nonatomic, weak )  IBOutlet PSContainerView *metadataContainerView;

- (void)playVideo:(PTSVideoItem *)item;
- (void)resize;
- (void)stopVideo;
- (void)pauseVideo;
- (void)resumeVideo;


@end


@interface SPPlayerViewController (TEST)

@property (nonatomic, weak) IBOutlet SPPlayerControlView *controlView;

@end
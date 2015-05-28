//
//  MetadataTableViewController.h
//  StarzPlayer
//
//  Created by Fernando Canon on 21/05/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PSDKLibrary/PSDKLibrary.h>
#import "SPChildViewControllerDelegate.h"

@protocol MetadataTableViewControllerDelegate;


@interface MetadataTableViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) id <SPChildViewControllerDelegate> player;
@property (nonatomic, weak) id <MetadataTableViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView * audiosTableView;
@property (weak, nonatomic) IBOutlet UITableView * subtitlesTableView;
@property (nonatomic,strong) UIFont *headerFont;
@property (nonatomic,strong) UIColor *headerTextColor;


-(id) initWithAVPlayerItem:(PTMediaPlayerItem*) item;

-(void) reloadDataForItem:(PTMediaPlayerItem*) item;

-(void) configureBackgroundColorInTables:(UIColor*) color;


@end


@protocol MetadataTableViewControllerDelegate <NSObject>

-(void) metadataTableViewController:(MetadataTableViewController*) controller didSelectCloseCaptionOption:(BOOL)enabled;
@end
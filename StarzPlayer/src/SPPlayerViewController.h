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

@protocol SPPlayerControllerObserverProtocol ;

@interface SPPlayerViewController : UIViewController <SPPlayerControlViewDelegate, UITableViewDelegate ,MetadataTableViewControllerDelegate, SPChildViewControllerDelegate>

/* Adobe Player*/
@property (nonatomic, strong) PTMediaPlayer *player;
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

/*  Observers class */
-(void) addObserverToStarzPlayerRequiredNotifications:(id<SPPlayerControllerObserverProtocol>) observer;

@end


@interface SPPlayerViewController (TEST)

@property (nonatomic, weak) IBOutlet SPPlayerControlView *controlView;

@end

@class PTSVideoItem;
@class SPPlayerNotification;


@protocol SPPlayerControllerObserverProtocol <NSObject>

/**
 * Protocol which defines an interface on which the movie player can notify an implementor
 * of this protocol of certain lifecycle events.
 *
 * Its use can be for various reasons, e.g. implementing analytics reacting to various events
 * in the player's lifetime.
 */

/** Called by `PTMoviePlayerController` right before it starts loading the original resource. */

@optional
- (void)moviePlayerDidLoad:(SPPlayerNotification*) notification ;
/** Called after playback is initiated for the first time, but before buffering is done. */

@optional
- (void)moviePlayerDidStartPlay:(SPPlayerNotification*) notification ;

/** Called when buffering started */
@optional
- (void)moviePlayerDidStartBuffering:(SPPlayerNotification*) notification ;


/** Called after buffering completed */
@optional
- (void)moviePlayerDidFinishBuffering:(SPPlayerNotification*) notification ;

/** Called when Stop event occurs */
@optional
- (void)moviePlayerDidPause:(SPPlayerNotification*) notification ;

/** Called when Resume event occurs */
//- (void)moviePlayerDidResume:(id<SPPlayerControllerObserverProtocol>)moviePlayerController;

/** Called when Stop event occurs */
@optional
- (void)moviePlayerDidStop:(SPPlayerNotification*) notification ;


/** Called when an error occured which needs to be reported to analytics API */
@optional
- (void)moviePlayerErrorDidOccur:(SPPlayerNotification*) playerNotification ;

/** Called when playback is done. Classe that implement this method should Stop Observing when called */

- (void)moviePlayerDidFinishPlayback:(SPPlayerNotification*) notification ;
/** Called right before normal Stop event will occur */
@optional
- (void)moviePlayerWillStop:(SPPlayerNotification*) notification ;


/* Call when the movie is about to finish*/
@optional
- (void)moviePlayerVideoWillFinish:(SPPlayerNotification*) playerNotification ;

@required
-(void) startObservingPlayer:(SPPlayerViewController*) playerViewController;
@required
-(void) stopObservingPlayer;
@end



@interface SPPlayerNotification : NSNotification


/*
 Notfication Types .. Objects registered to these notifications must implement SPPlayerControllerObserverProtocol
 */

FOUNDATION_EXPORT NSString *const SPPlayerChangeContentNotification;
FOUNDATION_EXPORT NSString *const SPPlayerDidLoadNotification;
FOUNDATION_EXPORT NSString *const SPPlayerStatusPlayingNotification;

FOUNDATION_EXPORT NSString *const SPPlayerPlaybackWillFinish;
FOUNDATION_EXPORT NSString *const SPPlayerStatusPausedNotification;
FOUNDATION_EXPORT NSString *const SPPlayerStatusStoppedNotification;
FOUNDATION_EXPORT NSString *const SPPlayerStatusCompletedNotification;
FOUNDATION_EXPORT NSString *const SPPPlayerStatusErrorNotification;
FOUNDATION_EXPORT NSString *const SPPlayerWillStopNotification;

@property(atomic, retain) id object;

+(id) notificationForplayer:(SPPlayerViewController*)player Item:(PTSVideoItem*)currentItem andIdentifier:(NSString*) identfier;
/*
 This expects to receive a dictionary with error an current item
 */
+(id) notificationForplayer:(SPPlayerViewController*)player withUserInfo:(NSDictionary*) userInf andIdentifier:(NSString*) identfier ;

-(instancetype)initWithObject:(id) player userInfo:(NSDictionary*) userdic andIdentifier:(NSString*) identifier;

-(NSString*) name;

-(NSDictionary*) userInfo;

//-(id) object;

-(PTSVideoItem*) currentVideo;
@end




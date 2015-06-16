//
//  SPPlayerControllerObserverProtocol.h
//  StarzPlayer
//
//  Created by Fernando Canon on 08/06/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

 
@class SPPlayerNotification;
@class SPPlayerViewController;

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


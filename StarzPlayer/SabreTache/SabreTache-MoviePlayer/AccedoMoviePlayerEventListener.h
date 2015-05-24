//
//  AccedoMoviePlayerEventListener.h
//  Appcelerator-MoviePlayer
//
//  Created by Tüz Csaba on 17/02/15.
//  Copyright (c) 2015 Accedo Broadband AB. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AccedoMoviePlayerAttachable.h"
#import "MPExtendedMediaPlayback.h"
/**
 * Protocol which defines an interface on which the movie player can notify an implementor
 * of this protocol of certain lifecycle events.
 *
 * Its use can be for various reasons, e.g. implementing analytics reacting to various events
 * in the player's lifetime.
 */
@protocol AccedoMoviePlayerEventListener <NSObject, AccedoMoviePlayerAttachable>

/** Called by `PTMoviePlayerController` right before it starts loading the original resource. */
- (void)moviePlayerDidLoad:(id<MPExtendedMediaPlayback>)moviePlayerController;

/** Called after playback is initiated for the first time, but before buffering is done. */
- (void)moviePlayerDidStartPlay:(id<MPExtendedMediaPlayback>)moviePlayerController;

/** Called when buffering started */
- (void)moviePlayerDidStartBuffering:(id<MPExtendedMediaPlayback>)moviePlayerController;

/** Called after buffering completed */
- (void)moviePlayerDidFinishBuffering:(id<MPExtendedMediaPlayback>)moviePlayerController;

/** Called when Stop event occurs */
- (void)moviePlayerDidPause:(id<MPExtendedMediaPlayback>)moviePlayerController;

/** Called when Resume event occurs */
- (void)moviePlayerDidResume:(id<MPExtendedMediaPlayback>)moviePlayerController;

/** Called when Stop event occurs */
- (void)moviePlayerDidStop:(id<MPExtendedMediaPlayback>)moviePlayerController;

/** Called when an error occured which needs to be reported to analytics API */
- (void)moviePlayer:(id<MPExtendedMediaPlayback>)moviePlayerController didErrorOccur:(NSError *)err;

@optional

/** Called right before normal Stop event will occur */
- (void)moviePlayerWillStop:(id<MPExtendedMediaPlayback>)moviePlayerController;

@end

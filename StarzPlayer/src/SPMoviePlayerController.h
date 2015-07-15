//
//  SPMoviePlayerController.h
//  StarzPlayer
//   This class is a wrapper for Adobe's player and drm manager
//  Created by Fernando Canon on 24/06/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PSDKLibrary/PSDKLibrary.h>

@protocol SPMoviewPlayerControllerObserver;
@class PTSVideoItem;

typedef void(^ PlayerInitializationCompletion)(UIView*);

@interface SPMoviePlayerController : NSObject

/* Adobe Player*/
@property (nonatomic, strong) PTMediaPlayer *player;



/* Adobe Player properties*/
@property (nonatomic, weak, getter=qoServiceInfo) PTPlaybackInformation *playbackInformation;
@property (readonly, nonatomic) CMTime currentTime;
@property  (readonly, nonatomic) NSUInteger bitrate;
@property (assign, nonatomic) float volume;
@property (readonly, nonatomic) BOOL isLive;

/*Playback Public Actions*/
- (void) playCurrentVideo:(PlayerInitializationCompletion)onPlayerViewReadyBlock;  // video passed on initialization method
- (void) playVideo:(PTSVideoItem *)item withCompletionBlock:(PlayerInitializationCompletion)onPlayerViewReadyBlock; // Resume playback or change the episode case
- (void) stopVideo;
- (void) pauseVideo;
- (void) resumeVideo;
- (void) releasePlayer;  // call to stop observing a clean adobes player status and instance 
- (void) showSubtitlesForLangKey:(NSString*)langKey;

/*Seeking*/
- (void) seekToTime:(CMTime)time completionHandler:(void (^)(BOOL finished))completionHandler;
- (void) seekToTime:(CMTime)time;

/* Mandatory Initializer*/
- (id) initWithMediaPlayerItem:(PTSVideoItem *) mediaItem andViewController:(id<SPMoviewPlayerControllerObserver>) observerViewController;

@end


/*
    The observer of the notifications post by adobes player must implement this procotol .. In Starz app
    is implemented by SPPlayerViewController
 */
@protocol SPMoviewPlayerControllerObserver <NSObject>

- (void) onMediaPlayerStatusChange:(NSNotification *)notification;
- (void) onMediaPlayerTimeChange:(NSNotification *)notification;
- (void) onMediaPlayerSeekCompleted:(NSNotification *)notification;
- (void) onMediaPlayerItemPlayCompleted:(NSNotification *) notification;
- (void) onMediaPlayerItemPlayStarted:(NSNotification *)notification;
- (void) onMediaPlayerNotificationItemEntry:(NSNotification *)nsnotification;
- (void) onMediaPlayerMediaSelectionOptionsAvailableNotification:(NSNotification *)nsnotification;
- (void) logDRMError:(NSString*)str :(DRMError*)error;
@end
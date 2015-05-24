//
//  AccedoMoviePlayer.h
//  Filmnet
//
//  Created by Csaba Tűz on 2014.04.02..
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SabreTache-Core/Macros.h>


#import "AccedoMoviePlayerEventListener.h"
#import "AccedoMoviePlayerUI.h"
#import "AccedoMoviePlayObject.h"
#import "DRMProvider.h"
#import "MPExtendedMediaPlayback.h"
#import "SubtitleProvider.h"

#if TARGET_IPHONE_SIMULATOR
extern CGFloat dummy_system_volume;
#endif

extern NSString * const ACCEDO_MOVIE_PLAYER_PRESENT_SUBTITLE_NOTIFICATION;
extern NSString * const ACCEDO_MOVIE_PLAYER_PRESENT_SUBTITLE_KEY;
extern NSString * const ACCEDO_MOVIE_PLAYER_SWICH_SCREEN_NOTIFICATION;
extern NSString * const ACCEDO_MOVIE_PLAYER_REMOTE_SUBTITLE_CHANGED_NOTIFICATION;
extern NSString * const ACCEDO_MOVIE_PLAYER_REMOTE_AUDIO_TRACK_LIST_NOTIFICATION;
extern NSString * const ACCEDO_MOVIE_PLAYER_REMOTE_AUDIO_TRACK_CHANGED_NOTIFICATION;
extern NSString * const ACCEDO_MOVIE_PLAYER_REMOTE_AUDIO_TRACK_KEY;

FOUNDATION_EXPORT NSString *const ACCEDO_MOVIE_PLAYER_FORCE_CLOSE;


typedef NS_ENUM(NSInteger, AccedoMoviePlaybackMode)
{
    AccedoMoviePlaybackModeLocal,
    AccedoMoviePlaybackModeRemote
};

typedef NS_ENUM(NSInteger, AccedoMoviePlaybackScreen)
{
    AccedoMoviePlaybackScreenDevice,
    AccedoMoviePlaybackScreenExternal
};

@protocol AccedoMovieRemotePlayer

- (void)setRemoteMedia:(id)remoteMedia;

@end

/**! Glue class to provide a DRM and Presentation independent interface for its user.
 *   It provides the necessary protocols and various helpers to
 */
@interface AccedoMoviePlayer : UIViewController<SubtitleProviderDelegate, MPExtendedMediaPlayback, AccedoMovieRemotePlayer>

@property (assign, nonatomic) AccedoMoviePlaybackMode mode;
@property (assign, nonatomic) AccedoMoviePlaybackScreen screen;

@property (retain, nonatomic) MPMoviePlayerController<MPExtendedMediaPlayback> * mediaPlayer;
@property (retain, nonatomic) id<MPExtendedMediaPlayback, AccedoMovieRemotePlayer> remotePlayer;

@property (retain, nonatomic) id<DRMProvider> drmProvider;
@property (retain, nonatomic) id<SubtitleProvider> subtitleProvider;

@property (retain, nonatomic) id<AccedoPlayerErrorRenderer> errorRenderer;

@property (retain, nonatomic) UIView * remoteBackgroundView;
@property (retain, nonatomic) UIView<AccedoMoviePlayerUI> * userInterface;
@property (retain, nonatomic) UIView<AccedoMoviePlayerUI> * remoteInterface;

@property (weak, nonatomic, readonly) UIView * presentingView;

@property (retain, nonatomic) AccedoMoviePlayObject * currentPlayObject;

@property (retain, nonatomic) NSDictionary* generalAppgridSettings;

@property (assign, nonatomic) BOOL shouldKeepPresentedOnStop;

+ (AccedoMoviePlayer *)instance;

- (id<MPExtendedMediaPlayback>)currentPlayer;

- (void)selectSubtitle:(SubtitleRef *)item;

- (void)playUrl:(NSURL *)mediaUrl playObjet:(AccedoMoviePlayObject *)playObject;

- (void)detachAnimated:(BOOL)animated;

- (void)attachToViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (BOOL)isPresented;

- (void)mute;

- (void)hidePlayer;

- (void)setGeneralAppgridConfig:(NSDictionary *)generalConfig;

@end

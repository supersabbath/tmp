//
//  DXMoviePlayerController.m
//  CMore
//
//  Created by Csaba Tűz on 2014.02.04..
//
//

#import "PTMoviePlayerController.h"

#import <SabreTache-Core/Logging.h>

#define TIMER_INTERVALS 0.2

@interface PTMoviePlayerController()
{
    BOOL wasPlayingBeforeSuspend;
}

@property (retain, nonatomic) PTQoSProvider * qosProvider;

@end

@implementation PTMoviePlayerController

- (void)setVolume:(float)newVolume
{
    [self.ptPlayer setVolume:newVolume];
}

- (float)volume
{
    return self.ptPlayer.volume;
}

- (id)remoteMedia
{
    // Do not support remote media
    return nil;
}

- (void)setRemoteMedia:(id)remoteMedia
{
    // Do not support remote media
}

- (void)selectSubtitle:(SubtitleRef *)item
{
    // NOP
}

- (void)selectAudioTrack:(NSObject *)track
{
    if ([track isKindOfClass:[PTMediaSelectionOption class]])
    {
        [self.ptPlayer.currentItem selectAudioOption:(PTMediaSelectionOption *)track];
    }
}

- (void)didEnterForeground
{
    // NOP
}

- (NSInteger)bitrate
{
    return self.qosProvider.playbackInformation.indicatedBitrate;
}

- (BOOL)isLive
{
    return self.ptPlayer.currentItem.isLive;
}

- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime {
    [self.ptPlayer seekToTime:CMTimeMakeWithSeconds(currentPlaybackTime, 10)];
}

- (NSTimeInterval)currentPlaybackTime {
    if (nil != self.ptPlayer)
    {
        return CMTimeGetSeconds(self.ptPlayer.currentItem.currentTime);
    }
    return -1;
}

- (void)setCurrentPlaybackRate:(float)currentPlaybackRate {
}

- (NSTimeInterval)duration {
    if (self.ptPlayer.currentItem)
    {
        return CMTimeGetSeconds(self.ptPlayer.currentItem.duration);
    }
    return 0;
}

- (float)currentPlaybackRate {
    return self.ptPlayer.rate;
}

- (BOOL)isPreparedToPlay {
    return self.ptPlayer.status >= PTMediaPlayerStatusReady;
}

- (void)initializePTPlayerIfNeeded:(PTMediaPlayerItem *)item {
    if (!self.ptPlayer)
    {
#ifdef IS_DEBUG_MODE
        [PTMediaPlayer enableDebugLog:YES];
#endif
        
        [PTSDKConfig setSubscribedTags:[NSArray arrayWithObject:@"#EXT-OATCLS-SCTE35"]];

        self.ptPlayer = [PTMediaPlayer playerWithMediaPlayerItem:item];

        [self addObservers];

        self.ptPlayer.currentTimeUpdateInterval = 1000;
        self.ptPlayer.closedCaptionDisplayEnabled = YES;
        self.ptPlayer.videoGravity = PTMediaPlayerVideoGravityResizeAspect;

        self.qosProvider = [[PTQoSProvider alloc] initWithPlayer:self.ptPlayer];
        
        _view = self.ptPlayer.view;


        [self play];
    }
}

- (void)addObservers
{
    if (self.ptPlayer)
    {
        /** Buffering events */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMediaPlayerBufferingStarted:) name:PTMediaPlayerBufferingStartedNotification object:self.ptPlayer];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMediaPlayerBufferingCompleted:) name:PTMediaPlayerBufferingCompletedNotification object:self.ptPlayer];

        /** Play event */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMediaPlayerItemPlayStarted:) name:PTMediaPlayerPlayStartedNotification object:self.ptPlayer];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMediaPlayerStatusChange:) name:PTMediaPlayerStatusNotification object:self.ptPlayer];
        /*
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMediaPlayerTimeChange:) name:PTMediaPlayerTimeChangeNotification object:self.ptPlayer];
         */

        /*
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMediaPlayerItemPlayCompleted:) name:PTMediaPlayerPlayCompletedNotification object:self.ptPlayer];
         */
        /*
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMediaPlayerAdBreakStarted:) name:PTMediaPlayerAdBreakStartedNotification object:self.ptPlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMediaPlayerAdBreakCompleted:) name:PTMediaPlayerAdBreakCompletedNotification object:self.ptPlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMediaPlayerAdPlayStarted:) name:PTMediaPlayerAdStartedNotification object:self.ptPlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMediaPlayerAdPlayProgress:) name:PTMediaPlayerAdProgressNotification object:self.ptPlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMediaPlayerAdPlayCompleted:) name:PTMediaPlayerAdCompletedNotification object:self.ptPlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMediaPlayerAdClick:) name:PTMediaPlayerAdClickNotification object:self.ptPlayer];
         */
    }
}

- (void)onMediaPlayerBufferingStarted:(NSNotificationCenter *)notification
{

    for (id<AccedoMoviePlayerEventListener> listener in self.eventListeners)
    {
        DLog(@"[PTMoviePlayerController] Analytics DidStartBuffering event");
        [listener moviePlayerDidStartBuffering:self];
    }
    [self sendMPNotiticationsForPlaybackState];
}

- (void)onMediaPlayerBufferingCompleted:(NSNotificationCenter *)notification
{
    for (id<AccedoMoviePlayerEventListener> listener in self.eventListeners)
    {
        DLog(@"[PTMoviePlayerController] Analytics DidFinishBuffering event");
        [listener moviePlayerDidFinishBuffering:self];
    }
    [self sendMPNotiticationsForPlaybackState];
}

- (void)onMediaPlayerItemPlayStarted:(NSNotification *)notification
{
    [self sendMPNotiticationsForPlaybackState];
}

- (void)onMediaPlayerTimeChange:(NSNotification *)notification
{

}

- (void)onMediaPlayerStatusChange:(NSNotification *)notification
{
    //the status is also available as self.player.status
    NSDictionary* userInfo = [notification userInfo];
    PTMediaPlayerStatus status = [(NSNumber*)[userInfo objectForKey:PTMediaPlayerStatusKey] intValue];
    PTMediaError *error;

    switch(status)
    {
        case PTMediaPlayerStatusCreated:
            break;
        case PTMediaPlayerStatusInitializing:
            for (id<AccedoMoviePlayerEventListener> listener in self.eventListeners)
            {
                DLog(@"[PTMoviePlayerController] Analytics DidLoad event");
                [listener moviePlayerDidLoad:self];
            }
            [self onMediaPlayerBufferingStarted:nil];
            break;
        case PTMediaPlayerStatusInitialized:
            for (id<AccedoMoviePlayerEventListener> listener in self.eventListeners)
            {
                [listener moviePlayerDidStartPlay:self];
            }
            break;
        case PTMediaPlayerStatusReady:
            [self play];
            [self onMediaPlayerBufferingCompleted:nil];
            break;
        case PTMediaPlayerStatusPlaying:
            for (id<AccedoMoviePlayerEventListener> listener in self.eventListeners)
            {
                DLog(@"[PTMoviePlayerController] Analytics DidResume event");
                [listener moviePlayerDidResume:self];
            }
            _contentURL = self.ptPlayer.currentItem.url;
            break;
        case PTMediaPlayerStatusPaused:
            for (id<AccedoMoviePlayerEventListener> listener in self.eventListeners)
            {
                DLog(@"[PTMoviePlayerController] Analytics DidPause event");
                [listener moviePlayerDidPause:self];
            }
            break;
        case PTMediaPlayerStatusStopped:
            for (id<AccedoMoviePlayerEventListener> listener in self.eventListeners)
            {
                [listener moviePlayerDidStop:self];
            }
            break;
        case PTMediaPlayerStatusCompleted:
            break;
        case PTMediaPlayerStatusError:
            error = self.ptPlayer.error;

            DLog(@"ViewController:: Error - media player error code[%ld], description[%@], internalError[%@].", (long)error.code, error.description, error.metadata[@"INTERNAL_ERRROR"]);

            [[PTErrorProcessor instance] processMediaPlayerError:error];
            break;
    }

    [self sendMPNotiticationsForPlaybackState];
}

- (MPMoviePlaybackState)playbackState
{
    PTMediaPlayerStatus s = self.ptPlayer.status;

    switch (s)
    {
        case PTMediaPlayerStatusCreated:
            return MPMoviePlaybackStateSeekingForward;
            break;
        case PTMediaPlayerStatusInitializing:
            return MPMoviePlaybackStateSeekingForward;
            break;
        case PTMediaPlayerStatusInitialized:
            return MPMoviePlaybackStateSeekingForward;
            break;
        case PTMediaPlayerStatusPaused:
            return MPMoviePlaybackStatePaused;
            break;
        case PTMediaPlayerStatusPlaying:
            return MPMoviePlaybackStatePlaying;
            break;
        case PTMediaPlayerStatusStopped:
            return MPMoviePlaybackStateStopped;
            break;
        case PTMediaPlayerStatusError:
            return MPMoviePlaybackStateInterrupted;
            break;
    }

    return MPMoviePlaybackStateInterrupted;
}

- (MPMovieLoadState)loadState
{
    PTPlaybackInformation * info = [self.qosProvider playbackInformation];
    BOOL playthroughOK = [info playbackLikelyToKeepUp];
    BOOL playable = [info playbackLikelyToKeepUp] || self.playbackState == MPMoviePlaybackStatePlaying;
    BOOL stalled = [info playbackBufferEmpty];

    if (stalled)
    {
        return MPMovieLoadStateStalled;
    }
    else if (playthroughOK || playable)
    {
        return MPMovieLoadStatePlayable | MPMovieLoadStatePlaythroughOK;
    }
    else
    {
        return MPMovieLoadStateUnknown;
    }
}

- (void)sendMPNotiticationsForPlaybackState
{

    [[NSNotificationCenter defaultCenter] postNotificationName:MPMoviePlayerLoadStateDidChangeNotification object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:MPMoviePlayerPlaybackStateDidChangeNotification object:self];

    if (self.playbackState == MPMoviePlaybackStateInterrupted || self.playbackState == MPMoviePlaybackStateStopped)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:MPMoviePlayerPlaybackDidFinishNotification object:self];
    }
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithMediaPlayerItem:(PTMediaPlayerItem *)mediaPlayerItem eventListeners:(NSArray *)eventListeners errorRenderer:(id<AccedoPlayerErrorRenderer>)errorRenderer
{
    self = [super init];
    if (self) {

        self.eventListeners = eventListeners;
        self.errorRenderer = errorRenderer;

        [self initializePTPlayerIfNeeded:mediaPlayerItem];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:NULL];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:NULL];
    }
    return self;
}

- (void)dealloc
{
    [self removeObservers];
}

- (void)beginSeekingBackward {

}

- (void)beginSeekingForward {

}

- (void)endSeeking {

}

- (NSTimeInterval)playableDuration
{
    return [self.qosProvider.playbackInformation segmentsDownloadedDuration];
}

- (void)prepareToPlay {
    [self.ptPlayer prepareToPlay];
}

- (void)play {
    [self.ptPlayer play];
}

- (void)pause {
    [self.ptPlayer pause];
}

- (void)stop {
    [self.ptPlayer stop];
}

- (void)showAllert:(NSString *)pMessage
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                    message:pMessage
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    alert = nil;
}

- (void)setFullscreen:(BOOL)fullscreen animated:(BOOL)animated {
    WLog(@"Fullscreen mode not supported with this implementation.");
}

- (void)stopDueToError:(id)sender
{
    [self stop];
}

- (NSTimeInterval)initialPlaybackTime {
    return 0;
}

- (void)setInitialPlaybackTime:(NSTimeInterval)initialPlaybackTime {
}

- (void)setAllowsAirPlay:(BOOL)allowsAirPlay {
    self.ptPlayer.allowsAirPlayVideo = allowsAirPlay;
}

- (BOOL)allowsAirPlay {
    return self.ptPlayer.allowsAirPlayVideo;
}

- (void) applicationWillResignActive {
    wasPlayingBeforeSuspend = self.ptPlayer.status == PTMediaPlayerStatusPlaying;
    [self.ptPlayer pause];
}

- (void) applicationDidBecomeActive {
    if (wasPlayingBeforeSuspend)
    {
        [self.ptPlayer play];
    }
}

- (void)addEventListener:(id<AccedoMoviePlayerEventListener>)listener
{
}

- (void)removeEventListener:(id<AccedoMoviePlayerEventListener>)listener
{
}

@end

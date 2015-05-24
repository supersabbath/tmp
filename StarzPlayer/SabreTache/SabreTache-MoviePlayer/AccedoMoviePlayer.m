//
//  AccedoMoviePlayer.m
//  Filmnet
//
//  Created by Csaba Tűz on 2014.04.02..
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>

#import <SabreTache-Core/UIView+RemoveWithConstraints.h>
#import <SabreTache-Core/Logging.h>

#import "AccedoMoviePlayer.h"

#import "ExternalDisplayManager.h"
#import "ExternalDisplayViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import "MBProgressHUD.h"
#import "UIColor+PSColors.h"

#if TARGET_IPHONE_SIMULATOR
CGFloat dummy_system_volume;
#endif

NSString * const ACCEDO_MOVIE_PLAYER_PRESENT_SUBTITLE_NOTIFICATION = @"AccedoMoviePlayerPresentSubtitlesAndAudioNotification";
NSString * const ACCEDO_MOVIE_PLAYER_PRESENT_SUBTITLE_KEY = @"AccedoMoviePlayerPresentSubtitlesAndAudioNotificationKey";
NSString * const ACCEDO_MOVIE_PLAYER_SWICH_SCREEN_NOTIFICATION = @"AccedoMoviePlayerSwichScreenSize";
NSString * const ACCEDO_MOVIE_PLAYER_REMOTE_SUBTITLE_CHANGED_NOTIFICATION = @"AccedoMoviePlayerRemoteSubtitleDidChange";
NSString * const ACCEDO_MOVIE_PLAYER_REMOTE_AUDIO_TRACK_LIST_NOTIFICATION = @"AccedoMoviePlayerRemoteAudioTrackListReceied";
NSString * const ACCEDO_MOVIE_PLAYER_REMOTE_AUDIO_TRACK_CHANGED_NOTIFICATION = @"AccedoMoviePlayerRemoteAudioTrackChanged";
NSString * const ACCEDO_MOVIE_PLAYER_REMOTE_AUDIO_TRACK_KEY = @"AccedoMoviePlayerRemoteAudioTrackKey";

NSString * const ACCEDO_MOVIE_PLAYER_FORCE_CLOSE = @"ShitMoviePlayerForCloseNotification";

@interface AccedoMoviePlayer()
{
    BOOL playbackStateChanged;
    double subtitleExpires;

    AccedoMoviePlaybackMode _mode;

    NSTimeInterval initialPosition;

    NSTimeInterval requestedPosition;
    NSTimeInterval previousPosition;

    BOOL finalReportDone;
}

@property (retain, nonatomic) NSDate * timeOfLastReport;
@property (retain, nonatomic) NSDate * timeOfLastKeepAlive;

@property (weak, nonatomic, readwrite) UIView * presentingView;
@property (retain, nonatomic) UIImageView * backgroundImage;

@property (retain, nonatomic) NSURL * lastPlayURL;
@property (assign, nonatomic) NSTimeInterval lastKnownPlaybackPosition;

@property (assign, nonatomic) BOOL normalStop;

//@property (retain) NSTimer *positionTimer;
@property (retain) CADisplayLink * displayLink;

@property (retain, nonatomic) NSMutableArray * eventListeners;

@property (retain, nonatomic) MBProgressHUD *spinner;
@end

@implementation AccedoMoviePlayer

+ (AccedoMoviePlayer *)instance
{
    static dispatch_once_t accedoMoviePlayer_once;
    static AccedoMoviePlayer * accedoMoviePlayer_instance;
    dispatch_once(&accedoMoviePlayer_once, ^{
        accedoMoviePlayer_instance = [[AccedoMoviePlayer alloc] init];
    });
    return accedoMoviePlayer_instance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.mode = AccedoMoviePlaybackModeLocal;
        initialPosition = -1;
        previousPosition = -1;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detachAnimated:) name:ACCEDO_MOVIE_PLAYER_FORCE_CLOSE object:nil];
    }
    return self;
}

- (void)restartDisplayLink
{
    if (self.displayLink)
    {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
    self.displayLink.frameInterval = 10;
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop]
                           forMode:NSDefaultRunLoopMode];
}

- (void)dealloc
{
    [self clearMediaPlayer];

    [self setEventListeners:nil];
    
    [self.displayLink invalidate];
    self.displayLink = nil;

    [self stopListeningToAudioVolume];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - MPExtendedMediaPlayback methods

- (AccedoMoviePlaybackMode)mode
{
    return _mode;
}

- (void)setMode:(AccedoMoviePlaybackMode)mode
{
    if (mode == AccedoMoviePlaybackModeRemote && self.remotePlayer == nil)
    {
        NSAssert(NO, @"Remote player must be set before switching to remote mode");
    }
    AccedoMoviePlaybackMode oldMode = _mode;
    _mode = mode;

    [self handleStateTransitionForOldMode:oldMode newMode:mode];
}

- (void)setScreen:(AccedoMoviePlaybackScreen)screen
{
    if (screen == AccedoMoviePlaybackScreenExternal && ![ExternalDisplayManager instance].isConnected)
    {
        NSAssert(NO, @"Cannot switch to external screen mode if display is not connected");
    }
    if (![[self.generalAppgridSettings valueForKey:@"allowsExternalScreen"] boolValue] && screen == AccedoMoviePlaybackScreenExternal)
    {
        screen = AccedoMoviePlaybackScreenDevice;
    }

    _screen = screen;
    
    [self attachToAccedoPlayerView];
    self.remoteBackgroundView.hidden = self.mode == AccedoMoviePlaybackModeLocal && screen == AccedoMoviePlaybackScreenDevice;
    if (!self.remoteBackgroundView.hidden)
    {

    }
}

- (void)handleStateTransitionForOldMode:(AccedoMoviePlaybackMode)oldMode newMode:(AccedoMoviePlaybackMode)mode
{

    self.remoteBackgroundView.hidden = mode == AccedoMoviePlaybackModeLocal && self.screen == AccedoMoviePlaybackScreenDevice;
    if (oldMode == AccedoMoviePlaybackModeLocal && mode == AccedoMoviePlaybackModeRemote)
    {

        if (self.remotePlayer)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(handleMPMoviePlayerPlaybackDidFinishNotification:)
                                                         name:MPMoviePlayerPlaybackDidFinishNotification
                                                       object:self.remotePlayer];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(handleMPMoviePlayerPlaybackStateDidChangeNotification:)
                                                         name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                       object:self.remotePlayer];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(handleMPMoviePlayerLoadStateDidChangeNotification:)
                                                         name:MPMoviePlayerLoadStateDidChangeNotification
                                                       object:self.remotePlayer];
        }

        if (self.mediaPlayer)
        {
            [self clearMediaPlayer];
        }

        [self stopListeningToAudioVolume];

        [self didEnterForeground];
    }
    else if (oldMode == AccedoMoviePlaybackModeRemote && mode == AccedoMoviePlaybackModeLocal)
    {
        [self ensureCleanMediaPlayer];

        [self startListeningToAudioVolume];

        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMoviePlayerPlaybackDidFinishNotification
                                                      object:self.remotePlayer];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                      object:self.remotePlayer];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMoviePlayerDidExitFullscreenNotification
                                                      object:self.remotePlayer];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMoviePlayerLoadStateDidChangeNotification
                                                      object:self.remotePlayer];
        //[self.remotePlayer stop];

        /*
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMPMoviePlayerPlaybackDidFinishNotification:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:self.mediaPlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMPMoviePlayerPlaybackStateDidChangeNotification:)
                                                     name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                   object:self.mediaPlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMPMoviePlayerLoadStateDidChangeNotification:)
                                                     name:MPMoviePlayerLoadStateDidChangeNotification
                                                   object:self.mediaPlayer];

        self.mediaPlayer.view.hidden = NO;
        self.remoteBackgroundView.hidden = YES;
        self.mediaPlayer.currentPlaybackRate = self.remotePlayer.currentPlaybackRate;
        self.mediaPlayer.currentPlaybackTime = self.remotePlayer.currentPlaybackTime;
        MPMoviePlaybackState remoteState = [self.remotePlayer playbackState];
        if (remoteState == MPMoviePlaybackStatePlaying)
        {
            [self.mediaPlayer play];
        }
        else if (remoteState == MPMoviePlaybackStatePaused)
        {
            [self.mediaPlayer pause];
        }
        [self.remotePlayer stop];
         */
    }
}

- (id<MPExtendedMediaPlayback>)currentPlayer
{
    switch([self mode])
    {
        case AccedoMoviePlaybackModeLocal:
            return self.mediaPlayer;
            break;
        case AccedoMoviePlaybackModeRemote:
            return self.remotePlayer;
            break;
    }
}

- (void)prepareToPlay
{
    [[self currentPlayer] prepareToPlay];
}

- (BOOL)isPreparedToPlay
{
    return [[self currentPlayer] isPreparedToPlay];
}

- (void)play
{
    [[self currentPlayer] play];
}

- (void)pause
{
    [[self currentPlayer] pause];
}

- (void)stop
{
    for (id<AccedoMoviePlayerEventListener> listener in self.eventListeners)
    {
        if ([listener respondsToSelector:@selector(moviePlayerWillStop:)])
        {
            [listener moviePlayerWillStop:self];
        }
    }
    [[self currentPlayer] stop];
}

- (BOOL)isLive
{
    return [[self currentPlayer] isLive];
}

- (NSInteger)bitrate
{
    return [[self currentPlayer] bitrate];
}

- (float)volume
{
    if (self.mode == AccedoMoviePlaybackModeLocal)
    {
        return [self currentVolume];
    }
    else
    {
        return self.remotePlayer.volume;
    }
}

- (void)setVolume:(float)newVolume
{
    if (self.mode == AccedoMoviePlaybackModeLocal)
    {
#if TARGET_IPHONE_SIMULATOR
        dummy_system_volume = newVolume;
#else
        CGFloat oldVolume = [[MPMusicPlayerController applicationMusicPlayer] volume];

        if( fabsf(newVolume - oldVolume) > 0.01 || newVolume == 0 || newVolume == 1  )
        {
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:newVolume];
        }
#endif
    }
    else
    {
       [[self remotePlayer] setVolume:newVolume];
    }

}

- (void)mute
{
    static CGFloat volumeBackup;
	CGFloat oldVolume = [self currentVolume];
    if (oldVolume>0){
        volumeBackup = oldVolume;
        [self setVolume:0.0f];
    }else{
        [[MPMusicPlayerController applicationMusicPlayer] setVolume:volumeBackup];
    }
}

- (MPMoviePlaybackState)playbackState
{
    return [[self currentPlayer] playbackState];
}

- (MPMovieLoadState)loadState
{
    return [[self currentPlayer] loadState];
}

- (NSTimeInterval)duration
{
    return [[self currentPlayer] duration];
}

- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime
{
    previousPosition = [self currentPlaybackTime];
    [[self currentPlayer] setCurrentPlaybackTime:currentPlaybackTime];
}

- (NSTimeInterval)currentPlaybackTime
{
    return [[self currentPlayer] currentPlaybackTime];
}

- (void)setCurrentPlaybackRate:(float)currentPlaybackRate
{
    [[self currentPlayer] setCurrentPlaybackRate:currentPlaybackRate];
}

- (float)currentPlaybackRate
{
    return [[self currentPlayer] currentPlaybackRate];
}

- (void)beginSeekingForward
{
    [[self currentPlayer] beginSeekingForward];
}

- (void)beginSeekingBackward
{
    [[self currentPlayer] beginSeekingBackward];
}

- (void)endSeeking
{
    [[self currentPlayer] endSeeking];
}

#pragma mark - Subtitle handling

- (void)setSubtitleProvider:(id<SubtitleProvider>)subtitleProvider
{
    _subtitleProvider = subtitleProvider;

    [subtitleProvider setDelegate:self];
}

- (void)setEventListeners:(NSArray *)eventListeners
{
    for (id<AccedoMoviePlayerEventListener> listener in _eventListeners)
    {
        [listener detachFromMoviePlayer:self];
    }
    _eventListeners = [eventListeners mutableCopy];

    for (id<AccedoMoviePlayerEventListener> listener in _eventListeners)
    {
        [listener attachToMoviePlayer:self];
    }
}

- (void)addEventListener:(id<AccedoMoviePlayerEventListener>)listener
{
    if (![self.eventListeners containsObject:listener])
    {
        [self.eventListeners addObject:listener];
      //  [listener attachToMoviePlayer:self];
    }
}

- (void)removeEventListener:(id<AccedoMoviePlayerEventListener>)listener
{
    [listener detachFromMoviePlayer:self];
    [self.eventListeners removeObject:listener];
}

- (void)setErrorRenderer:(id<AccedoPlayerErrorRenderer>)errorRenderer
{
    _errorRenderer = errorRenderer;
}

- (void)subtitleProvider:(id<SubtitleProvider>)subtitleProvider didChangeSubtitle:(SubtitleRef *)newSubtitle
{
    [self updateSubtitle:YES];
}

- (void)updateSubtitle:(BOOL)force
{
    if (!force && [[NSDate date] timeIntervalSinceReferenceDate] < subtitleExpires)
    {
        return;
    }
    SubtitleEntry * item = [self.subtitleProvider subtitleForTime:self.mediaPlayer.currentPlaybackTime];
    [self.userInterface updateUIForSubtitle:item.sub];

    if (self.screen == AccedoMoviePlaybackScreenExternal)
    {
        ExternalDisplayViewController * vc = [ExternalDisplayViewController instance];
        [vc updateUIForSubtitle:item.sub];
    }

    if ([self currentPlayer].playbackState == MPMoviePlaybackStatePlaying)
    {
        if (item.timeToNext > 0)
        {
            TLog(@"Scheduling next subtitle update for: %f", item.timeToNext);
        }
        if (item.timeToNext < 0)
        {
            return;
        }
        else
        {
            subtitleExpires = [[NSDate dateWithTimeIntervalSinceNow:item.timeToNext] timeIntervalSinceReferenceDate];
        }
    }
}

- (void)selectSubtitle:(SubtitleRef *)item
{
    [self.subtitleProvider selectSubtitle:item];
    if (self.mode == AccedoMoviePlaybackModeRemote)
    {
        [self.remotePlayer selectSubtitle:item];
    }
}
- (void)selectAudioTrack:(NSObject *)track
{

    if (self.mode == AccedoMoviePlaybackModeRemote)
    {
        [self.remotePlayer selectAudioTrack:track];
    }
}

- (void)updateCurrentPlaybackTime:(id)sender {
    if (isnan(previousPosition)) previousPosition = -1;
    if (previousPosition != -1)
    {
        if (ABS([[self currentPlayer] currentPlaybackTime] - previousPosition) > 1.0)
        {
            previousPosition = -1;
        }
        else
        {
            return;
        }
    }

    if ([self currentPlayer].playbackState == MPMoviePlaybackStatePlaying)
    {
        double duration = self.mediaPlayer.playableDuration;
        if (isnan(duration) || duration == 0.0)
        {
            duration = [self.currentPlayObject duration];
        }
        
        
        [self.userInterface updateUIForPlaybackPosition:[self currentPlayer].currentPlaybackTime andplayableDuration:duration initialPlaybackTime:[self.currentPlayObject.initialPosition doubleValue]];
    }
}

#pragma mark - MPMoviePlayerController notifications

- (void)handleMPMoviePlayerPlaybackDidFinishNotification:(NSNotification *)n
{
    ILog(@"Movie playback finished.");
    if ([n isKindOfClass:[NSNotification class]])
    {
        int reason = [n.userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
        ILog(@"Finish reason: %d", reason);

        if (reason == MPMovieFinishReasonPlaybackEnded || reason == MPMovieFinishReasonUserExited)
        {
            [self clearMediaPlayer];

            if (!self.shouldKeepPresentedOnStop)
            {

                if (self.displayLink)
                {
                    [self.displayLink invalidate];
                    self.displayLink = nil;
                }
                
                [self detachAnimated:NO];
                if (self.userInterface.delegate && [(id)self.userInterface.delegate respondsToSelector:@selector(moviePlayerUIShouldHandleClose:)])
                {
                    [self.userInterface.delegate moviePlayerUIShouldHandleClose:self.userInterface];
                }
                
                
            }
            self.shouldKeepPresentedOnStop = NO;
            
        }
    }
}

- (void)hidePlayer
{
    if (self.mode == AccedoMoviePlaybackModeLocal)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:MPMoviePlayerPlaybackDidFinishNotification object:self.mediaPlayer userInfo:@{MPMoviePlayerPlaybackDidFinishReasonUserInfoKey: @(MPMovieFinishReasonUserExited)}];
    }
    else
    {
        if (self.displayLink)
        {
            [self.displayLink invalidate];
            self.displayLink = nil;
        }

        [self detachAnimated:YES];
    }
}

- (void)handleMPMoviePlayerPlaybackStateDidChangeNotification:(NSNotification *)notif
{
    ILog(@"Playback state changed; %ld", (long)[self currentPlayer].playbackState);

    switch ([self playbackState])
    {
            
        case MPMoviePlaybackStatePaused:
        {
            [self.userInterface updateUIForPause];
            [self updateSubtitle:YES];
          
        }
            break;
        case MPMoviePlaybackStatePlaying:
        {
            [self attachToAccedoPlayerView];
            [self.userInterface updateUIForPlay];
            [self updateSubtitle:YES];
            
            [self hideSpinner];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                LOADING_ENDS(self.userInterface);
            });
            
        }
            break;
        case MPMoviePlaybackStateStopped:
        case MPMoviePlaybackStateInterrupted:
        {

            [self.userInterface updateUIForStop];
            break;
        }
        case MPMoviePlaybackStateSeekingBackward:
        case MPMoviePlaybackStateSeekingForward:
           //  LOADING_BEGINS(self.view);
            [self showSpinner];
            break;
    }
    [self.userInterface updateUIForDuration:[self duration]];
}



- (void)handleDisplayLink:(id)sender
{
    if (self.presentingViewController == nil)
        return;

    [self updateCurrentPlaybackTime:sender];

    [self updateSubtitle:NO];

    [self updateVolume];

    if ([self playbackState] == MPMoviePlaybackStatePlaying)
    {
        if (self.timeOfLastReport == nil || [[NSDate date] timeIntervalSinceDate:self.timeOfLastReport] > 60)
        {
        }
    }
}


// Hardware Button Volume Callback
void audioVolumeChangeListenerCallback (
                                        void                      *inUserData,
                                        AudioSessionPropertyID    inID,
                                        UInt32                    inDataSize,
                                        const void                *inData)
{
    AccedoMoviePlayer * player = (__bridge AccedoMoviePlayer *)inUserData;
    [player updateVolume];
}


- (void)startListeningToAudioVolume
{
    AudioSessionAddPropertyListener (
                                     kAudioSessionProperty_CurrentHardwareOutputVolume ,
                                     audioVolumeChangeListenerCallback,
                                     (__bridge void*)self);

    [self updateVolume];
}

- (void)stopListeningToAudioVolume
{
    AudioSessionRemovePropertyListenerWithUserData(
                                                   kAudioSessionProperty_CurrentHardwareOutputVolume,
                                                   audioVolumeChangeListenerCallback,
                                                   (__bridge void*)self);
}

- (void)handleMPMoviePlayerLoadStateDidChangeNotification:(NSNotification *)notif
{
    MPMovieLoadState loadState = [self loadState];
    
    if (self.userInterface){
        [self.userInterface updateUIForDuration:[self duration]];
    }

    if (loadState & MPMovieLoadStatePlayable)
    {
        if (self.mode == AccedoMoviePlaybackModeLocal)
        {
            [self play];
 
        }

        if (initialPosition != -1)
        {
            [[self currentPlayer] setCurrentPlaybackTime:initialPosition];

            initialPosition = -1;
        }
        else
        {
            
        }
    }
}

- (void)attachToAccedoPlayerView
{

    UIView * parent = nil;
    if (self.screen == AccedoMoviePlaybackScreenDevice)
    {
        parent = self.view;
    }
    else
    {
        parent = [ExternalDisplayViewController instance].view;
    }
    if (self.mediaPlayer && parent != self.mediaPlayer.view.superview)
    {
        [self.mediaPlayer.view removeFromSuperviewWithConstraints];
        self.mediaPlayer.view.translatesAutoresizingMaskIntoConstraints = NO;
        
        [parent addSubview:self.mediaPlayer.view];

        self.backgroundImage.hidden = YES;
        
        [parent addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": self.mediaPlayer.view}]];
        [parent addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": self.mediaPlayer.view}]];

        [parent setNeedsLayout];

        [parent layoutIfNeeded];
        if (self.userInterface){
            [parent bringSubviewToFront:self.userInterface];
            [self.userInterface attachToMoviePlayer:self];
        }


        AccedoMoviePlaybackMode oldMode = AccedoMoviePlaybackModeLocal;
        if (self.mode == AccedoMoviePlaybackModeRemote)
        {
            [self handleStateTransitionForOldMode:oldMode newMode:self.mode];
        }
    }
    [[ExternalDisplayViewController instance].view bringSubviewToFront:[ExternalDisplayViewController instance].subtitleLabel];
    [self attachRemoteBackgroundView];
}

- (void)attachRemoteBackgroundView
{
    if (self.remoteBackgroundView && self.remoteBackgroundView.superview != self.view)
    {
        self.remoteBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:self.remoteBackgroundView];

        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": self.remoteBackgroundView}]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": self.remoteBackgroundView}]];

        [self.remoteBackgroundView setNeedsUpdateConstraints];

        [self.view setNeedsLayout];

        [self.view layoutIfNeeded];

        self.remoteBackgroundView.hidden = YES;

        if (self.userInterface){
            [self.view bringSubviewToFront:self.userInterface];
            [self.userInterface attachToMoviePlayer:self];

            [self startListeningToAudioVolume];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backgroundImage = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.backgroundImage];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[v]|" options:0 metrics:nil views:@{@"v": self.backgroundImage}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]|" options:0 metrics:nil views:@{@"v": self.backgroundImage}]];
    
    self.backgroundImage.backgroundColor = [UIColor blackColor];
    [self showSpinner];
    //LOADING_BEGINS(self.view);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.backgroundImage.frame = self.view.bounds;

    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    //[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self didEnterForeground];
}

- (void)didEnterForeground
{
    if (self.mode == AccedoMoviePlaybackModeRemote)
    {
        [self.remotePlayer didEnterForeground];
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return IS_IPAD ? UIInterfaceOrientationMaskLandscape : UIInterfaceOrientationMaskLandscape;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (self.userInterface &&
        [self.userInterface respondsToSelector:@selector(willRotateToOrientation:)])
    {

        [self.userInterface willRotateToOrientation:toInterfaceOrientation];
    }
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (self.userInterface &&
        [self.userInterface respondsToSelector:@selector(updateForOrientation:)])
    {

        [self.userInterface updateForOrientation:toInterfaceOrientation];
    }

}
- (void)setGeneralAppgridConfig:(NSDictionary *)generalConfig {
    self.generalAppgridSettings = generalConfig;
}

#pragma mark - Internal

- (void)clearMediaPlayer
{
    @synchronized(self)
    {
        [self.mediaPlayer pause];
        if (self.userInterface &&
            [self.userInterface respondsToSelector:@selector(dismissPopover)])
        {
            [self.userInterface dismissPopover];
        }
        [self.drmProvider tearDownDRM];

     //   [self.mediaPlayer.view removeFromSuperviewWithConstraints];

        if (self.mediaPlayer)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:MPMoviePlayerPlaybackDidFinishNotification
                                                          object:self.mediaPlayer];
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                          object:self.mediaPlayer];
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:MPMoviePlayerDidExitFullscreenNotification
                                                          object:self.mediaPlayer];
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:MPMoviePlayerLoadStateDidChangeNotification
                                                          object:self.mediaPlayer];
        }

        self.drmProvider = nil;
        self.mediaPlayer = nil;
    }

    [self.view setNeedsUpdateConstraints];
    [self.view setNeedsLayout];
}

- (void)ensureCleanMediaPlayer
{
   @synchronized(self)
    {
        if (self.mediaPlayer == nil || self.mediaPlayer.contentURL != nil)
        {
            if (self.mediaPlayer != nil) [self clearMediaPlayer];

            self.mediaPlayer = [self.drmProvider newMediaPlayerInstance];

            if (self.mediaPlayer == nil)
            {
                self.mediaPlayer = (MPMoviePlayerController<MPExtendedMediaPlayback> *)[[MPMoviePlayerController alloc] init];

                //self.mediaPlayer.controlStyle = MPMovieControlStyleNone;
            }

            if ([self.mediaPlayer respondsToSelector:@selector(setEventListeners:)])
            {
                [self.mediaPlayer setEventListeners:self.eventListeners];
            }

            if ([self.mediaPlayer respondsToSelector:@selector(setErrorRenderer:)])
            {
                [self.mediaPlayer setErrorRenderer:self.errorRenderer];
            }

            self.mediaPlayer.allowsAirPlay = [[self.generalAppgridSettings valueForKey:@"allowsAirplay"] boolValue];
            self.mediaPlayer.shouldAutoplay = NO;
        }
    }
}

#pragma mark - Public interface

- (void)playUrl:(NSURL *)mediaUrl playObjet:(AccedoMoviePlayObject *)playObject
{
    
    self.backgroundImage.hidden = NO;
    self.lastPlayURL = mediaUrl;
    self.currentPlayObject = playObject;
    finalReportDone = NO;

    initialPosition = playObject.initialPosition == nil ? -1 : [playObject.initialPosition doubleValue];

    if (self.mode == AccedoMoviePlaybackModeLocal)
    {
        [self ensureCleanMediaPlayer];
    }
    else
    {
        [self clearMediaPlayer];
    }

    NSAssert(self.mediaPlayer.contentURL == nil, @"Reused Movie Player, ERROR");

    if (self.userInterface)
    {
        self.mediaPlayer.controlStyle = MPMovieControlStyleNone;
    }
    /*else
    {
        self.mediaPlayer.controlStyle = MPMovieControlStyleFullscreen;
    }*/
    
    if (self.userInterface.delegate)
    {
        NSURL * posterURL = nil;
        if ([(id)self.userInterface.delegate respondsToSelector:@selector(moviePlayerUIBackgroundImageURL:)])
        {
           posterURL = [self.userInterface.delegate moviePlayerUIBackgroundImageURL:self.userInterface];
        }
        UIImage * posterImage = nil;
        if ([(id)self.userInterface.delegate respondsToSelector:@selector(moviePlayerUIBackgroundImage:)])
        {
            posterImage = [self.userInterface.delegate moviePlayerUIBackgroundImage:self.userInterface];
        }
        
        self.backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
        
        if (posterImage)
        {
            self.backgroundImage.image = posterImage;
        }
        else if (posterURL)
        {
            [self.backgroundImage sd_setImageWithURL:posterURL];
        }
    }
    else
    {
        [self.backgroundImage setImage:nil];
    }
    
    
    [self.mediaPlayer setContentURL:mediaUrl];

    DLog(@"Playing URL: %@", mediaUrl);

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMPMoviePlayerPlaybackDidFinishNotification:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.mediaPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMPMoviePlayerPlaybackStateDidChangeNotification:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:self.mediaPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMPMoviePlayerLoadStateDidChangeNotification:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:self.mediaPlayer];

    self.shouldKeepPresentedOnStop = NO;
    //[[self currentPlayer] play];
}

- (void)setRemoteMedia:(id)remoteMedia
{
    [self.remotePlayer setRemoteMedia:remoteMedia];
}

- (id)remoteMedia
{
    return self.remotePlayer.remoteMedia;
}

- (void)setRemoteBackgroundView:(UIView *)remoteBackgroundView
{
    BOOL needsAttach = NO;
    if (_remoteBackgroundView)
    {
        if (_remoteBackgroundView.superview == self.view) needsAttach = YES;

        [_remoteBackgroundView removeFromSuperviewWithConstraints];
        _remoteBackgroundView = nil;
    }
    _remoteBackgroundView = remoteBackgroundView;

    if (needsAttach)
    {
        [self attachRemoteBackgroundView];

        //[(CastBackgroundView *)self.remoteBackgroundView updateWithFilm:self.currentPlayObject.film];
    }
}

- (void)setUserInterface:(UIView<AccedoMoviePlayerUI> *)userInterface
{
    if (_userInterface != userInterface)
    {
        [_userInterface removeFromSuperviewWithConstraints];
    }
    
    [self removeEventListener:_userInterface];
    
    _userInterface = userInterface;

    userInterface.frame = self.view.bounds;
    [self.view addSubview:userInterface];

    userInterface.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[ui]|" options:0 metrics:nil views:@{@"ui": userInterface}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[ui]|" options:0 metrics:nil views:@{@"ui": userInterface}]];

    [userInterface setNeedsUpdateConstraints];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];

    [self updateVolume];
    
    [self addEventListener:_userInterface];
}

- (float)currentVolume
{
    float vol = 0;
    if (self.mode == AccedoMoviePlaybackModeLocal)
    {
#if TARGET_IPHONE_SIMULATOR

        vol = dummy_system_volume;
#else
        vol = [[MPMusicPlayerController applicationMusicPlayer] volume];
#endif
    }
    else
    {
        vol = self.remotePlayer.volume;
    }
    return vol;
}

- (void)updateVolume
{

    [self.userInterface updateUIForVolume:[self currentVolume]];
}

- (void)detachAnimated:(BOOL)animated
{
    if ([self isPresented])
    {

        [self dismissViewControllerAnimated:animated completion:^{

            [self clearMediaPlayer];

            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:ACCEDO_MOVIE_PLAYER_PRESENT_SUBTITLE_NOTIFICATION
                                                          object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:ACCEDO_MOVIE_PLAYER_SWICH_SCREEN_NOTIFICATION
                                                          object:nil];
        }];
    }
}

- (BOOL)isPresented
{
    return self.presentingViewController != nil;
}

- (void)attachToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([self isPresented])
    {
        WLog(@"Player is already presented. Cannot attach.");
        return;
    }

    self.presentingView = nil;

    [self handleMPMoviePlayerLoadStateDidChangeNotification:nil];
    [self handleMPMoviePlayerPlaybackStateDidChangeNotification:nil];

    [self.remoteBackgroundView setNeedsLayout];
    self.remoteBackgroundView.hidden = self.mode == AccedoMoviePlaybackModeLocal && self.screen == AccedoMoviePlaybackScreenDevice;

    [self restartDisplayLink];
    
    [viewController presentViewController:self animated:animated completion:^{

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(presentSubtitles:animated:)
                                                     name:ACCEDO_MOVIE_PLAYER_PRESENT_SUBTITLE_NOTIFICATION
                                                   object:self.userInterface];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(swichScreenMode:)
                                                     name:ACCEDO_MOVIE_PLAYER_SWICH_SCREEN_NOTIFICATION
                                                   object:self.userInterface];

        if (self.userInterface &&
            [self.userInterface respondsToSelector:@selector(willRotateToOrientation:)])
        {
            [self.userInterface willRotateToOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
        }
        if (self.userInterface &&
            [self.userInterface respondsToSelector:@selector(updateForOrientation:)])
        {
            [self.userInterface updateForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
        }
        [self.view setNeedsLayout];
    
        DLog(@"ATTACH FINISHED ============================================================================================");
    }];
}

#pragma mark AV STUFF

-(void)presentSubtitles:(NSNotification *) notification animated:(BOOL)animated {

    UIViewController* viewController = [notification.userInfo valueForKey:ACCEDO_MOVIE_PLAYER_PRESENT_SUBTITLE_KEY];

    if (viewController && ![self.presentedViewController isEqual:viewController]) {
        [self presentViewController:viewController animated:animated completion:nil];
    }
}

-(void)swichScreenMode:(NSNotification *)notification {
    if (self.mediaPlayer.scalingMode== MPMovieScalingModeAspectFill ) {
        self.mediaPlayer.scalingMode = MPMovieScalingModeAspectFit;
    } else {
        self.mediaPlayer.scalingMode = MPMovieScalingModeAspectFill;
    }
    if (self.userInterface && [self.userInterface respondsToSelector:@selector(updateUIForScreen:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.userInterface updateUIForScreen: self.mediaPlayer.scalingMode];
        });
    }

}

#pragma mark Loading indicators
-(void) showSpinner
{
    
    if (self.spinner == nil) {
        
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.color = [UIColor blackColor];
    hud.activityIndicatorColor = [UIColor PSColorC3];
    hud.removeFromSuperViewOnHide = NO;
    self.spinner = hud;
    }else {
    
        [self.spinner show:YES];
    }
}

-(void) hideSpinner
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}


@end

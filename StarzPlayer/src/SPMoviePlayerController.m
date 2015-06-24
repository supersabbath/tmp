//
//  SPMoviePlayerController.m
//  StarzPlayer
//
//  Created by Fernando Canon on 24/06/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import "SPMoviePlayerController.h"
// PDSDK
#import <PSDKLibrary/PSDKLibrary.h>
//Collaborator
#import "PTSVideoItem.h"

@interface SPMoviePlayerController () {
    
    PTQoSProvider *qosProvider;
    BOOL wasPlayingBeforeSuspend;
    BOOL wasPlaybackNotificationSent; // for resume after home button is touch
   __weak id <SPMoviewPlayerControllerObserver> observer;
}

@property (nonatomic, strong) PTSVideoItem *videoItem;

@end

@implementation SPMoviePlayerController

- (id) initWithMediaPlayerItem:(PTSVideoItem *) mediaItem andViewController:(id<SPMoviewPlayerControllerObserver>) observerViewController
{
    
    self = [super init];
    if (self) {
        wasPlaybackNotificationSent = NO;
        self.videoItem = mediaItem;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:NULL];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:NULL];
        observer = observerViewController;
        [self addObserverToAdobeNotifications:observerViewController];
    }
    
    return self;
}

/*Playback Public Actions*/

#pragma mark - Private Actions
- (void) playVideo:(PTSVideoItem *)item withCompletionBlock:(PlayerInitializationCompletion)onPlayerViewReadyBlock
{
    [self releasePlayer];
    self.videoItem = item;
    [self playCurrentVideo:onPlayerViewReadyBlock];
}

- (void) playCurrentVideo:(PlayerInitializationCompletion)onPlayerViewReadyBlock
{
    wasPlaybackNotificationSent = NO;
    PTMediaPlayerItem *playableItem = [self createPTMediaplayerItemIfNeeded];
    UIView *playerView = [self createMediaPlayerView:playableItem];
    
    if (onPlayerViewReadyBlock) {
        onPlayerViewReadyBlock(playerView);
    }
}

- (void) stopVideo
{
    if (self.player)
    {
        [self.player stop];
    }
}

- (void) pauseVideo
{
     [self.player pause];
}

- (void) resumeVideo
{
    if (self.player && self.player.status == PTMediaPlayerStatusPaused)
    {
        [self.player play];
    }

}

- (void) releasePlayer
{
    [self removeObserverFromPlaybackNotificatiobs:observer];
    if (self.player != nil)
    {
        [self.player reset];
        [(UIView *)self.player.view removeFromSuperview];
        self.player = nil;
    }
    
    if (qosProvider)
    {
        qosProvider = nil;
    }
}


- (UIView *) createMediaPlayerView:(PTMediaPlayerItem *)item
{
    [PTSDKConfig setSubscribedTags:[NSArray arrayWithObject:@"#EXT-OATCLS-SCTE35"]];
#ifdef DEBUG
    [PTMediaPlayer enableDebugLog:NO];
#endif
    self.player = [PTMediaPlayer playerWithMediaPlayerItem:item];
    
   // [self addObserversToAdobeNotifications];
    
    self.player.currentTimeUpdateInterval = 1000;
    self.player.allowsAirPlayVideo = NO;                               // enable airplay
    self.player.videoGravity = PTMediaPlayerVideoGravityResizeAspect;   // set the video display properties
    self.player.muted = NO;
    self.player.autoPlay = YES;
    
    
    UIView *playerView =_player.view;
    playerView.translatesAutoresizingMaskIntoConstraints = NO;
    [playerView setBackgroundColor:[UIColor clearColor]];
    
    [self qosSetup]; // attach player to qosProvider
    
    DRMManager *manager = _player.drmManager;
    if (! _player.currentItem.isDrmProtected || ! [manager isSupportedPlaylist:item.url]) {
        // since this content is not FlashAccess protected, we will queue it up for playback without further DRM consideration
        NSLog(@"Loading NON FAXS content  %@", item.url);
        // start playback directly
        [self startPlayback];
    }
    else {
        [self startAuthentication:self.videoItem];
    }
    return playerView;
}

- (void) startPlayback
{
    [self.player play];
}
#pragma mark SEEK
- (void) seekToTime:(CMTime)time {
    
    [self.player seekToTime:time];
}


- (void) seekToTime:(CMTime)time completionHandler:(void (^)(BOOL finished))completionHandler
{

    [self.player seekToTime:time completionHandler:^(BOOL finished) {
        [self log:@"seekToTime complete........" ];
        completionHandler(YES);
    }];
}

#pragma mark Player Properties Accessor

- (void)setVolume:(float)newVolume
{
    [self.player setVolume:newVolume];
}

- (float)volume
{
    return self.player.volume;
}

- (BOOL) isLive
{
    return self.player.currentItem.isLive;
}


-(CMTime) currentTime
{
    return self.player.currentItem.currentTime;
}
#pragma mark DRM process

- (void) startAuthentication:(PTSVideoItem *)videoItem
{
    [self log: @"=== startAuthentication ==="];
    DRMManager *manager = _player.drmManager;
    if (_player && _player.currentItem)
    {
        PTMediaPlayerItem *mpItem = _player.currentItem;
        
        [mpItem loadDRMMetadataWithCompletionHandler:^(PTDRMMetadataInfo *metadata)
         {
             [self log:@"DRM Metadata loaded complete"];
             
             DRMMetadata *newMetadata = metadata.drmMetadata;
             if (newMetadata)
             {
                 DRMPolicy* firstPolicy = (DRMPolicy*)[[newMetadata getPolicies] objectAtIndex:0];
                 if (firstPolicy.authenticationMethod == USERNAME_AND_PASSWORD)
                 {
                     [self log:@"=============== Authenticating to License server, USERNAME_AND_PASSWORD : %@", [newMetadata getServerUrl]];
                     [manager authenticate:newMetadata url:newMetadata.serverUrl authenticationDomain:firstPolicy.authenticationDomain username:videoItem.drmUserName password:videoItem.drmUserPassword
                                     error:^(DRMError* error)
                      {
                          [self logDRMError:@"DRM authenticating error" :error];
                      }
                                  complete:^(NSData* token)
                      {
                          [self log:@"authentication successful"];
                          [self log:@"authentication token is %ld bytes", (long)[token length]];
                          [self startPlayback];
                      }
                      ];
                 }
                 else if (firstPolicy.authenticationMethod == UNKNOWN)
                 {
                     // custom authentication method, unkown to Adobe
                     NSData* tokenData = [videoItem.drmToken dataUsingEncoding:NSUTF8StringEncoding];
                     [self log:@"=============== Authenticating to License server, UNKNOWN : %@", [newMetadata getServerUrl]];
                     
                     __weak DRMManager *weakDRMManager = manager;
                     
                     // set token
                     [manager setAuthenticationToken:newMetadata authenticationDomain:firstPolicy.authenticationDomain token:tokenData
                                               error:^(DRMError* error){
                                                   
                                                   [self logDRMError:@"SetAuthenticationToken DRM error" :error];
                                                   
                                               } complete:^(){
                                                   // FORCE_REFRESH The License is always downloaded from the media rights server.
                                                   // LOCAL_ONLY The License is only loaded from the local cache.
                                                   // ALLOW_SERVER The License is loaded from the local cache if possible, but otherwise is downloaded from the server.
                                                   DRMAcquireLicenseSettings drmSetting = FORCE_REFRESH;
                                                   [weakDRMManager acquireLicense:newMetadata setting:drmSetting
                                                                            error:^(DRMError* error) {
                                                                                
                                                                                [self logDRMError:@"acquireLicense DRM ERROR" :error];
                                                                                
                                                                                
                                                                            } acquired:(DRMLicenseAcquired)^{
                                                                                [self log: @"=============== DRM acquireLicense: successfull "];
                                                                                [self startPlayback];
                                                                            }
                                                    ];
                                               }
                      ];
                 }
                 else if (firstPolicy.authenticationMethod == ANONYMOUS)
                 {
                     [self log:@"=============== Authenticating to License server, ANONYMOUS : %@", [newMetadata getServerUrl]];
                     [self startPlayback];
                 }
                 else
                 {
                     [self log: @"DRM ERROR: unsupported authentication method: %d", firstPolicy.authenticationMethod];
                 }
             }
             else
             {
                 [self log:@"===============  LOAD DRM ERROR: empty DRM metadata"];
             }
             
         }
         
                                        errorHandler:^(PTMediaError *error)
         {
#warning TODO:
             // please don't use the error object here, there is an exception thrown in the PSDK that will be addressed soon.
             // use player.error object instead  [self logDRMError:@"SetAuthenticationToken DRM error" :error];
             [self logDRMError:@"=============== loadDRMMetadataWithCompletionHandler": (DRMError*)self.player.error];
             
   
             
         }
         ];
    }
    else
    {
        [self log:@"===============  DRM Error: Could not start Authentication, no player instance or no current media player item created!"];
    }
    
}



- (void) logDRMError:(NSString*)str :(DRMError*)error
{

    NSUInteger major = error.majorError;
    
    if (major == 3322 || major == 3323 || major == 3324 || major == 3326)
    {
        
        [[DRMManager sharedManager] resetDRM:^(DRMError *secondError) {
            NSLog(@"[Second Error %@:] major:[%ld] minor:[%ld] string: [%@] NSError:[%@]", str, (long)error.majorError, (long)error.minorError, error.errorString, error.platformError);
                [observer logDRMError:str :secondError];
        } complete:^{
            [self.player play];
        }];
    }
    else {
        [observer logDRMError:str :error];
    }
};


#pragma mark - PTMetaData 

- (PTMediaPlayerItem*) createPTMediaplayerItemIfNeeded {
    
    if ([(NSObject*)self.videoItem.starzAsset valueForKey:@"ptMediaPlayerItem"] != nil) // we are using the the one created by PSPlayFilmObject
    {
        return [(NSObject*)self.videoItem.starzAsset valueForKey:@"ptMediaPlayerItem"];
    }else{
        
        NSURL *m3uUrl = [NSURL URLWithString:self.videoItem.url ];
        PTMetadata *metadata = [self createMetadata];
        PTMediaPlayerItem *item = [[PTMediaPlayerItem alloc] initWithUrl:m3uUrl mediaId:self.videoItem.mediaId metadata:metadata];
        return   item;
    }
}

- (PTMetadata *) createMetadata
{
    PTMetadata* metadata = [[PTMetadata alloc] init];
    if (self.videoItem.abrControl != nil)
    {
        [metadata setMetadata:self.videoItem.abrControl forKey:PTABRResolvingMetadataKey];
    }
    return metadata;
}
#pragma mark - Notification
#pragma mark -

- (void) addObserverToAdobeNotifications:(id<SPMoviewPlayerControllerObserver>) currentObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:currentObserver selector:@selector(onMediaPlayerStatusChange:) name:PTMediaPlayerStatusNotification object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:currentObserver selector:@selector(onMediaPlayerTimeChange:) name:PTMediaPlayerTimeChangeNotification object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:currentObserver selector:@selector(onMediaPlayerItemPlayStarted:) name:PTMediaPlayerPlayStartedNotification object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:currentObserver selector:@selector(onMediaPlayerItemPlayCompleted:) name:PTMediaPlayerPlayCompletedNotification object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:currentObserver selector:@selector(onMediaPlayerSeekCompleted:) name:PTMediaPlayerSeekCompletedNotification object:self.player];
    
}


- (void) removeObserverFromPlaybackNotificatiobs:(id<SPMoviewPlayerControllerObserver>) currentObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:currentObserver];
}



#pragma mark - Helpers

- (void) qosSetup
{
    qosProvider = [[PTQoSProvider alloc] initWithPlayer:self.player];
   
}


-(PTPlaybackInformation*) qoServiceInfo
{
    return qosProvider.playbackInformation;
}

#pragma mark - UTILS and Debugger
- (void) log:(NSString*)format, ...
{
#ifdef DEBUG
    
    if(DEBUG) //logging could be turned on/off here
    {
        va_list args;
        va_start(args,format);
        NSLogv(format, args);
        va_end(args);
    }
#endif
}

#pragma mark - Notitfications from Device
- (void) applicationWillResignActive
{
    wasPlayingBeforeSuspend = self.player.status == PTMediaPlayerStatusPlaying;
    [self.player pause];
}

- (void) applicationDidBecomeActive
{
    if (wasPlayingBeforeSuspend)
    {
        [self.player play];
    }
}

@end

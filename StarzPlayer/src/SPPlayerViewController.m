//
//  SPPlayerViewController.m
//  StarzPlayer
//
//  Created by Fernando Canon on 18/05/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import "SPPlayerViewController.h"
#import <PSDKLibrary/PSDKLibrary.h>
#import "PTSVideoItem.h"
#import "SPPlayerControlView.h"
#import "PSScrubbingCollectionViewController.h"
#import "SPVolumeViewController.h"

#define METADATA_TABLEVIE_TAG 843

@interface SPPlayerViewController ()

@property (nonatomic, strong) PTMediaPlayer *player;
@property (nonatomic, weak) IBOutlet SPPlayerControlView *controlView;
@property (weak, nonatomic) IBOutlet UIView *playerContainerView;
@property (nonatomic, strong) MetadataTableViewController *metadataTableViewController;
@property (weak, nonatomic) IBOutlet UIView *thumbsContainer;
@property (strong, nonatomic)  PSScrubbingCollectionViewController *scrubbCollectionView;

@end

@implementation SPPlayerViewController

- (instancetype)initWithVideoItem:(PTSVideoItem *) videoItem;
{
    self = [super init];
    if (self) {
        _currentItem = videoItem;
    }
    return self;
}

#pragma mark ViewController Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view bringSubviewToFront:_controlView];
    [self showScrubbingThumbnails];
    [_scrubbCollectionView fetchScrubbingImagesForULR:@"http://mena-cdn-lb.aws.playco.com/MGM/GIRLWITHTHEDRAGONTATTOOY2011M/GIRLWITHTHEDRAGONTATTOOY2011M.fs"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
    //  return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? UIInterfaceOrientationMaskLandscape : UIInterfaceOrientationMaskPortrait;
}


#pragma mark - Notification

- (void) addObserversToAdobeNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMediaPlayerStatusChange:) name:PTMediaPlayerStatusNotification object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMediaPlayerTimeChange:) name:PTMediaPlayerTimeChangeNotification object:self.player];
    //  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMediaPlayerNotificationItemEntry:) name:PTMediaPlayerNewNotificationEntryAddedNotification object:self.player];
    //  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMediaPlayerItemPlayStarted:) name:PTMediaPlayerPlayStartedNotification object:self.player];
    //  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMediaPlayerItemPlayCompleted:) name:PTMediaPlayerPlayCompletedNotification object:self.player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMediaPlayerSubscribedTagIdentified:) name:PTTimedMetadataChangedNotification object:self.player.currentItem];
    //   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableCC:) name:@"EnableCCNotification" object:nil];
    //   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMediaPlayerSubscribedTagIdentified:) name:PTTimedMetadataChangedNotification object:self.player.currentItem];
}

- (void) stopObservingAdobeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Player Actions 

- (void) playVideo:(PTSVideoItem *)item
{
    self.currentItem = item;
    
    if (self.player)
    {
        [self.player stop];
        [self.player reset];
    }
    
    [self playVideo];
}


- (void) pauseVideo
{
    [self.player pause];
}

- (void)resize{}
- (void)resumeVideo{}
- (void)stopVideo{}


- (void) playVideo
{
    NSURL *url = [NSURL URLWithString:_currentItem.url];
    if (url == nil) // invalid url
    {
#warning TODO
        return;
    }
    
    if (self.player)
    {
        [self releasePlayer];
    }
    
    PTMetadata *metadata = [self createMetadata];
    
    PTMediaPlayerItem *item = [[PTMediaPlayerItem alloc] initWithUrl:url mediaId:_currentItem.mediaId metadata:metadata];
    item.secure = NO;
    
    [self createMediaPlayer:item];
}

-(void)releasePlayer
{
    if (self.player != nil)
    {
        [self.player reset];
        [self stopObservingAdobeNotifications];
        [(UIView *)self.player.view removeFromSuperview];
        self.player = nil;
    }
    
#warning TODO qosProvider
    
    if (self.controlView)
    {
      //  self.controlView.player = nil;
    }
}

- (void) createMediaPlayer:(PTMediaPlayerItem *)item
{
    [PTSDKConfig setSubscribedTags:[NSArray arrayWithObject:@"#EXT-OATCLS-SCTE35"]];
    [PTMediaPlayer enableDebugLog:NO];
    
    self.player = [PTMediaPlayer playerWithMediaPlayerItem:item];
    
    [self addObserversToAdobeNotifications];
    
    self.player.currentTimeUpdateInterval = 1000;
    self.player.allowsAirPlayVideo = NO;                               // enable airplay
    self.player.videoGravity = PTMediaPlayerVideoGravityResizeAspect;   // set the video display properties
    
//self.player.closedCaptionDisplayEnabled = _enableCC;
    //self.player.volume = 1.0f;
    //self.player.muted = NO;
    //self.player.autoPlay = YES;
    
   // _controlView.player = self.player;
    
//
    [self.playerContainerView setBackgroundColor:[UIColor redColor]];
   
    
    
    
    UIView *playerView =_player.view;//[[UIView alloc] init];
    playerView.translatesAutoresizingMaskIntoConstraints = NO;
    [playerView setBackgroundColor:[UIColor blackColor]];
 //   _player.view;
    [self.playerContainerView addSubview:playerView];
    [self.playerContainerView bringSubviewToFront:_controlView];
    
    [self.playerContainerView addConstraint:[NSLayoutConstraint constraintWithItem:playerView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.playerContainerView
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0]];
    
 
    [self.playerContainerView addConstraint:[NSLayoutConstraint constraintWithItem:playerView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.playerContainerView
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.0
                                                           constant:0]];
    
    // Center horizontally
    [self.playerContainerView addConstraint:[NSLayoutConstraint constraintWithItem:playerView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.playerContainerView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    // Center vertically
    [self.playerContainerView addConstraint:[NSLayoutConstraint constraintWithItem:playerView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.playerContainerView
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0]];
    

//    NSDictionary *views = NSDictionaryOfVariableBindings(playerView);
//    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [self.playerContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [self.playerContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[playerView]-(0)-|" options:0 metrics:nil views:views]];
//    [self.playerContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[playerView]-(0)-|" options:0 metrics:nil views:views]];
//
//    [self qosSetup]; // attach player to qosProvider
    /* Enable for Video Heartbeat Tracking */
    // self.videoAnalyticsTracker = [[[PTVideoAnalyticsTracker alloc] initWithMediaPlayer:self.player] autorelease];
//    [self.view layoutIfNeeded];

    DRMManager *manager = _player.drmManager;
    if (! _player.currentItem.isDrmProtected || ! [manager isSupportedPlaylist:item.url]) {
        // since this content is not FlashAccess protected, we will queue it up for playback without further DRM consideration
        NSLog(@"Loading NON FAXS content  %@", item.url);
        // start playback directly
        [self startPlayback];
    }
    else {
        [self startAuthentication:_currentItem];
    }
    
}

- (void) startPlayback
{
    // start playback
    NSLog(@"=== start playback ===");
    [self.player play];
}


- (void) logDRMError:(NSString*)str :(DRMError*)error
{
    NSLog(@"[%@:] major:[%ld] minor:[%ld] string: [%@] NSError:[%@]", str, (long)error.majorError, (long)error.minorError, error.errorString, error.platformError);
};


- (void) startAuthentication:(PTSVideoItem *)videoItem
{
    NSLog(@"=== startAuthentication ===");
    DRMManager *manager = _player.drmManager;
    if (_player && _player.currentItem)
    {
        PTMediaPlayerItem *mpItem = _player.currentItem;
        
        [mpItem loadDRMMetadataWithCompletionHandler:^(PTDRMMetadataInfo *metadata)
         {
             NSLog(@"DRM Metadata loaded complete");
            
             DRMMetadata *newMetadata = metadata.drmMetadata;
             if (newMetadata)
             {
                 DRMPolicy* firstPolicy = (DRMPolicy*)[[newMetadata getPolicies] objectAtIndex:0];
                 if (firstPolicy.authenticationMethod == USERNAME_AND_PASSWORD)
                 {
                     NSLog(@"=============== Authenticating to License server, USERNAME_AND_PASSWORD : %@", [newMetadata getServerUrl]);
                     [manager authenticate:newMetadata url:newMetadata.serverUrl authenticationDomain:firstPolicy.authenticationDomain username:videoItem.drmUserName password:videoItem.drmUserPassword
                                     error:^(DRMError* error)
                      {
                          [self logDRMError:@"DRM authenticating error" :error];
                      }
                                  complete:^(NSData* token)
                      {
                          NSLog( @"authentication successful");
                          NSLog( @"authentication token is %ld bytes", (long)[token length]);
                          [self startPlayback];
                      }
                      ];
                 }
                 else if (firstPolicy.authenticationMethod == UNKNOWN)
                 {
                     // custom authentication method, unkown to Adobe
                     NSData* tokenData = [videoItem.drmToken dataUsingEncoding:NSUTF8StringEncoding];
                     NSLog( @"=============== Authenticating to License server, UNKNOWN : %@", [newMetadata getServerUrl]);
                     
                     __weak DRMManager *weakDRMManager = manager;
                     
                     // set token
                     [manager setAuthenticationToken:newMetadata authenticationDomain:firstPolicy.authenticationDomain token:tokenData
                                               error:^(DRMError* error)
                      {
                          [self logDRMError:@"SetAuthenticationToken DRM error" :error];
                      }
                                            complete:^()
                      {
                          //	FORCE_REFRESH The License is always downloaded from the media rights server.
                          // LOCAL_ONLY The License is only loaded from the local cache.
                          // ALLOW_SERVER The License is loaded from the local cache if possible, but otherwise is downloaded from the server.
                          DRMAcquireLicenseSettings drmSetting = FORCE_REFRESH;
                          [weakDRMManager acquireLicense:newMetadata setting:drmSetting
                                                   error:^(DRMError* error)
                           {
                               [self logDRMError:@"acquireLicense DRM ERROR" :error];
                           }
                                                acquired:(DRMLicenseAcquired)^
                           {
                               NSLog( @"=============== DRM acquireLicense: successfull ");
                               [self startPlayback];
                           }
                           ];
                      }
                      ];
                 }
                 else if (firstPolicy.authenticationMethod == ANONYMOUS)
                 {
                     NSLog( @"=============== Authenticating to License server, ANONYMOUS : %@", [newMetadata getServerUrl]);
                     [self startPlayback];
                 }
                 else
                 {
                     NSLog( @"DRM ERROR: unsupported authentication method: %d", firstPolicy.authenticationMethod);
                 }
             }
             else
             {
                 NSLog( @"===============  LOAD DRM ERROR: empty DRM metadata");
             }
             
         }
         
          errorHandler:^(PTMediaError *error)
         {
             // please don't use the error object here, there is an exception thrown in the PSDK that will be addressed soon.
             // use player.error object instead
             NSLog( @"=============== loadDRMMetadataWithCompletionHandler ERROR:  media player item error code[%ld], description[%@]", (long)self.player.error.code, self.player.error.description);
             
         }
         ];
    }
    else
    {
        NSLog( @"===============  DRM Error: Could not start Authentication, no player instance or no current media player item created!");
    }
    
}


- (PTMetadata *) createMetadata
{
    PTMetadata* metadata = [[PTMetadata alloc] init];
    
    if (_currentItem && _currentItem.auditudeInfo)
    {
        PTAuditudeMetadata *adMetadata = [[PTAuditudeMetadata alloc] init];
        adMetadata.zoneId = [[_currentItem.auditudeInfo objectForKey:@"zoneId"] integerValue];
        adMetadata.domain = [_currentItem.auditudeInfo objectForKey:@"domain"];
        //adMetadata.signalingMode = PTAdSignalingModeManifestCues;
        adMetadata.isCreativeRepackagingEnabled = [[_currentItem.auditudeInfo objectForKey:@"creativeRepackaging"] boolValue];
        //adMetadata.enableDVRAds = YES;
        
        NSString *targetingParametersString = [_currentItem.auditudeInfo objectForKey:@"targetingParameters"];
        if (targetingParametersString)
        {
            NSArray *components = [targetingParametersString componentsSeparatedByString:@"&"];
            if (components.count > 0)
            {
                NSMutableDictionary *targetingParameters = [[NSMutableDictionary alloc] init];
                for (int i = 0; i < components.count; i++)
                {
                    NSString *component = [components objectAtIndex:i];
                    if (component)
                    {
                        NSArray *keyVaue = [component componentsSeparatedByString:@"="];
                        if (keyVaue && keyVaue.count == 2)
                        {
                            [targetingParameters setObject:[keyVaue objectAtIndex:1] forKey:[keyVaue objectAtIndex:0]];
                        }
                    }
                }
                
                adMetadata.targetingParameters = targetingParameters;
            }
        }
        
        NSString *customParametersString = [_currentItem.auditudeInfo objectForKey:@"customParameters"];
        if (customParametersString)
        {
            NSArray *components = [customParametersString componentsSeparatedByString:@"&"];
            if (components.count > 0)
            {
                NSMutableDictionary *customParameters = [[NSMutableDictionary alloc] init];
                for (int i = 0; i < components.count; i++)
                {
                    NSString *component = [components objectAtIndex:i];
                    if (component)
                    {
                        NSArray *keyVaue = [component componentsSeparatedByString:@"="];
                        if (keyVaue && keyVaue.count == 2)
                        {
                            [customParameters setObject:[keyVaue objectAtIndex:1] forKey:[keyVaue objectAtIndex:0]];
                        }
                    }
                }
                
                adMetadata.customParameters = customParameters;
            }
        }
        
        [metadata setMetadata:adMetadata forKey:PTAdResolvingMetadataKey];
    }
    
    //ABR metadata
    //int initialBR = 41457;
    //int initialBR = 2500000;
    //int minBR = 250000;
    //int maxBR = 2000000;
    
    //PTABRControlParameters *abrMetaData = [[PTABRControlParameters alloc] initWithABRControlParams:initialBR minBitRate:minBR maxBitRate:maxBR];
    //[metadata setMetadata:abrMetaData forKey:PTMBRResolvingMetadataKey];
    
    /* Enable following code for Video Heartbeat Tracking */
    /*
     PTVideoAnalyticsTrackingMetadata *vaTrackingMetadata = [[[PTVideoAnalyticsTrackingMetadata alloc] initWithTrackingServer:@"http://heartbeats.omtrdc.net"
     jobId:@"j2"
     publisher:@"adobe"] autorelease];
     vaTrackingMetadata.debugLogging = YES; // TODO: Set to NO for production version.
     vaTrackingMetadata.quietMode = NO;
     vaTrackingMetadata.channel = @"test-channel";
     
     [metadata setMetadata:vaTrackingMetadata forKey:PTVideoAnalyticsTrackingMetadataKey];
     */
    
    return metadata;
}



#pragma mark -
#pragma mark Media Player Notifications

- (void)onMediaPlayerStatusChange:(NSNotification *)notification
{
    //the status is also available as self.player.status
    NSDictionary* userInfo = [notification userInfo];
    PTMediaPlayerStatus status = [(NSNumber*)[userInfo objectForKey:PTMediaPlayerStatusKey] intValue];
    PTMediaError *error;
    
    switch(status)
    {
        case PTMediaPlayerStatusCreated:
            [self log:@"=== Status: PTMediaPlayerStatusCreated ==="];
            break;
        case PTMediaPlayerStatusInitializing:

            [[self controlView] changeViewToLoadingMode];
            [self log:@"=== Status: PTMediaPlayerStatusInitializing ==="];
            break;
        case PTMediaPlayerStatusInitialized:
            [self log:@"=== Status: PTMediaPlayerStatusInitialized ==="];
            break;
        case PTMediaPlayerStatusReady:
        //    [_activityIndicator stopAnimating];
              [[self controlView] changeViewToLoadingMode];
        //    _activityIndicator.hidden = YES;
            [self log:@"=== Status: PTMediaPlayerStatusReady ==="];
            break;
        case PTMediaPlayerStatusPlaying:

            [self log:@"=== Status: PTMediaPlayerStatusPlaying ==="];
            [[self controlView] changeViewToPlayingMode];
            break;
        case PTMediaPlayerStatusPaused:
    
            [self log:@"=== Status: PTMediaPlayerStatusPaused ==="];
            break;
        case PTMediaPlayerStatusStopped:
            [self log:@"=== Status: PTMediaPlayerStatusStopped ==="];
              [[self controlView] changeViewToLoadingMode];
            break;
        case PTMediaPlayerStatusCompleted:
            [self log:@"=== Status: PTMediaPlayerStatusCompleted ==="];
            break;
        case PTMediaPlayerStatusError:
            error = self.player.error;
            [self log:@"=== Status: PTMediaPlayerStatusError ==="];
            [self log:[NSString stringWithFormat:@"PTSPlayerView:: Error - media player error code[%ld], description[%@], metadata[%@].", (long)error.code, error.description, error.metadata]];
            [self log:@"PTSPlayerView:: Stopping playback due to errors."];
            [self.player stop];
            break;
    }
}

- (void)onMediaPlayerNotificationItemEntry:(NSNotification *)nsnotification
{
    PTNotification *notification = [nsnotification.userInfo objectForKey:PTMediaPlayerNotificationKey];
    [self log:[NSString stringWithFormat:@"PTSPlayerView:: Notification - media player notification code[%ld], description[%@], metadata[%@].", (long)notification.code, notification.description, notification.metadata]];
}


- (void) onMediaPlayerItemPlayStarted:(NSNotification *)notification
{
    [self log:@"PTSPlayerView:: Media Playback started."];
}

- (void) onMediaPlayerItemPlayCompleted:(NSNotification *) notification
{
    [self log:@"PTSPlayerView:: Media Playback completed."];
}

- (void) onMediaPlayerAdBreakStarted:(NSNotification *) notification
{
    [self log:@"PTSPlayerView:: Ad break Started."];
}

- (void) onMediaPlayerAdBreakCompleted:(NSNotification *) notification
{
    [self log:@"PTSPlayerView:: Ad break completed."];
}

- (void) onMediaPlayerAdPlayStarted:(NSNotification *) notification
{
    [self log:@"PTSPlayerView:: Ad playback started."];
}

- (void) onMediaPlayerAdPlayProgress:(NSNotification *) notification
{
    PTAd *ad = [notification.userInfo objectForKey:PTMediaPlayerAdKey];
    
    if (ad != nil)
    {
        //[self log:@"PTSPlayerView:: Ad playback progress."];
    }
}

- (void) onMediaPlayerAdPlayCompleted:(NSNotification *) notification
{
    [self log:@"PTSPlayerView:: Ad playback completed."];
}

- (void)onMediaPlayerSubscribedTagIdentified:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    PTTimedMetadata *timedMetadata = (PTTimedMetadata *)[userInfo objectForKey:PTTimedMetadataKey];
    
    if (timedMetadata && [timedMetadata.name isEqualToString:@"#EXT-OATCLS-SCTE35"])
    {
        // uncomment the code below to read values for specific SCTE35 standard keys from the timedmetadata.
        // example base64string: @"/DA0AAAAAt/HAAAABQb+R2yfGwAeAhxDVUVJSAAAIn/PAAEGqkgICAAAAAAeYcdJNAAA79Oplg==";
        
        /*   PTMetadata *metadata = (PTMetadata *)timedMetadata;
         NSString *base64String = [metadata valueForKey:PTDataKey];
         NSData *decodedData = [NSData dataFromBase64String:base64String];
         PTSCTE35Parser *scteParser = [[PTSCTE35Parser alloc]init];
         PTSCTE35SpliceInfo *spliceInfo = [scteParser getObject:decodedData];
         NSDictionary *spliceInfoSection = spliceInfo.splice_info_section;
         
         //1.1.	Example usecase: Break with No Local Avail: subset
         if ([[spliceInfoSection objectForKey:PTSCTE35_SpliceCommandType] integerValue] == 6)
         {
         if ([spliceInfoSection objectForKey:PTSCTE35_SpliceDescriptors])
         {
         NSArray *spliceDescriptors = [spliceInfoSection objectForKey:PTSCTE35_SpliceDescriptors];
         NSDictionary *firstSpliceDescriptor = [spliceDescriptors objectAtIndex:0];
         
         if (firstSpliceDescriptor && [[firstSpliceDescriptor objectForKey:PTSCTE35_WebDeliveryAllowedFlag] integerValue] == 0)
         {
         if ([[firstSpliceDescriptor objectForKey:PTSCTE35_SegmentationUpidType]integerValue] == 8)
         {
         NSMutableDictionary *newTargetingParams = [NSMutableDictionary dictionary];
         NSNumber *segmentationUPID = [firstSpliceDescriptor objectForKey:PTSCTE35_SegmentationUpid];
         NSNumber *segmentationDuration = [firstSpliceDescriptor objectForKey:PTSCTE35_SegmentationDuration];
         
         [newTargetingParams setObject:segmentationUPID forKey:@"segmentation-upid"];
         [newTargetingParams setObject:segmentationDuration forKey:@"segmentation-duration"];
         [newTargetingParams setObject:[NSNumber numberWithInt:0] forKey:@"segment-number"];
         [newTargetingParams setObject:[NSNumber numberWithInt:0] forKey:@"segments-expected"];
         
         [self updateAdMetadataWithDictionary:newTargetingParams];
         }
         }
         }
         }
         [scteParser release];
         scteParser = nil;*/
    }
}

- (void) log:(NSString*)format, ...
{
    // if(DEBUG) //logging could be turned on/off here
    {
        va_list args;
        va_start(args,format);
        NSLogv(format, args);
        va_end(args);
    }
}

- (void) onMediaPlayerTimeChange:(NSNotification *)notification
{
    CMTimeRange seekableRange = self.player.seekableRange;
    [_controlView updateViewForTimeRange:seekableRange andCurrentPosition:self.player.currentItem.currentTime];
    
}


#pragma mark - SPPlayerControlView Delegate
- (void)view:(SPPlayerControlView*) view didReceivePlayTouch:(UIButton*) button
{
    [self.player  play];
}

- (void)view:(SPPlayerControlView*) view didReceivePauseTouch:(UIButton*) button
{
    [self pauseVideo];
}


/*Slider delegate*/
-(void)view:(SPPlayerControlView*) view valueDidChangeToPlaybackTime:(CMTime) time
{
    
    
    double currentTime = CMTimeGetSeconds(time);
    
    double scrubWidth = self.scrubbCollectionView.collectionView.contentSize.width;
    double timeWidth = CMTimeGetSeconds(self.player.seekableRange.duration);
    
    CGFloat currentOffset = (currentTime * scrubWidth ) / timeWidth ;
    
    if (isnan(currentOffset))
    {
        currentOffset = 0;
    }
    
    [self.scrubbCollectionView.collectionView setContentOffset:CGPointMake(currentOffset, 0) animated:NO];
    
}


-(void) view:(SPPlayerControlView*) view seekingDidStartWithPlaybackTime:(CMTime) time{

    [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
        self.scrubbCollectionView.view.alpha = 1.0;
    } completion:nil];
}


-(void) view:(SPPlayerControlView*) view seekingDidFinishWithPlaybackTime:(CMTime) time
{
 
    [[self controlView] changeViewToLoadingMode];
 
    
    [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
        self.scrubbCollectionView.view.alpha = 0.0;
    } completion:nil];
    [self.player seekToTime:time completionHandler:^(BOOL finished) {
        NSLog(@"seekToTime complete........");
        [[self controlView] changeViewToPlayingMode];
    }];
}

/*Buttons delegate*/
-(void)view:(SPPlayerControlView*) view didReceiveLANGButtonTouch:(UIButton*) langButton
{
    BOOL  isCreated = [self loadMetadataMetadataTableViewIfneeded];
    
    self.metadataContainerView.hidden = !self.metadataContainerView.isHidden;
    
    if (isCreated == NO) {
        
        [self.metadataTableViewController reloadDataForItem:_player.currentItem];
    }
}


-(void)view:(SPPlayerControlView*) view didReceiveVolumenButtonTouch:(UIButton*) volButton
{
 
    SPVolumeViewController *volumeViewController = [[SPVolumeViewController alloc] initWithNibName:@"SPVolumeViewController" bundle:nil];
    [self addChildViewController:volumeViewController];
    UIView *volumeView = volumeViewController.view;
    [_metadataContainerView addSubview:volumeViewController.view];
    [volumeViewController didMoveToParentViewController:self];
    
    _metadataContainerView.hidden = NO;
    [self.metadataContainerView  addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[volumeView(72)]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(volumeView)]];
    [self.metadataContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[volumeView(241)]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(volumeView)]];
}



-(BOOL) loadMetadataMetadataTableViewIfneeded
{

    if (_metadataTableViewController == nil)
    {
        self.metadataTableViewController = [[MetadataTableViewController alloc] initWithAVPlayerItem:_player.currentItem];
        _metadataTableViewController.delegate = self;
        
        MetadataTableViewController *controller = _metadataTableViewController;
        
        NSDictionary *views = @{@"tableViews":controller.view};
        [controller.view setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self addChildViewController:controller];
        [_metadataContainerView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
        
        
        [self.metadataContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.metadataContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[tableViews]-(0)-|" options:0 metrics:nil views:views]];
        [self.metadataContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[tableViews]-(0)-|" options:0 metrics:nil views:views]];
        [self.metadataContainerView layoutIfNeeded];
        return YES;
    }
    return NO;
}

-(void) addMetadataView {
    
  
    


}
#pragma mark -
#pragma mark MetadataTableViewController Delegates

-(void) metadataTableViewController:(MetadataTableViewController*) controller didSelectCloseCaptionOption:(BOOL)enabled
{

    self.player.closedCaptionDisplayEnabled = enabled;
}

#pragma mark -
#pragma ThumbsCollection 

-(void) loadScrubbCollectionViewIfNeeded
{
    if (!_scrubbCollectionView) {
        self.scrubbCollectionView = [[PSScrubbingCollectionViewController alloc] initWithNibName:@"PSScrubbingCollectionViewController" bundle:nil];
    }
}

-(void) showScrubbingThumbnails
{
    [self loadScrubbCollectionViewIfNeeded];
    
    if (_scrubbCollectionView.view.superview == nil) {
        
        NSDictionary *views = @{@"collectionView":_scrubbCollectionView.view};
        [_scrubbCollectionView.view setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.scrubbCollectionView.view.alpha = 0.0;
        [self addChildViewController:_scrubbCollectionView];
        [self.thumbsContainer addSubview:_scrubbCollectionView.view];
        [_scrubbCollectionView didMoveToParentViewController:self];
        
        [self.thumbsContainer  addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[collectionView]-(0)-|" options:0 metrics:nil views:views]];
        [self.thumbsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[collectionView]-(0)-|" options:0 metrics:nil views:views]];
        [self.thumbsContainer layoutIfNeeded];
    }
 
}

@end

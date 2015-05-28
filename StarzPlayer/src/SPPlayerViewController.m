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
// Accedo Utils
#import "UIButton+Player.h"
// Views
#import "SPContainerView.h"
// Style
#import "SPPlayerUIStyle.h"


#define HIDE_TIME_PERIOD 5.0

#ifdef DEBUG
#define LOGGIN_LABEL_TAG 731
#endif


@interface SPPlayerViewController ()
{
    PTQoSProvider *qosProvider;

}

@property (nonatomic, strong) PTMediaPlayer *player;
@property (nonatomic, strong) NSTimer * hideUIElementsTimer;

/*
 View Containes for the differen view Controllers
 */
@property (nonatomic, weak) IBOutlet SPPlayerControlView *controlView;
@property (weak, nonatomic) IBOutlet UIView *playerContainerView;           //  --> PTMediaPlayer
@property (weak, nonatomic) IBOutlet SPContainerView *thumbsContainer;      //  --> PSScrubbingCollectionViewController
@property (weak, nonatomic) IBOutlet SPContainerView *volumenContainer;     //  --> SPVolumeViewController
@property (weak, nonatomic) IBOutlet SPContainerView *topControlsContainer;
@property (nonatomic, weak ) IBOutlet SPContainerView *metadataContainerView; // --> SubTitle and Audios Table View Controller
@property (nonatomic, strong) NSMutableArray *containerViewsArray;
@property (nonatomic, weak) UIView *visibleElement;

@property (nonatomic, strong) SPContainerView *episodeSelectorView;

/* UIElements in top container*/
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *mainTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *episodeSelectorButton;


/*
 Constrains for addjusting the size to iphone view
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *volumeContainerHeightConstrain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *volumenContainerWidthConstrain;

/*
 Controllers for the different features of the playert
 */
@property (strong, nonatomic)   SPVolumeViewController *volumeViewController;
@property (strong, nonatomic)   PSScrubbingCollectionViewController *scrubbCollectionView;
@property (nonatomic, strong)   MetadataTableViewController *metadataTableViewController;
@property (nonatomic, strong)   SPPlayerUIStyle * uiPropertiesStyle;

@end

@implementation SPPlayerViewController
#pragma mark - Initialization

-(instancetype) initWithVideoItem:(PTSVideoItem *) videoItem andStyle:(SPPlayerUIStyle*) uiStyler;
{
    self = [super init];
    if (self) {
        _currentItem = videoItem;
        _containerViewsArray = [@[] mutableCopy];
        _uiPropertiesStyle = uiStyler;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
   
    if (self) {
        _containerViewsArray = [@[] mutableCopy];
        _uiPropertiesStyle = [[SPPlayerUIStyle alloc] init];

    }
    return self;
}
- (void)qosSetup
{
    qosProvider = [[PTQoSProvider alloc] initWithPlayer:self.player];
    [self addLogginLabel];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
#warning  TODO
}

-(void) dealloc
{
    [self.hideUIElementsTimer invalidate];
    [self stopObservingAdobeNotifications];
}

#pragma mark -  ViewController Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setUp];
    
    [self addScrubbingThumbnailsToView];
#warning FER: OJO
    [self view:nil didReceiveVolumenButtonTouch:nil];
   
}

- (void)bringControlViewsToFrontMostPosition
{
    [self.playerContainerView bringSubviewToFront:_topControlsContainer];
    [self.playerContainerView bringSubviewToFront:_controlView];
}


-(void) setUp
{
    [_containerViewsArray addObjectsFromArray:@[_metadataContainerView,_thumbsContainer,_volumenContainer,_topControlsContainer,_controlView]];
    
    if (LEFTTORIGHTLANG)
    {
        [self.backButton setProvidedAssetAsImage:IS_IPAD ? @"ico_arrowleft_32_c1_": @"ico_arrowleft_24_c1_"];
    }
    else
    {
        [self.backButton setProvidedAssetAsImage:IS_IPAD ? @"ico_arrowright_32_c1_": @"ico_arrowright_24_c1_"];
    }
    [self setupAppearence];
}

-(void) setupAppearence
{
    [_mainTitleLabel setFont:[_uiPropertiesStyle fontForTimeLabel]];
    [_mainTitleLabel setTintColor:[_uiPropertiesStyle tintColorForTitleLabel]];
    
    [_subtitleLabel setFont:[_uiPropertiesStyle fontForSutimeLabel]];
    [_subtitleLabel setTintColor:[_uiPropertiesStyle tintColorForSubtitleLabel]];
    
 
    [_controlView setupColorInLangButton:[_uiPropertiesStyle titleColorForLangButtonStateNormal] forState:UIControlStateNormal];
    [_controlView setupColorInLangButton:[_uiPropertiesStyle titleColorForLangButtonStateHighlighted] forState:UIControlStateHighlighted];
    [_controlView setupFontInLanButton:[_uiPropertiesStyle fontForLangButton]];
    [_controlView setControlViewColor:[_uiPropertiesStyle backgroundColorForControlView]];
    [_controlView setupFontInTimeLabel:[_uiPropertiesStyle fontForTimeLabel]];
}


-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

-(void) startHideElementsTimer
{
    [self log:@" =============== Start Timer ================="];
    if (self.hideUIElementsTimer)
    {
        [self.hideUIElementsTimer invalidate];
        self.hideUIElementsTimer = nil;
    }
    self.hideUIElementsTimer = [NSTimer timerWithTimeInterval:HIDE_TIME_PERIOD target:self selector:@selector(handleTimerCallback:) userInfo:nil repeats:NO];
    [self.hideUIElementsTimer setTolerance:1.0];
    [[NSRunLoop currentRunLoop] addTimer:_hideUIElementsTimer forMode:NSRunLoopCommonModes];
}

- (void) handleTimerCallback:(NSTimer*) timer
{
    [self hideUIElements];
}


-(void) stopUIHideTimer
{
    [self log:@" =============== invalidate Timer ================="];
    [self.hideUIElementsTimer invalidate];
}



#pragma mark - Player Actions
#pragma mark - Public Actions
- (void) playVideo:(PTSVideoItem *)item
{
    self.currentItem = item;
    [_scrubbCollectionView fetchScrubbingImagesForULR:_currentItem.stripContentUrl];
    
    if (self.player)
    {
        [self.player stop];
        [self.player reset];
    }
    
    [self playVideo];
    [self setTextInInformationLabels:item];
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

- (void) stopVideo
{
    if (self.player)
    {
        [self.player stop];
    }
}

-(void) releasePlayer
{
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

/*
    Internal methods
 */
#pragma mark - Private Actions
- (void) playVideo
{
    NSURL *url = [NSURL URLWithString:_currentItem.url];
    if (url == nil) // invalid url
    {
        [self closePlayer:nil];
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


- (void) createMediaPlayer:(PTMediaPlayerItem *)item
{
    [PTSDKConfig setSubscribedTags:[NSArray arrayWithObject:@"#EXT-OATCLS-SCTE35"]];
    [PTMediaPlayer enableDebugLog:NO];
    
    self.player = [PTMediaPlayer playerWithMediaPlayerItem:item];
    
    [self addObserversToAdobeNotifications];
    
    self.player.currentTimeUpdateInterval = 1000;
    self.player.allowsAirPlayVideo = NO;                               // enable airplay
    self.player.videoGravity = PTMediaPlayerVideoGravityResizeAspect;   // set the video display properties
        self.player.muted = NO;
    self.player.autoPlay = YES;
    
   
   
    UIView *playerView =_player.view;
    playerView.translatesAutoresizingMaskIntoConstraints = NO;
    [playerView setBackgroundColor:[UIColor blackColor]];
 
    [self.playerContainerView addSubview:playerView];
    [self bringControlViewsToFrontMostPosition];
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
    


    [self qosSetup]; // attach player to qosProvider

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
    [self.player play];
}


- (void) logDRMError:(NSString*)str :(DRMError*)error
{
    NSLog(@"[%@:] major:[%ld] minor:[%ld] string: [%@] NSError:[%@]", str, (long)error.majorError, (long)error.minorError, error.errorString, error.platformError);
};


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
             // please don't use the error object here, there is an exception thrown in the PSDK that will be addressed soon.
             // use player.error object instead
             [self log:@"=============== loadDRMMetadataWithCompletionHandler ERROR:  media player item error code[%ld], description[%@]", (long)self.player.error.code, self.player.error.description];
             
         }
         ];
    }
    else
    {
        [self log:@"===============  DRM Error: Could not start Authentication, no player instance or no current media player item created!"];
    }
    
}


- (PTMetadata *) createMetadata
{
    PTMetadata* metadata = [[PTMetadata alloc] init];
#warning TODO:
//TODO: check wtf is this for ?'
    
    //ABR metadata
//    int initialBR = 41457;
//    int initialBR = 2500000;
//    int minBR = 250000;
//    int maxBR = 2000000;
//    
//    PTABRControlParameters *abrMetaData = [[PTABRControlParameters alloc] initWithABRControlParams:initialBR minBitRate:minBR maxBitRate:maxBR];
//    [metadata setMetadata:abrMetaData forKey:PTMBRResolvingMetadataKey];
    
    return metadata;
}

#pragma mark -
#pragma mark View Actions

- (IBAction) closePlayer:(id)sender
{
    if ([self.delgate respondsToSelector:@selector(playerViewControllerWillDissmissed:)]) {
     
        [self.delgate playerViewControllerWillDissmissed:self];
    }
   
    [self releasePlayer];
    
    if ([self.delgate respondsToSelector:@selector(playerViewControllerReadyToBeDissmissed:)]) {
        [self.delgate playerViewControllerReadyToBeDissmissed:self];
    }else{
       
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}


- (IBAction)showEpisodeSelector:(id)sender
{
    [self stopUIHideTimer];
    
    if ([self.dataSource respondsToSelector:@selector(playerViewController:viewForEpisodeSelectorForVideoItem:)]) {
        
        UIView *contentView = [self.dataSource playerViewController:self viewForEpisodeSelectorForVideoItem:self.currentItem];
        contentView.translatesAutoresizingMaskIntoConstraints  = NO;
        [self loadEpisodeSelectorContainerViewFrorView:contentView];
        [_episodeSelectorView setDisplayStatus:[self.episodeSelectorView isDisplayed]];
        [self markViewAsVisible:_episodeSelectorView];
    }
}


-(void) loadEpisodeSelectorContainerViewFrorView:(UIView*)view {
    
    if (!self.episodeSelectorView) {
        
        SPContainerView* episodeSelectorView =[[SPContainerView alloc] init];
        episodeSelectorView.translatesAutoresizingMaskIntoConstraints  = NO;
        [episodeSelectorView setBackgroundColor:[UIColor lightGrayColor]];
        
        [self.view addSubview:episodeSelectorView];
        
        CGPoint postion = [self positionForEpisodeSelectorView];
        
        NSDictionary *metrics = @{@"viewHeight":@200.0,@"viewWidth":@300.0,@"padding":@15.0,@"rightPaddin":@(postion.x-300),@"topPosition":@(postion.y),@"lowPriority":@(UILayoutPriorityDefaultLow),@"highPriority":@(UILayoutPriorityDefaultHigh)};
        NSDictionary *views = NSDictionaryOfVariableBindings(episodeSelectorView);
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10@200-[episodeSelectorView(viewWidth@highPriority)]-padding@highPriority-|" options:NSLayoutFormatAlignAllLeft metrics:metrics views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topPosition@highPriority-[episodeSelectorView(viewHeight@highPriority)]->=0@lowPriority-|" options:NSLayoutFormatAlignAllLeft metrics:metrics views:views]];
        self.episodeSelectorView =episodeSelectorView;
    
        [episodeSelectorView setDisplayStatus:YES];
    }

}


-(CGPoint) positionForEpisodeSelectorView
{
    CGRect btnFrame =  self.episodeSelectorButton.frame;
    CGFloat secureMargin = 10.0;
    return CGPointMake(CGRectGetMaxX(btnFrame), CGRectGetMaxY(btnFrame)+secureMargin);
}

/*
 
 */
-(void) hideViewContainer:(UIView*) viewContainer animated:(BOOL) animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.8 animations:^{
              viewContainer.alpha = 0.0f;
        }];
    }
    else{
        viewContainer.alpha = 0.0f;
    }
}


-(void) showViewContainer:(UIView*) viewContainer animated:(BOOL) animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.8 animations:^{
            viewContainer.alpha = 1.0f;
        }];
    }
    else{
        viewContainer.alpha = 1.0f;
    }
}

-(void) setTextInInformationLabels:(PTSVideoItem*) item
{
    [self.subtitleLabel setText:item.description];
    [self.mainTitleLabel setText:item.title];

}

#pragma mark  Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];

    [self startHideElementsTimer];
    
    UITouch *any = [touches anyObject];
    CGRect centerFrame =CGRectInset(self.view.frame, 50, 100);
    
    if ( CGRectContainsPoint(centerFrame, [any locationInView:self.view])) {
        [self showViewContainer:_controlView animated:YES];
        [self showViewContainer:_topControlsContainer animated:YES];
      
    }
}


-(void) hideUIElements
{
    [_containerViewsArray enumerateObjectsUsingBlock:^(SPContainerView *obj, NSUInteger idx, BOOL *stop) {
        [obj setDisplayStatus:NO];// set all objects to Not Visible
    }];
    
    if (self.episodeSelectorView) {
        [UIView animateWithDuration:0.2 animations:^{
            self.episodeSelectorView.alpha = 1.0;
        } completion:^(BOOL finished) {
            [self.episodeSelectorView removeFromSuperview];
        }];
    }
}


-(void) markViewAsVisible:(SPContainerView*) container
{
    if (!_visibleElement) {
        self.visibleElement = container;
    }else {
        
        if (![_visibleElement isEqual:container]) {
            [(SPContainerView*)_visibleElement setDisplayStatus:NO];
        }
        self.visibleElement = container;
    }
}

#pragma mark - Notification
#pragma mark -

- (void) addObserversToAdobeNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMediaPlayerStatusChange:) name:PTMediaPlayerStatusNotification object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMediaPlayerTimeChange:) name:PTMediaPlayerTimeChangeNotification object:self.player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMediaPlayerItemPlayStarted:) name:PTMediaPlayerPlayStartedNotification object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMediaPlayerItemPlayCompleted:) name:PTMediaPlayerPlayCompletedNotification object:self.player];
}

- (void) stopObservingAdobeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
              [[self controlView] changeViewToLoadingMode];
       
                [self startHideElementsTimer];
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
#warning TODO: check the error
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
    if ([self.dataSource respondsToSelector:@selector(playerViewController:viewToDisplayAfterVideoPlayback:)]) {
        UIView *postPlaybackView = [self.dataSource playerViewController:self viewToDisplayAfterVideoPlayback:_player.currentItem];
         
    }
}


- (void) onMediaPlayerTimeChange:(NSNotification *)notification
{
    CMTimeRange seekableRange = self.player.seekableRange;
    [_controlView updateViewForTimeRange:seekableRange andCurrentPosition:self.player.currentItem.currentTime];
    [self logVideoDetailsToLabel:qosProvider.playbackInformation];
}



#pragma mark - SPPlayerControlView Delegate
#pragma mark -

#pragma mark  Play Button methods
- (void)view:(SPPlayerControlView*) view didReceivePlayTouch:(UIButton*) button
{
    [self.player  play];
}

- (void)view:(SPPlayerControlView*) view didReceivePauseTouch:(UIButton*) button
{
    [self pauseVideo];
}


/*Slider delegate*/
#pragma mark  Slider Related methods
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
    
    [self stopUIHideTimer];
    self.thumbsContainer.alpha = 1.0;
    [self.volumenContainer setDisplayStatus:NO];
    [self.metadataContainerView setDisplayStatus:NO];
}


-(void) view:(SPPlayerControlView*) view seekingDidFinishWithPlaybackTime:(CMTime) time
{
 
    [[self controlView] changeViewToLoadingMode];
 
    [UIView animateWithDuration:0.2 delay:0.2 options:0 animations:^{
        self.thumbsContainer.alpha = 0.0;
    } completion:nil];
    [self.player seekToTime:time completionHandler:^(BOOL finished) {
        NSLog(@"seekToTime complete........");
        [[self controlView] changeViewToPlayingMode];
        [self.player play];
    }];
}

/*Buttons delegate*/
#pragma mark  Lang Button methods
-(void)view:(SPPlayerControlView*) view didReceiveLANGButtonTouch:(UIButton*) langButton
{
    [self stopUIHideTimer];
    
    BOOL  isCreated = [self loadMetadataMetadataTableViewIfneeded];
    
    if (isCreated == NO) {
        
        [self.metadataTableViewController reloadDataForItem:_player.currentItem];
    }
    [self.metadataContainerView setDisplayStatus:![_metadataContainerView isDisplayed]]; // control same button click to hide
    [self markViewAsVisible:_metadataContainerView];
}


-(BOOL) loadMetadataMetadataTableViewIfneeded
{
    
    if (_metadataTableViewController == nil)
    {
        self.metadataTableViewController = [[MetadataTableViewController alloc] initWithAVPlayerItem:_player.currentItem];
        _metadataTableViewController.delegate = self;
        
        [_metadataTableViewController setHeaderFont:[_uiPropertiesStyle fontForMetadataTableHeader]];
        [_metadataTableViewController setHeaderTextColor:[_uiPropertiesStyle tableHeaderTextColor]];
        MetadataTableViewController *controller = _metadataTableViewController;
        
        NSDictionary *views = @{@"tableViews":controller.view};
        [controller.view setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self addChildViewController:controller];
        [_metadataContainerView addSubview:controller.view];
        [controller configureBackgroundColorInTables:[_uiPropertiesStyle backgroundColorForMetadataTablesViews]];
        [controller didMoveToParentViewController:self];
        
        
        [self.metadataContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.metadataContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[tableViews]-(0)-|" options:0 metrics:nil views:views]];
        [self.metadataContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[tableViews]-(0)-|" options:0 metrics:nil views:views]];
        [self.metadataContainerView layoutIfNeeded];
        
        return YES;
    }
    return NO;
}

#pragma mark - Volumen Button related methods

-(void)view:(SPPlayerControlView*) view didReceiveVolumenButtonTouch:(UIButton*) volButton
{
    [self stopUIHideTimer];
    [self loadVolumenViewControllerInContainerIfNeeded];

    [self.volumenContainer setDisplayStatus:![_volumenContainer isDisplayed]];
    [self markViewAsVisible:_volumenContainer];
    
}


-(BOOL) loadVolumenViewControllerInContainerIfNeeded
{
    
    if(_volumeViewController) return NO; // not created
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.volumeContainerHeightConstrain.constant = 172;
        self.volumenContainerWidthConstrain.constant = 40;
        [self.volumenContainer layoutIfNeeded];
    }
    
    self.volumeViewController= [[SPVolumeViewController alloc] initWithNibName:@"SPVolumeViewController" bundle:nil];
    [_volumeViewController setDelegate:self];
    [self addChildViewController:_volumeViewController];
    UIView *volumeView = _volumeViewController.view;
    [volumeView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_volumenContainer addSubview:_volumeViewController.view];
    [_volumeViewController didMoveToParentViewController:self];
    
    
    [self.volumenContainer  addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[volumeView]-(0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(volumeView)]];
    [self.volumenContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[volumeView]-(0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(volumeView)]];

    return YES;
}

#pragma mark - MetadataTableViewController Delegates

-(void) metadataTableViewController:(MetadataTableViewController*) controller didSelectCloseCaptionOption:(BOOL)enabled
{
    self.player.closedCaptionDisplayEnabled = enabled;
}


#pragma mark - ThumbsCollection

-(void) loadScrubbCollectionViewIfNeeded
{
    if (!_scrubbCollectionView) {
        self.scrubbCollectionView = [[PSScrubbingCollectionViewController alloc] initWithNibName:@"PSScrubbingCollectionViewController" bundle:nil];
    }
}

-(void) addScrubbingThumbnailsToView
{
    [self loadScrubbCollectionViewIfNeeded];
    
    if (_scrubbCollectionView.view.superview == nil) {
        
        NSDictionary *views = @{@"collectionView":_scrubbCollectionView.view};
        [_scrubbCollectionView.view setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self addChildViewController:_scrubbCollectionView];
        [self.thumbsContainer addSubview:_scrubbCollectionView.view];
        [_scrubbCollectionView didMoveToParentViewController:self];
        
        [self.thumbsContainer  addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[collectionView]-(0)-|" options:0 metrics:nil views:views]];
        [self.thumbsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[collectionView]-(0)-|" options:0 metrics:nil views:views]];
        [self.thumbsContainer layoutIfNeeded];
        
        
    }
 
}

#pragma mark - SPPlayerViewControllerChildControllersProtocol
/*
 Called from the child viewControllers
 */
-(void) childViewController:(UIViewController *)viewController didCompleteActionWithMessage:(PSPlayerMessage)messageType{

    switch (messageType) {
        case PSPlayerMessageMute:
            [self.player setVolume:0.0];
            break;
        case PSPlayerMessageUnMute:
            [self.player setVolume:[AVAudioSession sharedInstance].outputVolume];
        default:
            break;
    }
}

#pragma mark - UTILS and Debugger
- (void) log:(NSString*)format, ...
{
    if(DEBUG) //logging could be turned on/off here
    {
        va_list args;
        va_start(args,format);
        NSLogv(format, args);
        va_end(args);
    }
}


-(void) addLogginLabel
{
#ifdef DEBUG
    // Show playback stats
    UILabel *logingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame), 100.0, 200.0)];
    [logingLabel setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:0.2]];
    logingLabel.numberOfLines = 10;
    [logingLabel setTextColor:[UIColor whiteColor]];
    [logingLabel setTag:LOGGIN_LABEL_TAG];
    
    
    logingLabel.translatesAutoresizingMaskIntoConstraints  = NO;
    [self.view addSubview:logingLabel];
    
    
    NSDictionary *metrics = @{@"viewHeight":@250.0,@"viewWidth":@200.0,@"padding":@15.0,@"topPosition":@(CGRectGetHeight(self.view.frame) *0.2),@"lowPriority":@(UILayoutPriorityDefaultLow),@"highPriority":@(UILayoutPriorityDefaultHigh)};
    NSDictionary *views = NSDictionaryOfVariableBindings(logingLabel);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10@highPriority-[logingLabel(viewWidth@highPriority)]-padding@lowPriority-|" options:NSLayoutFormatAlignAllLeft metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topPosition@highPriority-[logingLabel(viewHeight@highPriority)]->=0@lowPriority-|" options:NSLayoutFormatAlignAllLeft metrics:metrics views:views]];
    
#endif
    
}
-(void) logVideoDetailsToLabel:(PTPlaybackInformation*) playbackInfo
{
#ifdef DEBUG
    UILabel *logLabel =(UILabel*)[self.view viewWithTag:LOGGIN_LABEL_TAG];
    NSString *infoString = [NSString stringWithFormat:@"Status: %ld \n, BitRate (Observed): %f bits \nBitrate (Server): %f bits\nTs Downloaded: %ld Dropped: ( %ld ) \nTimeToStart ( %f )\nBufferinTime: %f\nBytesTransfered: ( %lld )", _player.status,playbackInfo.observedBitrate, playbackInfo.indicatedBitrate,playbackInfo.numberOfSegmentsDownloaded, (long)playbackInfo.numberOfDroppedVideoFrames,  playbackInfo.timeToStart ,playbackInfo.totalBufferingTime,playbackInfo.numberOfBytesTransferred];
    [logLabel setText:infoString];
#endif
}

@end

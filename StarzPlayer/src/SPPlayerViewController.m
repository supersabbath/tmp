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
// SPMoviePlayer
#import "SPMoviePlayerController.h"
// Accedo Utils
#import "UIButton+Player.h"
// Views
#import "SPContainerView.h"

// Style
#import "SPPlayerUIStyle.h"

//DEpendencys
#import "SPPlayerNotification.h"
#import "SPPlayerControllerObserverProtocol.h"
#import <MBProgressHUD.h>

// used in the timer
#define HIDE_TIME_PERIOD 5.0

#ifdef DEBUG
#define LOGGIN_LABEL_TAG 731
#endif





#ifdef UI_USER_INTERFACE_IDIOM
#define IS_IPAD_IDIOM \
(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#else
#define IS_IPAD_IDIOM NO
#endif

#include <math.h>       /* fmod */



/* Extension Private iVars*/

@interface SPPlayerViewController ()  <SPMoviewPlayerControllerObserver>
{
    PTQoSProvider *qosProvider;
    BOOL wasPlayingBeforeSuspend;
    BOOL wasPlaybackNotificationSent; // for resume after home button is touch
    SPMoviePlayerController *playerController;
}



@property (nonatomic, strong) NSTimer * hideUIElementsTimer;
@property (copy) PlayerInitializationCompletion addPlayerViewBlock;
/*
 View Containes for the differen view Controllers
 */
@property (unsafe_unretained, nonatomic) IBOutlet SPContainerView *centerControlsContainer;
@property (nonatomic, weak) IBOutlet SPPlayerControlView *controlsContainerView;


@property (weak, nonatomic) IBOutlet SPContainerView *thumbsContainer;      //  --> PSScrubbingCollectionViewController
@property (weak, nonatomic) IBOutlet SPContainerView *volumenContainer;     //  --> SPVolumeViewController
@property (weak, nonatomic) IBOutlet SPContainerView *topControlsContainer;
@property (nonatomic, weak ) IBOutlet SPContainerView *metadataContainerView; // --> SubTitle and Audios Table View Controller
@property (nonatomic, strong) NSMutableArray *containerViewsArray;
@property (nonatomic, weak) SPContainerView *visibleElement;

@property (nonatomic, strong) SPContainerView *episodeSelectorContainerView;
@property (nonatomic, strong) SPContainerView *postPlaybackView;
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
        _uiPropertiesStyle = uiStyler;
        _containerViewsArray = [@[] mutableCopy];
        [self configurePlayerViewAddingBlock];
        
    }
    return self;
}

-(void) configurePlayerViewAddingBlock
{
    
    SPPlayerViewController * __weak unretainedSelf = self;
    self.addPlayerViewBlock =^(UIView *playerView) {
 
        [unretainedSelf.playerContainerView insertSubview:playerView atIndex:0];
        [unretainedSelf bringControlViewsToFrontMostPosition];
        [unretainedSelf.playerContainerView addConstraint:[NSLayoutConstraint constraintWithItem:playerView
                                                                             attribute:NSLayoutAttributeWidth
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:unretainedSelf.playerContainerView
                                                                             attribute:NSLayoutAttributeWidth
                                                                            multiplier:1.0
                                                                              constant:0]];
        
        
        [unretainedSelf.playerContainerView addConstraint:[NSLayoutConstraint constraintWithItem:playerView
                                                                             attribute:NSLayoutAttributeHeight
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:unretainedSelf.playerContainerView
                                                                             attribute:NSLayoutAttributeHeight
                                                                            multiplier:1.0
                                                                              constant:0]];
        
        // Center horizontally
        [unretainedSelf.playerContainerView addConstraint:[NSLayoutConstraint constraintWithItem:playerView
                                                                             attribute:NSLayoutAttributeCenterX
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:unretainedSelf.playerContainerView
                                                                             attribute:NSLayoutAttributeCenterX
                                                                            multiplier:1.0
                                                                              constant:0.0]];
        
        // Center vertically
        [unretainedSelf.playerContainerView addConstraint:[NSLayoutConstraint constraintWithItem:playerView
                                                                             attribute:NSLayoutAttributeCenterY
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:unretainedSelf.playerContainerView
                                                                             attribute:NSLayoutAttributeCenterY
                                                                            multiplier:1.0
                                                                              constant:0.0]];
        
    };
}
//- (void) applicationWillResignActive
//{
//    wasPlayingBeforeSuspend = self.player.status == PTMediaPlayerStatusPlaying;
//    [self.player pause];
//}
//
//- (void) applicationDidBecomeActive
//{
//    if (wasPlayingBeforeSuspend)
//    {
//        [self.player play];
//    }
//}

/*
     // _scrubbCollectionView memory is managed in its onw viewcontroller
 */
- (void) didReceiveMemoryWarning
{
    
    [super didReceiveMemoryWarning];

    if  ([self isContanerVisible:_episodeSelectorContainerView] == NO)
    {
        [self.episodeSelectorContainerView removeFromSuperview ];
        self.episodeSelectorContainerView = nil;
    }
    
    if ([self isContanerVisible:_metadataContainerView] == NO) {
        [_metadataTableViewController removeFromParentViewController];
        [_metadataTableViewController.view removeFromSuperview];
        self.metadataTableViewController = nil;
        
    }
    if ([self isContanerVisible:_volumenContainer] == NO ) {
        [_volumeViewController removeFromParentViewController];
        [_metadataTableViewController.view removeFromSuperview];
        self.volumeViewController = nil;
    }
 
    if ([self isContanerVisible:_episodeSelectorContainerView] == NO)
    {
        [self.episodeSelectorContainerView removeFromSuperview];
        self.episodeSelectorContainerView = nil;
    }

   
    if ( [self isContanerVisible:_postPlaybackView] ) {
        
        [self.postPlaybackView removeFromSuperview];
        self.postPlaybackView = nil;
    }
   
}


-(BOOL) isContanerVisible:(SPContainerView*) element
{
    BOOL isVisible =  [element isEqual:_visibleElement];

    return isVisible;
}


-(void) dealloc
{
    [self.hideUIElementsTimer invalidate];
    [self clearCurrentItemAssociatedViews]; // to prevent a crash from the table views
    [self stopObservingNotifications];
}


#pragma mark -  ViewController Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configUI];

    [self addScrubbingThumbnailsToView];
    [self setTextInInformationLabels:_currentItem];
    [self bringControlViewsToFrontMostPosition];
    
}

- (void)bringControlViewsToFrontMostPosition
{
    [self.playerContainerView bringSubviewToFront:_controlsContainerView];
    [_controlsContainerView setDisplayStatus:YES];
    [self.playerContainerView bringSubviewToFront:_topControlsContainer];
    [_topControlsContainer setDisplayStatus:YES];
    [self.playerContainerView bringSubviewToFront:self.centerControlsContainer];
    [self.centerControlsContainer setDisplayStatus:YES];
}


-(void) configUI
{
    [_containerViewsArray addObjectsFromArray:@[_metadataContainerView,_thumbsContainer,_volumenContainer,_topControlsContainer,self.controlsContainerView]];
    
    if ( UIUserInterfaceLayoutDirectionLeftToRight == [UIApplication sharedApplication].userInterfaceLayoutDirection)
    {
        [self.backButton setProvidedAssetAsImage:IS_IPAD_IDIOM ? @"ico_arrowleft_32_c1_": @"ico_arrowleft_24_c1_"];
    }
    else
    {
        [self.backButton setProvidedAssetAsImage:IS_IPAD_IDIOM ? @"ico_arrowright_32_c1_": @"ico_arrowright_24_c1_"];
    }
    [self.episodeSelectorButton setProvidedAssetAsBackgroundImage:IS_IPAD_IDIOM ? @"ico_episodes_32_c1_": @"ico_episodes_36_c1_"];
    [self setupAppearence];
 
    [self configureForContentType:_currentItem.contentType];
}




-(void) setupAppearence
{
    [_subtitleLabel setTintColor:[_uiPropertiesStyle tintColorForMainTitleLabel]];
    [_subtitleLabel setTextColor:[_uiPropertiesStyle tintColorForMainTitleLabel]];
    [_subtitleLabel setFont:[_uiPropertiesStyle fontForSutimeLabel]];
    
    [_mainTitleLabel setFont:[_uiPropertiesStyle fontForMainTitleLabel]];
    [_mainTitleLabel setTintColor:[_uiPropertiesStyle tintColorForSubtitleLabel]];
    [_mainTitleLabel setTextColor:[_uiPropertiesStyle tintColorForMainTitleLabel]];
    // TIME LABELS
    [self.controlsContainerView setupFontInTimeLabel:[_uiPropertiesStyle fontForTimeLabel] withColor:[_uiPropertiesStyle tintColorForTimeLabel]];
 
    // LANG Button
    [self.controlsContainerView setupColorInLangButton:[_uiPropertiesStyle titleColorForLangButtonStateNormal] forState:UIControlStateNormal];
    [self.controlsContainerView setupColorInLangButton:[_uiPropertiesStyle titleColorForLangButtonStateHighlighted] forState:UIControlStateHighlighted];
    [self.controlsContainerView setupFontInLanButton:[_uiPropertiesStyle fontForLangButton]];
    
    [self.controlsContainerView setControlViewColor:[_uiPropertiesStyle backgroundColorForControlView]];
    
}

-(void) configureForContentType:(PTSContentType) conteType
{
    
    switch (conteType) {
        case PTSEpisodeContent:
            [_episodeSelectorButton setHidden:NO];
            break;
        case PTSTrailerContent:
            [_episodeSelectorButton setHidden:YES];
            break;
        case PTSMovieContent:
            [_episodeSelectorButton setHidden:YES];
            break;
    }
}


-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

-(void) startHideElementsTimer
{
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
    [self.hideUIElementsTimer invalidate];
}


-(void) clearCurrentItemAssociatedViews
{
    [_episodeSelectorContainerView removeFromSuperview];
    _episodeSelectorContainerView = nil;
    
    [_postPlaybackView removeFromSuperview];
    _postPlaybackView = nil;
}

#pragma mark - Player Actions
#pragma mark - Public Actions
- (void) playCurrentVideo
{
    [_scrubbCollectionView fetchScrubbingImagesForULR:_currentItem.stripContentUrl];
    [self playVideo];
}


- (void) playVideo:(PTSVideoItem *)item
{
    self.currentItem = item;
    [self loadScrubbCollectionViewIfNeeded];
    [_scrubbCollectionView fetchScrubbingImagesForULR:_currentItem.stripContentUrl];
    [self setTextInInformationLabels:item];
    [self playVideo];
}


- (void) stopVideo
{
    [playerController stopVideo];
}

-(void) releaseMoviePlayerController
{
    [playerController releasePlayer];
    playerController = nil;
}

-(void) moveToInitialPosition
{
    if (_currentItem.initialPosition > 10) {
         
        [playerController seekToTime:CMTimeMakeWithSeconds(_currentItem.initialPosition,100000) completionHandler:^(BOOL finished) {
            
            if (finished) {
                
                [self.controlsContainerView changeViewToPlayingMode];
            }
        }];
    }
}

-(BOOL) isPlayerControllerLive
{
    return [playerController isLive];
}

-(CMTime) currentPlaybackTime {
    return playerController.currentTime;
}

-(CMTime) videoDuration
{
    return playerController.player.duration;
}
#pragma mark - Private Actions
/*
 Internal methods
 */

- (void) playVideo
{
 
    NSURL *url = [NSURL URLWithString:_currentItem.url];
    if (url == nil) // invalid url
    {
        [self closePlayer:nil];
        return;
    }

    if (playerController)
    {
        [playerController stopVideo];
        [self releaseMoviePlayerController];
    }
    
    playerController = [[SPMoviePlayerController alloc] initWithMediaPlayerItem:_currentItem andViewController:self];
 
    [playerController playCurrentVideo:self.addPlayerViewBlock];
  
}


- (void) logDRMError:(NSString*)str :(DRMError*)error
{
     NSLog(@"[%@:] major:[%ld] minor:[%ld] string: [%@] NSError:[%@]", str, (long)error.majorError, (long)error.minorError, error.errorString, error.platformError);
    [self callDelegateForDRMError:error];
    [self postNotificationForDRMError:error];
};


-(void) postNotificationForDRMError:(DRMError*)error {

    SPPlayerNotification *notification  = [SPPlayerNotification notificationForplayer:self withUserInfo:@{@"videoAsset":_currentItem, @"error":error} andIdentifier:SPPPlayerStatusErrorNotification];

    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

-(void) callDelegateForDRMError:(DRMError*) error
{
    if ([self.delgate respondsToSelector:@selector(playerViewController:willStopDueDRMError:)]) {
        [self.delgate playerViewController:self willStopDueDRMError:error ];
    }
    
}




-(void) changePlayerToDiffentContent:(NSNotification*) notification
{
    [_episodeSelectorContainerView setDisplayStatus:NO];
    [self clearCurrentItemAssociatedViews];
    PTSVideoItem *newItem = [notification object];
    if (newItem) {
        [playerController stopVideo];
        
        [self playVideo:newItem];
    }
}

-(void) refreshPlayerForNewPlaybackItem:(PTSVideoItem *)item {
    
    [_episodeSelectorContainerView setDisplayStatus:NO];
    self.currentItem = item;
    self.visibleElement = nil;
}

#pragma mark -
#pragma mark View Actions

- (IBAction) closePlayer:(id)sender
{
    
    [self postNotificationToObservers:SPPlayerWillStopNotification];
    
    [self postNotificationToObservers:SPPlayerPlaybackWillFinish];
    
    if ([self.delgate respondsToSelector:@selector(playerViewControllerWillDissmissed:)]) {
        
        [self.delgate playerViewControllerWillDissmissed:self];
    }
    
     [self releaseMoviePlayerController]; // this position is important in other to notify the delegate
    
    if ([self.delgate respondsToSelector:@selector(playerViewControllerReadyToBeDissmissed:)]) {
        [self.delgate playerViewControllerReadyToBeDissmissed:self];
    }else{
        
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}


- (IBAction) showEpisodeSelector:(id)sender
{
    [self stopUIHideTimer];
    
    if ([self.dataSource respondsToSelector:@selector(playerViewController:viewForEpisodeSelectorForVideoItem:)]) {
        
        id contentView =  [self.dataSource playerViewController:self viewForEpisodeSelectorForVideoItem:self.currentItem];
        [self loadEpisodeSelectorContainerViewFrorView:contentView];
        [_episodeSelectorContainerView setDisplayStatus:![self.episodeSelectorContainerView isDisplayed]];
        [self markViewAsVisible:_episodeSelectorContainerView];
      
        if ([contentView respondsToSelector:@selector(addableViewHide)]) {
            
            if ([_episodeSelectorContainerView isDisplayed] == NO) {
                [contentView addableViewHide];
            }else  if ([contentView respondsToSelector:@selector(addableViewShow)])  {
                [contentView addableViewShow];
            }
        }
    }
}



/*
 Animates view disappear
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
    [self.subtitleLabel setText:[item.contentDescription uppercaseString] ];
    [self.mainTitleLabel setText:[item.title uppercaseString]];    
}

-(void) addView:(UIView*) view ToContainer:(SPContainerView*) container
{
    view.translatesAutoresizingMaskIntoConstraints  = NO;
    [container addSubview:view];
    //   NSDictionary *metrics = @{@"width":@(CGRectGetWidth(container.frame)),@"height":@(CGRectGetHeight(container.frame))};
    NSDictionary *views = NSDictionaryOfVariableBindings(view);
    [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[view]-(0)-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[view]-(0)-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [self bringControlViewsToFrontMostPosition];
}


-(void) loadEpisodeSelectorContainerViewFrorView:(UIView*)view
{
    
    if (!self.episodeSelectorContainerView) {
        
        SPContainerView* episodeSelectorView =[[SPContainerView alloc] init];
        episodeSelectorView.translatesAutoresizingMaskIntoConstraints  = NO;
        [episodeSelectorView setBackgroundColor:[UIColor clearColor]];
        
        [episodeSelectorView setClipsToBounds:YES];
        [self.view addSubview:episodeSelectorView];
        
        CGPoint postion = [self positionForEpisodeSelectorView];
        if (IS_IPAD_IDIOM) {
            
        NSDictionary *metrics = @{@"viewHeight":@300.0,@"viewWidth":@400.0,@"padding":@15.0,@"rightPaddin":@(postion.x-300),@"topPosition":@(postion.y + 20),@"lowPriority":@(UILayoutPriorityDefaultLow),@"highPriority":@(UILayoutPriorityDefaultHigh)};
        NSDictionary *views = NSDictionaryOfVariableBindings(episodeSelectorView);
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10@200-[episodeSelectorView(viewWidth@highPriority)]-padding@highPriority-|" options:NSLayoutFormatAlignAllLeft metrics:metrics views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topPosition@highPriority-[episodeSelectorView(viewHeight@highPriority)]->=0@lowPriority-|" options:NSLayoutFormatAlignAllLeft metrics:metrics views:views]];
        
        }else { // IS_IPHONE
        
        
            NSLayoutConstraint * verticalCenter = [NSLayoutConstraint constraintWithItem:episodeSelectorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:episodeSelectorView.superview attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
            NSLayoutConstraint *horizontalCenter = [NSLayoutConstraint constraintWithItem:episodeSelectorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:episodeSelectorView.superview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0 ];
            
            
            NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:episodeSelectorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:episodeSelectorView.superview attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0 ];
             NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:episodeSelectorView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:episodeSelectorView.superview attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0 ];
            
            [self.view addConstraints:@[verticalCenter,height,width,horizontalCenter]];
        }
        
        
        self.episodeSelectorContainerView =episodeSelectorView;
        
    }
    
    if ([_episodeSelectorContainerView.subviews containsObject:view] == NO) {
        
        [self addView:view ToContainer:_episodeSelectorContainerView];
    }
}


-(CGPoint) positionForEpisodeSelectorView
{
    CGRect btnFrame =  self.episodeSelectorButton.frame;
    CGFloat secureMargin = 10.0;
    return CGPointMake(CGRectGetMaxX(btnFrame), CGRectGetMaxY(btnFrame)+secureMargin);
}


-(void) addPostPlaybackViewToScreenWithContent:(UIView *) view
{
    [self loadPostPlaybackContainerViewFrorView:view];
    [_postPlaybackView setDisplayStatus:![_postPlaybackView isDisplayed]];
    [self markViewAsVisible:_postPlaybackView];
    [self.playerContainerView bringSubviewToFront:_postPlaybackView];
    [self.playerContainerView bringSubviewToFront:_topControlsContainer];
    [self.playerContainerView bringSubviewToFront:_controlsContainerView];
    
}


- (void) loadPostPlaybackContainerViewFrorView:(UIView*)view {
    
    if (!self.postPlaybackView) {
        
        self.postPlaybackView=[[SPContainerView alloc] init];
        _postPlaybackView.translatesAutoresizingMaskIntoConstraints  = NO;
        [_postPlaybackView setBackgroundColor:[UIColor clearColor]];
        [self.playerContainerView insertSubview:_postPlaybackView belowSubview:_topControlsContainer];
        
        NSLayoutConstraint *centerXConstrain = [NSLayoutConstraint constraintWithItem:_postPlaybackView
                                                                            attribute:NSLayoutAttributeCenterX
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:_postPlaybackView.superview
                                                                            attribute:NSLayoutAttributeCenterX
                                                                          multiplier:1.f constant:0.0f];
        NSLayoutConstraint *widthConstrain =[NSLayoutConstraint constraintWithItem:_postPlaybackView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
       
        
        NSLayoutConstraint *topConstrain = [NSLayoutConstraint constraintWithItem:_postPlaybackView
                                                                            attribute:NSLayoutAttributeTop
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:_playerContainerView
                                                                            attribute:NSLayoutAttributeTop
                                                                           multiplier:1.0f constant:0.0f];
        NSLayoutConstraint *bottonConstrain = [NSLayoutConstraint constraintWithItem:_postPlaybackView
                                                                            attribute:NSLayoutAttributeBottom
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.controlsContainerView
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:1.0f constant:0.0f];
        
 
        [self.view addConstraints:@[centerXConstrain,widthConstrain, topConstrain,bottonConstrain]];
        
     }
    
    if (![_postPlaybackView.subviews containsObject:view]) { // only in case is the first time
        
        [self addView:view ToContainer:_postPlaybackView];
    }
}




#pragma mark  Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];

    if (self.controlsContainerView.alpha == 1.0 || self.visibleElement != nil )
    {
        [self hideUIElements];
    }else {
        [self startHideElementsTimer];
        
        [self showViewContainer:self.controlsContainerView animated:YES];
        [self showViewContainer:self.topControlsContainer animated:YES];
        
    }
}


-(void) hideUIElements

{
    if ([_postPlaybackView isDisplayed] || [_volumenContainer isDisplayed] || [_metadataContainerView isDisplayed]) return; // do nothing
 
    [_containerViewsArray enumerateObjectsUsingBlock:^(SPContainerView *obj, NSUInteger idx, BOOL *stop) {
        [obj setDisplayStatus:NO];// set all objects to Not Visible
    }];
    
    if (self.episodeSelectorContainerView)
    {
        [_episodeSelectorContainerView setDisplayStatus:NO];
        id<SPPlayerViewControllerAddableViews> view = (id <SPPlayerViewControllerAddableViews>)[_episodeSelectorContainerView viewWithTag:EPISODE_VIEW_TAG];
        [view addableViewHide];
        
    }
    self.visibleElement = nil;
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


- (void) stopObservingNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void) showSpinner
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.centerControlsContainer animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    hud.activityIndicatorColor = [UIColor colorWithRed:216.0/255 green:205.0/255 blue:178.0/255 alpha:1.0];
    hud.removeFromSuperViewOnHide = YES;
}

-(void) hideSpinner
{
       [MBProgressHUD hideAllHUDsForView:self.centerControlsContainer animated:YES];
}
#pragma mark - Player State Machine

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
            
            [self showSpinner];
            [self log:@"=== Status: PTMediaPlayerStatusInitializing ==="];
            break;
        case PTMediaPlayerStatusInitialized:
            [self log:@"=== Status: PTMediaPlayerStatusInitialized ==="];
            [self postNotificationToObservers:SPPlayerDidLoadNotification];
            
          
            break;
        case PTMediaPlayerStatusReady:
            [self moveToInitialPosition ];
           
            [self log:@"=== Status: PTMediaPlayerStatusReady ==="];
            break;
        case PTMediaPlayerStatusPlaying:
            
            [self log:@"=== Status: PTMediaPlayerStatusPlaying ==="];
            [[self controlsContainerView] changeViewToPlayingMode];
            [self hideSpinner];
            [self startHideElementsTimer];
            [self hidePostPlaybackViewIfNeeded];
            [self postNotificationToObservers:SPPlayerStatusPlayingNotification];
         
            break;
        case PTMediaPlayerStatusPaused:
            
            [self log:@"=== Status: PTMediaPlayerStatusPaused ==="];
            [self postNotificationToObservers:SPPlayerStatusPausedNotification];
            [self requestPostPlaybackViewToDelegate];
         
            break;
        case PTMediaPlayerStatusStopped:
            [self log:@"=== Status: PTMediaPlayerStatusStopped ==="];
            [self showSpinner];
            [self postNotificationToObservers:SPPlayerStatusStoppedNotification];
        
            break;
        case PTMediaPlayerStatusCompleted:
            [self log:@"=== Status: PTMediaPlayerStatusCompleted ==="];
            [self postNotificationToObservers:SPPlayerStatusCompletedNotification];
            
            break;
        case PTMediaPlayerStatusError:
            error = playerController.player.error;
            [self log:@"=== Status: PTMediaPlayerStatusError ==="];
            [self log:[NSString stringWithFormat:@"PTSPlayerView:: Error - media player error code[%ld], description[%@], metadata[%@].", (long)error.code, error.description, error.metadata]];
            //#warning TODO: check the error
            [self log:@"PTSPlayerView:: Stopping playback due to errors."];
            [playerController stopVideo];
            [self postNotificationToObservers:SPPPlayerStatusErrorNotification];
            [self.delgate playerViewController:self willStopDuePTMediaError:error];
            
            break;
    }
}

-(void) postNotificationToObservers:(NSString*) notificationIdentifier
{
    
    SPPlayerNotification *notification  = [SPPlayerNotification notificationForplayer:self Item:_currentItem andIdentifier:notificationIdentifier ];
    [[NSNotificationCenter defaultCenter] postNotification:notification];

}



- (void)onMediaPlayerNotificationItemEntry:(NSNotification *)nsnotification
{
    PTNotification *notification = [nsnotification.userInfo objectForKey:PTMediaPlayerNotificationKey];
    [self log:[NSString stringWithFormat:@"PTSPlayerView:: Notification - media player notification code[%ld], description[%@], metadata[%@].", (long)notification.code, notification.description, notification.metadata]];
}


- (void) onMediaPlayerItemPlayStarted:(NSNotification *)notification
{
    [self log:@"PTSPlayerView:: Media Playback started."];
   // [self postNotificationToObservers:SPPlayerStatusPlayingNotification];
}

- (void) onMediaPlayerItemPlayCompleted:(NSNotification *) notification
{
    [self log:@"PTSPlayerView:: Media Playback completed."];

    [self requestPostPlaybackViewToDelegate];
}


- (void) onMediaPlayerTimeChange:(NSNotification *)notification
{
    CMTimeRange seekableRange = playerController.player.seekableRange;
    [self.controlsContainerView updateViewForTimeRange:seekableRange andCurrentPosition:playerController.currentTime];
    [self logVideoDetailsToLabel:qosProvider.playbackInformation];
    
    [self checkIfPlaybackIsAlmostDone:playerController.player];
}

- (void) onMediaPlayerSeekCompleted:(NSNotification *)notification
{
    [self postNotificationToObservers:SPPlayerStatusPlayingNotification];
    
}

#pragma mark - POST Playback View Actions

-(void) hidePostPlaybackViewIfNeeded {
    
    if ([_postPlaybackView isDisplayed]) {
        [_postPlaybackView setDisplayStatus:NO];
    }
}



-(void) requestPostPlaybackViewToDelegate
{
    if ([self.dataSource respondsToSelector:@selector(playerViewController:viewToDisplayAfterVideoPlayback:)]) {
        
        UIView *postPlaybackView = [self.dataSource playerViewController:self viewToDisplayAfterVideoPlayback:self.currentItem];
        
        [self addPostPlaybackViewToScreenWithContent:postPlaybackView];
    }
}


-(void) checkIfPlaybackIsAlmostDone:(PTMediaPlayer*) player
{
    double secs =CMTimeGetSeconds(player.currentTime);
    double duration = CMTimeGetSeconds(player.duration);

    if (secs / duration > 0.9) {
     
       
        if (wasPlaybackNotificationSent == NO) {
            
            [self log:@"PostWillFinishNotification"];
            [self postNotificationToObservers:SPPlayerWillStopNotification];
            wasPlaybackNotificationSent = true;
        }
    }
}



#pragma mark - SPPlayerControlView Delegate
#pragma mark -

#pragma mark  Play Button methods
- (void)view:(SPPlayerControlView*) view didReceivePlayTouch:(UIButton*) button
{
    [playerController resumeVideo];
}

- (void)view:(SPPlayerControlView*) view didReceivePauseTouch:(UIButton*) button
{
    [playerController pauseVideo];
}


/*Slider delegate*/
#pragma mark  Slider Related methods
-(void)view:(SPPlayerControlView*) view valueDidChangeToPlaybackTime:(CMTime) time
{
    
    double currentTime = CMTimeGetSeconds(time);
    
    double scrubWidth = self.scrubbCollectionView.collectionView.contentSize.width;
    double timeWidth = CMTimeGetSeconds(playerController.player.seekableRange.duration);
    
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
    
    [self showSpinner];
    
    [UIView animateWithDuration:0.2 delay:0.2 options:0 animations:^{
        self.thumbsContainer.alpha = 0.0;
    } completion:nil];
    [playerController seekToTime:time completionHandler:^(BOOL finished) {

        [self updateViewAfterSeeking:nil];
    }];

}

-(void) updateViewAfterSeeking:(NSNotification*) notification {

    [self log:@"seek Notification" ];
    [self hideSpinner];
    [playerController.player play];
}

/*Buttons delegate*/
#pragma mark  Metadata Lang Button methods
-(void)view:(SPPlayerControlView*) view didReceiveLANGButtonTouch:(UIButton*) langButton
{
    [self stopUIHideTimer];
    
    BOOL  isCreated = [self loadMetadataMetadataTableViewIfneeded];
    
    if (isCreated == NO) {
        
        [self.metadataTableViewController reloadDataForItem:playerController.player.currentItem];
    }

    [self.playerContainerView bringSubviewToFront:_controlsContainerView];
    [self.metadataContainerView setDisplayStatus:![_metadataContainerView isDisplayed]]; // control same button click to hide
    [self markViewAsVisible:_metadataContainerView];
}


-(BOOL) loadMetadataMetadataTableViewIfneeded
{
    
    if (_metadataTableViewController == nil)
    {
        self.metadataTableViewController = [[MetadataTableViewController alloc] initWithAVPlayerItem:playerController.player.currentItem];
          [_metadataTableViewController configureBackgroundColorInTables:[_uiPropertiesStyle backgroundColorForMetadataTablesViews]];
        [_metadataTableViewController configureFontInTableHeader:[_uiPropertiesStyle fontForMetadataTableHeader] withColor:[_uiPropertiesStyle textColorForHeaderTableView]];
        _metadataTableViewController.delegate = self;
  
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
    [self.playerContainerView bringSubviewToFront:_volumenContainer];
    [self.volumenContainer setDisplayStatus:![_volumenContainer isDisplayed]];
    [self markViewAsVisible:_volumenContainer];
    
}


-(BOOL) loadVolumenViewControllerInContainerIfNeeded
{
    
    if(_volumeViewController) return NO; // not created
    
    
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
    playerController.player.closedCaptionDisplayEnabled = enabled;
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
    
    if (_scrubbCollectionView.view.superview == nil)
    {
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
            [playerController setVolume:0.0];
            break;
        case PSPlayerMessageUnMute:
            [playerController setVolume:[AVAudioSession sharedInstance].outputVolume];
        default:
            break;
    }
}
#pragma EpisodeSelector PopOver
/*
    This will be called when an episode is selected.. this should no be couple with the player. I put it here for the moment.
 */
-(void) episodeSelectorViewDidCallPlayer
{
    [self showEpisodeSelector:self];
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


-(void) addLogginLabel
{
#ifdef DEBUG
    // Show playback stats
    UILabel *logingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame), 100.0, 200.0)];
    [logingLabel setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:0.3]];
    logingLabel.numberOfLines = 10;
    [logingLabel setTextColor:[UIColor whiteColor]];
    [logingLabel setTag:LOGGIN_LABEL_TAG];
    [logingLabel setFont:[UIFont systemFontOfSize:10]];
    
    logingLabel.translatesAutoresizingMaskIntoConstraints  = NO;
    [self.view addSubview:logingLabel];
    
    
    NSDictionary *metrics = @{@"viewHeight":@160.0,@"viewWidth":@200.0,@"padding":@15.0,@"topPosition":@(CGRectGetHeight(self.view.frame) *0.3),@"lowPriority":@(UILayoutPriorityDefaultLow),@"highPriority":@(UILayoutPriorityDefaultHigh)};
    NSDictionary *views = NSDictionaryOfVariableBindings(logingLabel);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10@highPriority-[logingLabel(viewWidth@highPriority)]-padding@lowPriority-|" options:NSLayoutFormatAlignAllLeft metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[logingLabel(viewHeight@highPriority)]-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
    
#endif
    
}
-(void) logVideoDetailsToLabel:(PTPlaybackInformation*) playbackInfo
{
#ifdef DEBUG
    UILabel *logLabel =(UILabel*)[self.view viewWithTag:LOGGIN_LABEL_TAG];
    NSString *infoString = [NSString stringWithFormat:@"Status: %ld \n, BitRate (Observed): %f bits \nBitrate (Server): %f bits\nTs Downloaded: %ld Dropped: ( %ld ) \nTimeToStart ( %f )\nBufferinTime: %f\nBytesTransfered: ( %lld )", (long)playerController.player.status,playbackInfo.observedBitrate, playbackInfo.indicatedBitrate,(long)playbackInfo.numberOfSegmentsDownloaded, (long)playbackInfo.numberOfDroppedVideoFrames,  playbackInfo.timeToStart ,playbackInfo.totalBufferingTime,playbackInfo.numberOfBytesTransferred];
    [logLabel setText:infoString];
#endif
}

@end


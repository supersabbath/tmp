 //
//  SPVolumeViewController.m
//  StarzPlayer
//
//  Created by Fernando Canon on 23/05/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import "SPVolumeViewController.h"
#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioSession.h>

@import MediaPlayer;
@interface SPVolumeViewController ()

@property (weak, nonatomic) IBOutlet UIView * volumeBaseView;
@property (weak, nonatomic) IBOutlet UIView * volumeFrontView;
@property (weak, nonatomic) IBOutlet UIView *volumeControlView;

@property (weak, nonatomic) IBOutlet UIButton *volumeControlMuteButton;
@property (nonatomic, strong) MPVolumeView *volumeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *volumeLevelWidthConstrain;
@end

@implementation SPVolumeViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        self.volumeLevelWidthConstrain.constant = 48;
    }

    [self startListeningToAudioVolume];
    [self configVolumenButtonsImages];
    [self setupView];
    [self.volumeControlMuteButton sizeToFit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void) configVolumenButtonsImages
{
    [self.volumeControlMuteButton setImage:[UIImage imageNamed:@"btn_player_voltop_n.png"] forState:UIControlStateNormal];
    [self.volumeControlMuteButton setImage:[UIImage imageNamed:@"btn_player_voltop_p.png"] forState:UIControlStateHighlighted];
    [self.volumeControlMuteButton setImage:[UIImage imageNamed:@"btn_player_mute_n.png"] forState:UIControlStateSelected];

}


-(void) setupView

{
    self.volumeView = [[MPVolumeView alloc] init];
    self.volumeView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.volumeBaseView addSubview:self.volumeView];

    
    UIImage * valueImage = [UIImage imageNamed:@"volume_value.png"];
    valueImage = [valueImage stretchableImageWithLeftCapWidth:0 topCapHeight:1];
    
    UIImage * baseImage = [UIImage imageNamed:@"volume_base.png"];
    baseImage = [baseImage stretchableImageWithLeftCapWidth:0 topCapHeight:1];
    
    UIImage * blankImage = [UIImage imageNamed:@"catalog_letter_default.png"];
    
    [self.volumeView setMinimumVolumeSliderImage:blankImage forState:UIControlStateNormal];
    [self.volumeView setMaximumVolumeSliderImage:blankImage forState:UIControlStateNormal];
    [self.volumeView setVolumeThumbImage:blankImage forState:UIControlStateNormal];

 
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [self.volumeBaseView addConstraint:[NSLayoutConstraint constraintWithItem:self.volumeView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.volumeBaseView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:1]];
        [self.volumeBaseView addConstraint:[NSLayoutConstraint constraintWithItem:self.volumeView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.volumeBaseView attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.volumeBaseView.bounds.size.height / 2]];
        
        [self.volumeBaseView addConstraint:[NSLayoutConstraint constraintWithItem:self.volumeView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.volumeBaseView.frame.size.height]];
        [self.volumeBaseView addConstraint:[NSLayoutConstraint constraintWithItem:self.volumeView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.volumeBaseView.frame.size.width]];
    }
    else
    {
        [self.volumeBaseView addConstraint:[NSLayoutConstraint constraintWithItem:self.volumeView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.volumeBaseView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [self.volumeBaseView addConstraint:[NSLayoutConstraint constraintWithItem:self.volumeView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.volumeBaseView attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.volumeBaseView.bounds.size.height / 2]];
        // here is the diff
        [self.volumeBaseView addConstraint:[NSLayoutConstraint constraintWithItem:self.volumeView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.volumeBaseView.frame.size.height]];
        [self.volumeBaseView addConstraint:[NSLayoutConstraint constraintWithItem:self.volumeView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.volumeBaseView.frame.size.width]];
        
    }
    
    
    CGAffineTransform trans = CGAffineTransformMakeRotation(-M_PI * 0.5);
    self.volumeView.transform = trans;
    
    self.volumeView.showsRouteButton = NO;
    self.volumeView.backgroundColor = [UIColor clearColor];
    
    self.volumeBaseView.backgroundColor = [UIColor colorWithPatternImage:baseImage];
    self.volumeFrontView.backgroundColor = [UIColor colorWithPatternImage:valueImage];
    
   
 
    [self.volumeControlView setNeedsLayout];
    [self.volumeControlView layoutIfNeeded];
    
    [self updateVolumeLevel];
}




- (void) updateVolumeLevel
{

    CGFloat volume = [AVAudioSession sharedInstance].outputVolume;

    CGFloat h = self.volumeFrontView.bounds.size.height;
    CGFloat w = self.volumeFrontView.bounds.size.width;
    CGFloat maskHeight = volume * self.volumeBaseView.bounds.size.height;
    
    CALayer * maskLayer = [CALayer layer];
    CGRect inset = CGRectMake(0, h - maskHeight, w, maskHeight);
    maskLayer.frame = inset;
    maskLayer.backgroundColor = [UIColor blackColor].CGColor;
    
    self.volumeFrontView.layer.mask = maskLayer;
    [self.volumeFrontView setNeedsUpdateConstraints];
    [self.volumeControlView setNeedsLayout];
    
    if (volume == 0) {
        [_volumeControlMuteButton setSelected:YES];
    }
    else {
        [_volumeControlMuteButton setSelected:NO];
    }
    [self.delegate childViewController:self didCompleteActionWithMessage:PSPlayerMessageUnMute];
}


-(void) dealloc
{
    [self stopListeningToAudioVolume];
}


- (IBAction) mutePlayer:(id)sender {
    NSLog(@"Mute");
    [_volumeControlMuteButton setSelected:!_volumeControlMuteButton.isSelected];
    
    if ([self.delegate respondsToSelector:@selector(childViewController:didCompleteActionWithMessage:)]) {
        if (_volumeControlMuteButton.isSelected) {
            
            [self.delegate childViewController:self didCompleteActionWithMessage:PSPlayerMessageMute];
        }else{
            [self.delegate childViewController:self didCompleteActionWithMessage:PSPlayerMessageUnMute];

        }
    }
}


#pragma mark -
#pragma mark audio session

//// Hardware Button Volume Callback
void volumeListenerCallback (void                   *inUserData,
                             AudioSessionPropertyID inPropertyID,
                             UInt32                         volume,
                             const void                *inData){
    
    if (inPropertyID != kAudioSessionProperty_CurrentHardwareOutputVolume) return;
    
    volume = kAudioSessionProperty_CurrentHardwareOutputVolume;
    SPVolumeViewController * volumeViewController = (__bridge SPVolumeViewController *)inUserData;
    
    [volumeViewController updateVolumeLevel];
}


- (void)startListeningToAudioVolume
{
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    AudioSessionAddPropertyListener (kAudioSessionProperty_CurrentHardwareOutputVolume,
                                     volumeListenerCallback,
                                     (__bridge void*)self);
}



- (void)stopListeningToAudioVolume
{
    AudioSessionRemovePropertyListenerWithUserData(
                                                   kAudioSessionProperty_CurrentHardwareOutputVolume,
                                                   volumeListenerCallback,
                                                   (__bridge void*)self);
}
@end

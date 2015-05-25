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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *VolContainerWidth;
@property (nonatomic, strong) MPVolumeView *volumeView;
@end

@implementation SPVolumeViewController


void volumeListenerCallback (
                             void *inUserData,
                             AudioSessionPropertyID inPropertyID,
                             Float32 volume){
    
    if (inPropertyID != kAudioSessionProperty_CurrentHardwareOutputVolume) return;
    
    volume = kAudioSessionProperty_CurrentHardwareOutputVolume;
    SPVolumeViewController * volumeViewController = (__bridge SPVolumeViewController *)inUserData;
   
    [volumeViewController updateUIForVolume:volume];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    AudioSessionAddPropertyListener (kAudioSessionProperty_CurrentHardwareOutputVolume,
                                     volumeListenerCallback,
                                     (__bridge void*)self
                                     );
    [self setupView];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) setupView

{

    self.volumeView = [[MPVolumeView alloc] init];
    self.volumeView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.volumeControlView addSubview:self.volumeView];
    
    [self.volumeView setNeedsUpdateConstraints];
    [self.volumeControlView setNeedsLayout];
    
    [self.volumeControlView layoutIfNeeded];
    
    UIImage * valueImage = [UIImage imageNamed:@"volume_value.png"];
    valueImage = [valueImage stretchableImageWithLeftCapWidth:0 topCapHeight:1];
    
    UIImage * baseImage = [UIImage imageNamed:@"volume_base.png"];
    baseImage = [baseImage stretchableImageWithLeftCapWidth:0 topCapHeight:1];
    
    UIImage * blankImage = [UIImage imageNamed:@"catalog_letter_default.png"];
    
    [self.volumeView setMinimumVolumeSliderImage:blankImage forState:UIControlStateNormal];
    [self.volumeView setMaximumVolumeSliderImage:blankImage forState:UIControlStateNormal];
    [self.volumeView setVolumeThumbImage:blankImage forState:UIControlStateNormal];
    
    NSMutableArray* cons = [NSMutableArray array];
    for (NSLayoutConstraint* con in self.volumeControlView.constraints)
        if (con.firstItem == self.volumeView || con.secondItem == self.volumeView)
            [cons addObject:con];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [self.volumeControlView addConstraint:[NSLayoutConstraint constraintWithItem:self.volumeView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.volumeBaseView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.volumeBaseView.bounds.size.width / 2]];
        [self.volumeControlView addConstraint:[NSLayoutConstraint constraintWithItem:self.volumeView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.volumeBaseView attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.volumeBaseView.bounds.size.height / 2]];
        
        [self.volumeControlView addConstraint:[NSLayoutConstraint constraintWithItem:self.volumeView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.volumeBaseView.frame.size.height]];
        [self.volumeControlView addConstraint:[NSLayoutConstraint constraintWithItem:self.volumeView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.volumeBaseView.frame.size.width]];
    }
    else
    {
        [self.volumeControlView addConstraint:[NSLayoutConstraint constraintWithItem:self.volumeView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.volumeBaseView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.volumeBaseView.bounds.size.width / 2]];
        [self.volumeControlView addConstraint:[NSLayoutConstraint constraintWithItem:self.volumeView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.volumeBaseView attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.volumeBaseView.bounds.size.height / 2]];
        
        [self.volumeControlView addConstraint:[NSLayoutConstraint constraintWithItem:self.volumeView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.volumeBaseView.frame.size.height]];
        [self.volumeControlView addConstraint:[NSLayoutConstraint constraintWithItem:self.volumeView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.volumeBaseView.frame.size.width]];
    }
    
    
    CGAffineTransform trans = CGAffineTransformMakeRotation(-M_PI * 0.5);
    self.volumeView.transform = trans;
    
    self.volumeView.showsRouteButton = NO;
    self.volumeView.backgroundColor = [UIColor clearColor];
    
    self.volumeBaseView.backgroundColor = [UIColor colorWithPatternImage:baseImage];
    self.volumeFrontView.backgroundColor = [UIColor colorWithPatternImage:valueImage];
    
    if (( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)) {
        
        self.VolContainerWidth.constant = 24;
    }
    [self.volumeControlView setNeedsUpdateConstraints];
    [self.volumeControlView setNeedsLayout];
    [self.volumeControlView layoutIfNeeded];

}


- (void)updateUIForVolume:(double)volume
{

    volume = [AVAudioSession sharedInstance].outputVolume;

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
    
//    [self layoutIfNeeded];
//    
//    if (volume == 0)
//    {
//        [self.volumeControlMuteButton setImage:[UIImage imageNamed:@"btn_player_mute_n.png"] forState:UIControlStateNormal];
//        [self.volumeControlMuteButton setImage:[UIImage imageNamed:@"btn_player_mute_p.png"] forState:UIControlStateHighlighted];
//    }
//    else
//    {
//        [self.volumeControlMuteButton setImage:[UIImage imageNamed:@"btn_player_voltop_n.png"] forState:UIControlStateNormal];
//        [self.volumeControlMuteButton setImage:[UIImage imageNamed:@"btn_player_voltop_p.png"] forState:UIControlStateHighlighted];
//    }
}


//// Hardware Button Volume Callback
//void audioVolumeChangeListenerCallback (
//                                        void                      *inUserData,
//                                        AudioSessionPropertyID    inID,
//                                        UInt32                    inDataSize,
//                                        const void                *inData)
//{
//    SPVolumeViewController * volumeViewController = (__bridge SPVolumeViewController *)inUserData;
//    
//}
//
//
//- (void)startListeningToAudioVolume
//{
//    AudioSessionAddPropertyListener(
//                                     kAudioSessionProperty_CurrentHardwareOutputVolume ,
//                                     audioVolumeChangeListenerCallback,
//                                     (__bridge void*)self);
//    
//    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//    CGFloat volume = audioSession.outputVolume;
//}
//
//- (void)stopListeningToAudioVolume
//{
//    AudioSessionRemovePropertyListenerWithUserData(
//                                                   kAudioSessionProperty_CurrentHardwareOutputVolume,
//                                                   audioVolumeChangeListenerCallback,
//                                                   (__bridge void*)self);
//}


@end

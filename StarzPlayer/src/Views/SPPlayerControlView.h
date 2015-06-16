//
//  SPAControlView.h
//  StarzPlayer
//
//  Created by Fernando Canon on 18/05/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPContainerView.h"

@import AVFoundation;

@protocol SPPlayerControlViewDelegate ;


@interface SPPlayerControlView : SPContainerView

@property (nonatomic, assign) IBOutlet id <SPPlayerControlViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton * playButton;
@property (weak, nonatomic) IBOutlet UISlider *scrubber;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet  UIButton *langButton;
 

-(void) updateViewForTimeRange:(CMTimeRange) range andCurrentPosition:(CMTime) currentPosition;

- (IBAction) playTouch:(id)sender;
- (IBAction) sliderDidChageValue:(id)sender;
- (IBAction) sliderFinishedMoving: (id)sender;
- (IBAction) showLanguageOptions:(id)sender;
- (IBAction) showVolumeControl:(id)sender;

/*UI Actions*/

-(void) changeViewToPlayingMode;
-(void) changeViewToLoadingMode;
/* Appearence*/
-(void) setupColorInLangButton:(UIColor*) color forState:(UIControlState) state;
-(void) setupFontInLanButton:(UIFont*) font;
-(void) setupFontInTimeLabel:(UIFont*) font withColor:(UIColor *) color;
-(void) setControlViewColor:(UIColor*) backColor;
@end

@protocol SPPlayerControlViewDelegate <NSObject>
/*Play*/
-(void)view:(SPPlayerControlView*) view didReceivePlayTouch:(UIButton*) button;
-(void)view:(SPPlayerControlView*) view didReceivePauseTouch:(UIButton*) button;

/* Srubber */
-(void) view:(SPPlayerControlView*) view seekingDidFinishWithPlaybackTime:(CMTime) time;
-(void) view:(SPPlayerControlView *)view valueDidChangeToPlaybackTime:(CMTime)time;
-(void) view:(SPPlayerControlView*) view seekingDidStartWithPlaybackTime:(CMTime) time;

/*Buttons*/
-(void)view:(SPPlayerControlView*) view didReceiveLANGButtonTouch:(UIButton*) langButton;
-(void)view:(SPPlayerControlView*) view didReceiveVolumenButtonTouch:(UIButton*) volButton;
@end

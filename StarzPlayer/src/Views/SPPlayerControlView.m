//
//  SPAControlView.m
//  StarzPlayer
//
//  Created by Fernando Canon on 18/05/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import "SPPlayerControlView.h"
#import <MBProgressHUD.h>
#import <PSDKLibrary/PTMediaPlayer.h>
#define AD_TIMESCALE 100000
#define CONTROL_CONTAINER_TAG 221

@interface SPPlayerControlView ()
{
    CMTimeRange sliderRange;
    BOOL isSeeking;
}

@end

@implementation SPPlayerControlView

@synthesize playButton,delegate, scrubber;

-(void) awakeFromNib
{
 [self setupView];
}



-(void) setupView
{
    isSeeking = NO;
    
    [playButton setImage:[UIImage imageNamed:@"btn_player_pause_n.png"] forState:UIControlStateSelected];
    [playButton setImage:[UIImage imageNamed:@"btn_player_play_p.png"] forState:UIControlStateNormal];
 
    [scrubber setMaximumTrackTintColor:[UIColor colorWithRed:132.0/255 green:119.0/255 blue:92.0/255 alpha:1.0]];
    [scrubber setMinimumTrackTintColor:[UIColor colorWithRed:216.0/255 green:205.0/255 blue:178.0/255 alpha:1.0]];
    [scrubber setThumbImage:[UIImage imageNamed:@"btn_player_playhead_n.png"] forState:UIControlStateNormal];
    [scrubber setThumbImage:[UIImage imageNamed:@"btn_player_playhead_p.png"] forState:UIControlStateHighlighted];
}

#pragma mark - IBActions
- (IBAction) playTouch:(id)sender
{
    if ( playButton.isSelected ) {
        
        [self sendSelectorToDelegate:@selector(view:didReceivePauseTouch:) withSender:sender];
        [playButton setSelected:NO];
    }else  {
       [self sendSelectorToDelegate:@selector(view:didReceivePlayTouch:) withSender:sender];
        [playButton setSelected:YES];
    }
}



-(IBAction) sliderStarted:(id)sender {
 
    if ([self.delegate respondsToSelector:@selector(view:seekingDidStartWithPlaybackTime:)]) {
        [self.delegate view:self seekingDidStartWithPlaybackTime:CMTimeMake(0, AD_TIMESCALE)];
    }
}

- (IBAction) sliderDidChageValue:(id)sender {
    
    isSeeking  = YES;
    double sliderTime = [scrubber value];
    [self updateViewForTimeRange:sliderRange andCurrentPosition:CMTimeMake(sliderTime, AD_TIMESCALE)];
    
    double duration = CMTimeGetSeconds(sliderRange.duration);
    double currentTime = duration * sliderTime;
    [self.timeLabel setText: [self formatStringCurrenTime:currentTime andTotalLenght:duration]];
    double start = CMTimeGetSeconds(sliderRange.start);
    
    
    CMTime newTime = CMTimeMakeWithSeconds((sliderTime * duration) + start, AD_TIMESCALE);
    
    if ([self.delegate respondsToSelector:@selector(view:valueDidChangeToPlaybackTime:)]) {
        [self.delegate view:self valueDidChangeToPlaybackTime:newTime];
    }

}

- (IBAction) sliderFinishedMoving: (id)sender
{
    isSeeking  = NO;
    double sliderTime = [scrubber value];
    if (CMTIMERANGE_IS_VALID(sliderRange))
    {
        double start = CMTimeGetSeconds(sliderRange.start);
        double duration = CMTimeGetSeconds(sliderRange.duration);
        
        CMTime newTime = CMTimeMakeWithSeconds((sliderTime * duration) + start, AD_TIMESCALE);
        
        if ([self.delegate respondsToSelector:@selector(view:seekingDidFinishWithPlaybackTime:)]) {
            [self.delegate view:self seekingDidFinishWithPlaybackTime:newTime];
        }
    }
}


- (IBAction) showLanguageOptions:(id)sender
{
    [self sendSelectorToDelegate:@selector(view:didReceiveLANGButtonTouch:) withSender:sender];
}


- (IBAction) showVolumeControl:(id)sender
{
    [self sendSelectorToDelegate:@selector(view:didReceiveVolumenButtonTouch:) withSender:sender];
}


-(void) sendSelectorToDelegate:(SEL) selector withSender:(UIButton *) button
{
    if ([delegate respondsToSelector:selector])
    {
        NSMethodSignature * methodSignature = [[delegate class]
                                           instanceMethodSignatureForSelector:selector];
        NSInvocation * delegateInvocation = [NSInvocation
                                       invocationWithMethodSignature:methodSignature];
        
  
        [delegateInvocation setSelector:selector];
        [delegateInvocation setTarget:delegate];
        SPPlayerControlView *weakSealf =self;
        [delegateInvocation setArgument:&weakSealf atIndex:2];
        [delegateInvocation setArgument:&button atIndex:3];
        [delegateInvocation invoke];
        
    }
}


/*UI Actions*/
#pragma mark - UI Actions

-(void) changeViewToPlayingMode
{
    playButton.selected  = YES;
}

-(void) changeViewToPauseMode
{
    playButton.selected  = NO;
}

-(void) updateViewForTimeRange:(CMTimeRange) range andCurrentPosition:(CMTime) currentPosition
{
    if (isSeeking) {return;}

    sliderRange = range;
    if (CMTIMERANGE_IS_VALID(range))
    {
        double start = CMTimeGetSeconds(range.start);
        double duration = CMTimeGetSeconds(range.duration);
        double currentTime = CMTimeGetSeconds(currentPosition);
        
        if (duration > 0 )
        {
            [scrubber setValue:((currentTime - start) / duration)];
        }
        
            if (CMTIME_IS_INDEFINITE(currentPosition))
        {
            [self.timeLabel setText:[NSString stringWithFormat:@"LIVE"]];
         }
        else
        {
            [self.timeLabel setText: [self formatStringCurrenTime:currentTime andTotalLenght:duration]];
          
        }
    }
}

#pragma UI appearance setup

-(void) setupColorInLangButton:(UIColor*) color forState:(UIControlState) state
{
    [_langButton setTitleColor:color forState:state];
}


-(void) setupFontInLanButton:(UIFont*) font
{
    [_langButton.titleLabel setFont:font];
}

-(void) setupFontInTimeLabel:(UIFont*) font withColor: (UIColor *) color
{
    [_timeLabel setFont:font];
    [_timeLabel setTextColor:color];
}


-(void) setControlViewColor:(UIColor*) backColor
{
    [[self viewWithTag:CONTROL_CONTAINER_TAG] setBackgroundColor:backColor];
}

#pragma mark - Time Format Helpers
-(NSString*) formatStringCurrenTime:(double) time andTotalLenght:(double) duration
{
    NSString *currentTime = [self formattedTime:time] ;
    if (UIUserInterfaceLayoutDirectionRightToLeft == [UIApplication sharedApplication].userInterfaceLayoutDirection)
    {
        return  [[self formattedTime:duration] stringByAppendingFormat:@" / %@",currentTime];
    }else{
        return [currentTime stringByAppendingFormat:@" / %@",[self formattedTime:duration]];
    }
}


-(NSString *) formattedTime: (double) time
{
    int h = time / 3600;
    float rest = time - (h * 3600);
    int m = rest / 60;
    rest = rest - (m * 60);
    int s = (int)rest;
    
    NSString *hours = Nil;
    NSString *minutes = Nil;
    NSString *seconds = Nil;
    
    hours = [NSString stringWithFormat:@"%02d", h];
    minutes = [NSString stringWithFormat:@"%02d", m];
    seconds = [NSString stringWithFormat:@"%02d", s];
    
    return [NSString stringWithFormat:@"%@:%@:%@", hours, minutes, seconds];
   
}

@end

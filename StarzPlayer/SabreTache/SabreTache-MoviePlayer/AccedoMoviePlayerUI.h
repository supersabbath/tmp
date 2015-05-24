//
//  AccedoMoviePlayerUI.h
//  Appcelerator-MoviePlayer
//
//  Created by Tüz Csaba on 17/02/15.
//  Copyright (c) 2015 Accedo Broadband AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccedoMoviePlayerEventListener.h"

@protocol AccedoMoviePlayerUI;

@protocol AccedoMoviePlayerUIDelegate

- (void)moviePlayerUIShouldHandleClose:(id<AccedoMoviePlayerUI>)view;

- (NSURL *)moviePlayerUIBackgroundImageURL:(id<AccedoMoviePlayerUI>)view;
- (UIImage *)moviePlayerUIBackgroundImage:(id<AccedoMoviePlayerUI>)view;

@end

@protocol AccedoMoviePlayerUI<AccedoMoviePlayerEventListener>

@property (assign) id<AccedoMoviePlayerUIDelegate> delegate;

#pragma mark - Update interfaces

- (void)updateUIForPlay;
- (void)updateUIForPause;
- (void)updateUIForStop;

- (void)updateUIForPlaybackPosition:(NSTimeInterval)playbackTime andplayableDuration:(NSTimeInterval)bufferedTime initialPlaybackTime:(NSTimeInterval)initialPlaybackTime;


- (void)updateUIForDuration:(double)f;

- (void)updateUIForSubtitle:(NSString *)subtitle;
- (void)updateUIForVolume:(double)volume;
@optional
- (void)updateUIForScreen:(MPMovieScalingMode) scaling;

- (void)updateForOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
- (void) willRotateToOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
- (void) dismissPopover;
@end

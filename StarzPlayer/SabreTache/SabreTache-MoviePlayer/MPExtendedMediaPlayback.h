//
//  MPExtendedMediaPlayback.h
//  Appcelerator-MoviePlayer
//
//  Created by Tüz Csaba on 17/02/15.
//  Copyright (c) 2015 Accedo Broadband AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "AccedoPlayerError.h"
#import "AccedoMoviePlayerEventListener.h"
#import "SubtitleProvider.h"

@protocol AccedoMoviePlayerEventListener;

@protocol MPExtendedMediaPlayback<MPMediaPlayback>

@property(nonatomic, readonly) MPMoviePlaybackState playbackState;

@property(nonatomic, readonly) MPMovieLoadState loadState;

@property(assign, nonatomic, readonly) NSTimeInterval duration;

@property (assign, nonatomic, readonly) BOOL isLive;

@property (retain, nonatomic, readonly) NSArray * eventListeners;

@property (retain, nonatomic) id<AccedoPlayerErrorRenderer> errorRenderer;

@property (assign, nonatomic, readonly) NSInteger bitrate;

- (void)setVolume:(float)newVolume;

- (void)selectSubtitle:(SubtitleRef *)item;
- (void)selectAudioTrack:(NSObject *)track;

- (float)volume;

- (void)didEnterForeground;

@property (retain, nonatomic) id remoteMedia;

- (void)addEventListener:(id<AccedoMoviePlayerEventListener>)listener;

- (void)removeEventListener:(id<AccedoMoviePlayerEventListener>)listener;

- (void)setEventListeners:(NSArray *)eventListeners;

@end

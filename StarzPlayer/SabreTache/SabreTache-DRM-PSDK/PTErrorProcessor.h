//
//  PTErrorProcessor.h
//  Starz
//
//  Created by Tüz Csaba on 27/11/14.
//  Copyright (c) 2014 accedo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <PSDKLibrary/PSDKLibrary.h>

#import "AccedoMoviePlayer.h"

@class PTMoviePlayerController;

typedef NS_ENUM(NSInteger, PTMediaErrorGroup)
{
    PTMediaErrorGroupDRM             = 100,
    PTMediaErrorGroupPlayback        = 101,
    PTMediaErrorGroupInvalidResource = 102,
    PTMediaErrorGroupAdProcessing    = 104,
    PTMediaErrorGroupNative          = 106,
    PTMediaErrorGroupConfiguration   = 107,
    PTMediaErrorGroupIOSSpecific     = 170
};

@interface PTErrorEvent : AccedoPlayerError

@property (assign, nonatomic) BOOL isBlockingPlayback;
@property (assign, nonatomic) PTMediaErrorGroup errorGroup;
@property (retain, nonatomic) NSObject * originalError;

@end

@interface PTErrorProcessor : NSObject

+ (PTErrorProcessor *)instance;

- (void)processMediaPlayerError:(PTMediaError *)error;
- (void)processDRMError:(DRMError *)error;

@end

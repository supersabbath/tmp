//
//  PrimetimeDRMController.h
//  Parsifal
//
//  Created by Tüz Csaba on 17/10/14.
//  Copyright (c) 2014 accedo. All rights reserved.
//
#import <PSDKLibrary/PSDKLibrary.h>
#import <Foundation/Foundation.h>
#import <SabreTache-MoviePlayer/DRMProvider.h>

#import "PTMoviePlayerController.h"

@class TitleMedia;

@interface PrimetimeDRMController : NSObject<DRMProvider>

+ (PrimetimeDRMController *)instance;

+ (PTMediaPlayerItem *)createPTMediaPlayerItemForReleaseUrl:(NSURL *)releaseUrl mediaId:(NSString *)mediaId abrControl:(PTABRControlParameters *)abrControl;

- (void)authenticateWithDRMManager:(DRMMetadata *)metadata mpxUsername:(NSString *)mpxUsername mediaAccessToken:(NSString *)accessToken onComplete:(void(^)(void))complete onFailure:(void(^)(DRMError *))failure;

@property (retain, nonatomic) PTMediaPlayerItem * currentPlayerItem;

@end

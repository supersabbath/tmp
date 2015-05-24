//
//  AccedoMoviePlayerAttachable.h
//  Appcelerator-MoviePlayer
//
//  Created by Tüz Csaba on 17/02/15.
//  Copyright (c) 2015 Accedo Broadband AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AccedoMoviePlayer;

@protocol AccedoMoviePlayerAttachable<NSObject>

- (void)attachToMoviePlayer:(AccedoMoviePlayer *)moviePlayerController;

- (void)detachFromMoviePlayer:(AccedoMoviePlayer *)moviePlayerController;

@end

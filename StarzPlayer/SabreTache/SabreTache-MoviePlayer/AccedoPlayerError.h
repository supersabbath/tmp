//
//  AccedoPlayerErrorRenderer.h
//  Appcelerator-MoviePlayer
//
//  Created by Tüz Csaba on 17/02/15.
//  Copyright (c) 2015 Accedo Broadband AB. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AccedoMoviePlayerAttachable.h"


@interface AccedoPlayerError : NSError

@end

@protocol AccedoPlayerErrorRenderer <NSObject, AccedoMoviePlayerAttachable>

- (void)shouldRenderPlayerError:(AccedoPlayerError *)errorEvent;

@end

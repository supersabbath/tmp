
//
//  PTErrorProcessor.m
//  Starz
//
//  Created by Tüz Csaba on 27/11/14.
//  Copyright (c) 2014 accedo. All rights reserved.
//

#import "PTErrorProcessor.h"

NSString * const PTErrorProcessorDidProcessErrorNotification = @"PTErrorProcessorDidProcessErrorNotification";
NSString * const PTErrorProcessorNotificationError = @"PTErrorProcessorNotificationError";

@implementation PTErrorEvent

- (instancetype)initWithError:(PTMediaError *)error
{
    self = [super init];
    if (self)
    {
        self.originalError = error;
    }
    return self;
}

- (instancetype)initWithDRMError:(DRMError *)error
{
    self = [super init];
    if (self)
    {
        self.originalError = error;
    }
    return self;
}

@end

@interface PTErrorProcessor()

@end

@implementation PTErrorProcessor

SYNTHESIZE_SINGLETON_FOR_CLASS(PTErrorProcessor);

- (void)processMediaPlayerError:(PTMediaError *)error
{
    NSInteger errorCode = error.code;
    
    NSInteger group = errorCode / 1000;
    
    PTErrorEvent * errorEvent;
    switch (group)
    {
        case PTMediaErrorGroupDRM:
            errorEvent = [self processDRMErrorFromPTMediaError:error];
            break;
        case PTMediaErrorGroupPlayback:
            errorEvent = [self processPlaybackError:error];
            break;
        case PTMediaErrorGroupInvalidResource:
            errorEvent = [self processResourceError:error];
            break;
        case PTMediaErrorGroupAdProcessing:
            errorEvent = [self processAdProcessingError:error];
            break;
        case PTMediaErrorGroupNative:
            errorEvent = [self processNativeError:error];
            break;
        case PTMediaErrorGroupIOSSpecific:
            errorEvent = [self processIOSSpecificError:error];
            break;
    }
    
    if (errorEvent != nil)
    {
        [self notifyAnalyticsProviderOfError:errorEvent];
        
        [self notifyPlayerErrorRenderer:errorEvent];
    }
}

- (void)processDRMError:(DRMError *)error
{
    PTErrorEvent * err = [[PTErrorEvent alloc] initWithDRMError:error];
    
    err.errorGroup = PTMediaErrorGroupDRM;
    err.isBlockingPlayback = YES;
    
    if (err != nil)
    {
        [self notifyAnalyticsProviderOfError:err];
        
        [self notifyPlayerErrorRenderer:err];
    }
}

- (void)notifyAnalyticsProviderOfError:(PTErrorEvent *)error
{
    AccedoMoviePlayer * p = [AccedoMoviePlayer instance];
    
    if (p)
    {
        for (id<AccedoMoviePlayerEventListener> l in p.eventListeners)
        {
            [l moviePlayer:p didErrorOccur:error];
        }
    }
}

- (void)notifyPlayerErrorRenderer:(PTErrorEvent *)error
{
    AccedoMoviePlayer * p = [AccedoMoviePlayer instance];
    if (p)
    {
        [[p errorRenderer] shouldRenderPlayerError:error];
    }
}

#pragma mark - Error group handlers

- (PTErrorEvent *)processDRMErrorFromPTMediaError:(PTMediaError *)error
{
    PTErrorEvent * err = [[PTErrorEvent alloc] initWithError:error];
    
    err.errorGroup = PTMediaErrorGroupDRM;
    err.isBlockingPlayback = YES;
    
    // NSInteger majorDRMErrorCode = [error.metadata[@"MAJOR_DRM_CODE"] integerValue];
    // NSInteger minorDRMErrorCode = [error.metadata[@"MINOR_DRM_CODE"] integerValue];
    
    return err;
}

- (PTErrorEvent *)processPlaybackError:(PTMediaError *)error
{
    PTErrorEvent * err = [[PTErrorEvent alloc] initWithError:error];
    
    err.errorGroup = PTMediaErrorGroupPlayback;
    
    BOOL isBlockingPlayback = NO;
    switch (error.code)
    {
        case 101001:
            isBlockingPlayback = YES;
            break;
        case 101008:
            break;
        case 101009:
            break;
        case 101101:
            break;
    }
    err.isBlockingPlayback = isBlockingPlayback;
    
    return err;
    
}

- (PTErrorEvent *)processResourceError:(PTMediaError *)error
{
    PTErrorEvent * err = [[PTErrorEvent alloc] initWithError:error];
    
    err.errorGroup = PTMediaErrorGroupInvalidResource;
    err.isBlockingPlayback = YES;
    
    return err;
}

- (PTErrorEvent *)processAdProcessingError:(PTMediaError *)error
{
    PTErrorEvent * err = [[PTErrorEvent alloc] initWithError:error];
    
    err.errorGroup = PTMediaErrorGroupAdProcessing;
    err.isBlockingPlayback = NO;
    
    return err;
}

- (PTErrorEvent *)processNativeError:(PTMediaError *)error
{
    PTErrorEvent * err = [[PTErrorEvent alloc] initWithError:error];
    
    err.errorGroup = PTMediaErrorGroupNative;
    err.isBlockingPlayback = YES;
    
    return err;
}

- (PTErrorEvent *)processConfigurationError:(PTMediaError *)error
{
    PTErrorEvent * err = [[PTErrorEvent alloc] initWithError:error];
    
    err.errorGroup = PTMediaErrorGroupConfiguration;
    err.isBlockingPlayback = YES;
    
    return err;
}

- (PTErrorEvent *)processIOSSpecificError:(PTMediaError *)error
{
    PTErrorEvent * err = [[PTErrorEvent alloc] initWithError:error];
    
    err.errorGroup = PTMediaErrorGroupIOSSpecific;
    err.isBlockingPlayback = YES;
    
    return err;
}

@end

//
//  PrimetimeDRMController.m
//  Parsifal
//
//  Created by Tüz Csaba on 17/10/14.
//  Copyright (c) 2014 accedo. All rights reserved.
//

#import "PrimetimeDRMController.h"

#import <SabreTache-Core/Macros.h>
#import <SabreTache-Core/Logging.h>

@interface PSConsoleLogger : NSObject<PTLogger>

@end

@implementation PSConsoleLogger

+ (PSConsoleLogger *) consoleLogger {
    return [[PSConsoleLogger alloc] init];
}

- (void)logEntry:(PTLogEntry *)entry {
    //Log the message to the console using NSLog
    DLog(@"[%@] %@", entry.tag, entry.message);
}

@end

@interface PrimetimeDRMController()

@end

@implementation PrimetimeDRMController

SYNTHESIZE_SINGLETON_FOR_CLASS(PrimetimeDRMController);

- (void)initializeDRM {
    PSConsoleLogger *logger = [PSConsoleLogger consoleLogger];
    // Either use the addLogger method:
    [[PTLogFactory sharedInstance] addLogger:(logger)];
}

- (DRMFlowResult *)invokeDRM:(DRMEntry *)entry {
    WLog(@"This method does nothing. Please invoke DRM lifecycle methods instead");
    return nil;
}

+ (PTMediaPlayerItem *)createPTMediaPlayerItemForReleaseUrl:(NSURL *)releaseUrl
                                                    mediaId:(NSString *)mediaId abrControl:(PTABRControlParameters *)abrControl
{
    PTMetadata * meta = [PTMetadata new];
    if (abrControl != nil)
    {
        [meta setMetadata:abrControl forKey:PTABRResolvingMetadataKey];
    }
    PTMediaPlayerItem * playerItem = [[PTMediaPlayerItem alloc] initWithUrl:releaseUrl mediaId:mediaId metadata:meta];
    

    return playerItem;
}

- (void)authenticateWithDRMManager:(DRMMetadata *)metadata mpxUsername:(NSString *)mpxUsername mediaAccessToken:(NSString *)accessToken onComplete:(void(^)(void))complete onFailure:(void(^)(DRMError *))failure
{
    DRMPolicy * policy = [metadata.getPolicies firstObject];
    NSString * domain = [policy getAuthenticationDomain];

    [[DRMManager sharedManager] authenticate:metadata url:metadata.serverUrl authenticationDomain:domain username:mpxUsername password:accessToken error:^(DRMError *error) {
        WLog(@"DRM ERROR on authenticate: %@", error);
        
        if (failure)
        {
            failure(error);
        }
    } complete:^(NSData *authenticationToken) {

        [[DRMManager sharedManager] setAuthenticationToken:metadata authenticationDomain:domain token:authenticationToken error:^(DRMError *error) {
            ELog(@"Error: %@", error);
            if (failure)
            {
                failure(error);
            }
        } complete:complete];
    }];
}

- (void)tearDownDRM {
}

- (void)destroyDRM {
}

- (id)newMediaPlayerInstance
{
    AccedoMoviePlayer * player = [AccedoMoviePlayer instance];
    PTMoviePlayerController * controller = [[PTMoviePlayerController alloc] initWithMediaPlayerItem:self.currentPlayerItem eventListeners:player.eventListeners errorRenderer:player.errorRenderer];

    self.currentPlayerItem = nil;
    
    return controller;
}

@end

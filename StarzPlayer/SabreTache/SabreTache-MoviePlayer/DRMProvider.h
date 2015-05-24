//
//  DRMProvider.h
//  CMore
//
//  Created by Csaba Tűz on 2014.02.05..
//
//
#import <Foundation/Foundation.h>
#import <SabreTache-Core/SynthesizeSingleton.h>

@class AccedoMoviePlayer;

/**
 @enum DRMFlowStatus enum

 Represents possible results of a DRM invocation attempt.
 */
typedef NS_ENUM(NSInteger, DRMFlowStatus)
{
    /** Some error has occured */
    DRMFlowStatusError,
    /** DRM flow was successful */
    DRMFlowStatusSuccess
};

/**
 `DRMFlowResult` represents the outcome of a DRM invocation attempt.

 @see `DRMProvider`
 */
@interface DRMFlowResult : NSObject

@property (assign, nonatomic) DRMFlowStatus status;
@property (assign, nonatomic) NSError * error;
@property (retain, nonatomic) NSMutableString * playableUrl;

@end

@interface DRMEntry : NSObject

@property (retain, nonatomic) NSString *mediaFormat;

@property (retain, nonatomic) NSString *assetURL;
@property (retain, nonatomic) NSString *licenseURL;

@property (retain, nonatomic) id userInfo;

@property (retain, nonatomic) NSString *logURL;

@end

@protocol DRMProvider <NSObject>

// Any initialization tasks
- (void)initializeDRM;

// Receives the DRM manifest URL and a license URL, and handles the appropriate DRM flow accordingly.
- (DRMFlowResult *) invokeDRM:(DRMEntry *)drmEntry;

// The DRM solution often determines the player to use. This method should return a virgin instance
// of a Media Player, which then can be used for displaying the media.
- (id)newMediaPlayerInstance;

// Responsible for cleaning up the DRM between playback sessions.
- (void)tearDownDRM;

- (void)destroyDRM;

@end

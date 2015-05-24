/*************************************************************************
 * ADOBE CONFIDENTIAL
 * ___________________
 *
 *  Copyright 2013 Adobe Systems Incorporated
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Adobe Systems Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Adobe Systems Incorporated and its
 * suppliers and are protected by all applicable intellectual property
 * laws, including trade secret and copyright laws.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Adobe Systems Incorporated.
 **************************************************************************/

//
//  PTAdMetadata.h
//  MediaPlayer
//
//  Created by Venkat Jonnadula on 1/27/13.
//

#import <Foundation/Foundation.h>

#import "PTMetadata.h"

@class PTTimeRangeCollection;

typedef enum
{
    PTAdSignalingModeDefault,
    PTAdSignalingModeManifestCues,
    PTAdSignalingModeCustomRanges,
    PTAdSignalingModeServerMap
} PTAdSignalingMode;

typedef enum
{
    PTAdBreakAsWatchedOnBegin,
    PTAdBreakAsWatchedOnEnd,
    PTAdBreakAsWatchedNever
} PTAdBreakAsWatched;

/**
 * The name of the key associated with this metadata type.
 * Used to retrieve the PTMetadata instance from a metadata collection.
 */
extern NSString *const PTAdResolvingMetadataKey;

/**
 * PTAdMetadata class provides properties that should be configured for resolving ads for a given media item.
 * All the required properties must be set to configure the player for successfully resolving ads.
 */
@interface PTAdMetadata : PTMetadata

/** @name Properties */
/**
 * An array of CMTimeRange type values for c3 window ads.
 * DEPRECATED: Use the timeRangeCollection property instead. Use PTTimeRangeCollectionType PTTimeRangeCollectionTypeMarkRanges.
 */
@property (nonatomic, strong) NSArray *externalAdRanges DEPRECATED_ATTRIBUTE;

/** @name Properties */
/**
 * Property to define behavior of ads on DVR streams.
 * If enableDVRAds is YES, the PSDK loads all the ads from the stream, even if they are before the live point.
 * Default value of enableDVRAds is NO.
 */
@property (nonatomic, assign) BOOL enableDVRAds;

/** @name Properties */
/**
 * Property to enable preroll on a live stream.
 * If enableLivePreroll is NO, PSDK does not make an explicit ad server call for the preroll prior to the content playback
 * and hence does not play preroll. This, however, has no impact on the midrolls.
 * Default value of enableLivePreroll is YES.
 */
@property (nonatomic, assign) BOOL enableLivePreroll;

/** @name Properties */
/**
 * Property to define the duration of the dvr window (in seconds) that must be resolved for content splicing cues.
 * This value is only relevant when 'enableDVRAds' is set to YES. The DVR window is resolved beginning from
 * the end of the live playlist and upto the value specified with this property.
 * A value of 0 indicates no ads in the dvr window are resolved and a negative value (default -1) indicates that all cues
 * in the dvr window must be resolved.
 */
@property (nonatomic, assign) NSTimeInterval cueResolutionDurationInDVRWindow;

/** @name Properties */
/**
 * Property to define the ad signaling mode used to insert ads.
 * The value can be one of the options defined in the PTAdSignalingMode enumeration.
 * Modes: PTAdSignalingModeDefault, PTAdSignalingModeManifestCues, PTAdSignalingModeServerMap
 */
@property (nonatomic) PTAdSignalingMode signalingMode;

/** @name Properties */
/**
 * Property to define the custom time ranges.
 * The value is an instance of PTTimeRangeCollection and defines the behavior based on the type of the PTTimeRangeCollection.
 */
@property (nonatomic, retain) PTTimeRangeCollection *timeRangeCollection;

/** @name Properties */
/**
 * Property to define when to mark an ad break as watched.
 * The value can be one of the options defined in the PTAdBreakIsWatched enumeration with PTAdBreakIsWatchedOnBegin as default.
 * Modes: PTAdBreakAsWatchedOnBegin, PTAdBreakAsWatchedOnEnd, PTAdBreakAsWatchedNever
 */
@property (nonatomic) PTAdBreakAsWatched adBreakAsWatched;

@end

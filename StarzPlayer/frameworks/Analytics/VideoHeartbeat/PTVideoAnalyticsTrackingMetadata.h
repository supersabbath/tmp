/*************************************************************************
 * ADOBE CONFIDENTIAL
 * ___________________
 *
 *  Copyright 2014 Adobe Systems Incorporated
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

#import <Foundation/Foundation.h>

#import <PSDKLibrary/PSDKLibrary.h>

@class PTAd, PTVideoAnalyticsChapterData;

/**
 * The name of the key associated with this VideoAnalyticsTracker instance.
 * Used to retrieve the PTVideoAnalyticsTracker instance from a metadata collection.
 */
extern NSString *const PTVideoAnalyticsTrackingMetadataKey;

/**
 *  The PTVideoAnalyticsVideoMetadataBlock is called for every video that is to be tracked.
 */
typedef NSDictionary *(^PTVideoAnalyticsVideoMetadataBlock)();

/**
 *  The PTVideoAnalyticsAdMetadataBlock is called for every ad that is to be tracked.
 */
typedef NSDictionary *(^PTVideoAnalyticsAdMetadataBlock)(PTAd *ad);

/**
 *  The PTVideoAnalyticsChapterMetadataBlock is called for every chapter that is to be tracked.
 */
typedef NSDictionary *(^PTVideoAnalyticsChapterMetadataBlock)(PTVideoAnalyticsChapterData *chapter);



/**
 * PTVideoAnalyticsTrackingMetadata class contains property metadata specific to VideoHeartbeat tracking within the SDK.
 *
 */
@interface PTVideoAnalyticsTrackingMetadata : PTTrackingMetadata

/** @name Properties */
/**
 * String representing the URL of the tracking endpoint on the backend side.
 */
@property (nonatomic, readonly) NSString *trackingServer;

/** @name Properties */
/**
 * String representing the content publisher unique identifier.
 */
@property (nonatomic, readonly) NSString *publisher;

/** @name Properties */
/**
 * String representing the playerName.
 * Default value is "PTMediaPlayer"
 */
@property (nonatomic, retain) NSString *playerName;

/** @name Properties */
/**
 * String representing the name of the content distribution channel.
 * Default value is "unknown".
 */
@property (nonatomic, retain) NSString *channel;

/** @name Properties */
/**
 * String representing the name of the video.
 */
@property (nonatomic, retain) NSString *videoName;

/** @name Properties */
/**
 * String representing a unique id for the video.
 */
@property (nonatomic, retain) NSString *videoId;

/** @name Properties */
/**
 * Specifies an array of chapters (each array entry is an instance of PTVideoAnalyticsChapterData).
 * For chapter tracking to be enabled, set the enableChapterTracking boolean property to YES.
 */
@property (nonatomic, retain) NSArray *chapters;

/** @name Properties */
/**
 * Specifies whether video chapter tracking is enabled (default value is NO).
 */
@property (nonatomic, assign) BOOL enableChapterTracking;

/** @name Properties */
/**
 * Specifies whether ssl should be used for tracking calls
 */
@property (nonatomic, assign) BOOL useSSL;

/** @name Properties */
/**
 * A block returning a dictionary of video related custom metadata key-value pairs to be attached to the analytics calls
 * Return a null value to clear the previous custom metadata dictionary
 */
@property (nonatomic, copy) PTVideoAnalyticsVideoMetadataBlock videoMetadataBlock;

/** @name Properties */
/**
 * A block returning a dictionary of ad related custom metadata key-value pairs to be attached to the analytics calls
 * Return a null value to clear the previous custom metadata dictionary
 */
@property (nonatomic, copy) PTVideoAnalyticsAdMetadataBlock adMetadataBlock;

/** @name Properties */
/**
 * A block returning a dictionary of chapter related custom metadata key-value pairs to be attached to the analytics calls
 * Return a null value to clear the previous custom metadata dictionary
 */
@property (nonatomic, copy) PTVideoAnalyticsChapterMetadataBlock chapterMetadataBlock;

/** @name Properties */
/**
 * Activates console debug tracing.
 */
@property (nonatomic, assign) BOOL debugLogging;

/** @name Properties */
/**
 * Activates the "quiet" mode (suppress the output network calls).
 */
@property (nonatomic, assign) BOOL quietMode;

/** @name Constructor method */
/**
 * @param trackingServer The URL of the backend endpoint where the VideoHeartbeat
 *                       tracking data is being collected.
 *
 * @param publisher Unique identifier for the content publisher.
 *
 * NOTE: the constructor method raises an exception if any of the input parameters
 *       are either *nil* or the empty string.
 *
 * NOTE: calling the *init* constructor directly is forbidden. Doing so will raise
 *       an exception.
 */
- (id) initWithTrackingServer:(NSString *)trackingServer
                 publisher:(NSString *)publisher;

@end
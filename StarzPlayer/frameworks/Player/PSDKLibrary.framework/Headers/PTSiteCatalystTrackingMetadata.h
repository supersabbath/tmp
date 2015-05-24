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
//  PTSiteCatalystTrackingMetadata.h
//  MediaPlayer
//
//  Created by Prerna Vij on 2/28/13.
//

#import <Foundation/Foundation.h>
#import "PTTrackingMetadata.h"

@class ADMS_Measurement;
@class ADMS_MediaMeasurement;

/**
 * PTSiteCatalystTrackingMetadata class contains property metadata specific to SiteCatalyst tracking within the SDK
 *
 */
@interface PTSiteCatalystTrackingMetadata : PTTrackingMetadata

/** @name Properties */
/**
 * String representing the playerName.
 * Default value is "PTMediaPlayer"
 */
@property (nonatomic , retain) NSString *playerName;

/** @name Properties */
/**
 * ADMS_Measurement shared instance to be used for sitecatalyst app tracking.
 *
 */
@property (nonatomic , assign) ADMS_Measurement *appMeasurementInstance;

/** @name Properties */
/**
 * ADMS_MediaMeasurement shared instance to be used for sitecatalyst media tracking.
 */
@property (nonatomic,  assign) ADMS_MediaMeasurement *mediaMeasurementInstance;

@end

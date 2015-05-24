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

//
//  PTVideoAnalyticsChapterData.h
//  VideoAnalytics
//
//  Created by Venkat Jonnadula on 7/1/14.
//  Copyright (c) 2014 Adobe Systems Inc. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>

/**
 * PTVideoAnalyticsChapterData instance holds data specific to a chapter within the main content.
 * Chapter range should be relative to the main content without any runtime spliced ad durations.
 */
@interface PTVideoAnalyticsChapterData : NSObject

/** @name Properties */
/**
 * String representing a unique name for this chapter
 */
@property (nonatomic, retain) NSString *name;

/** @name Properties */
/**
 * A time range for this chapter within the main content
 */
@property (nonatomic, assign) CMTimeRange range;

@end

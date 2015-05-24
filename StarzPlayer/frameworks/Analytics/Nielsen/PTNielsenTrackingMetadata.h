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
//  PTNielsenMetadata.h
//  PSDKLibrary
//
//  Created by Venkat Jonnadula on 6/15/14.
//  Copyright (c) 2014 Adobe Systems Inc. All rights reserved.
//

#import <PSDKLibrary/PSDKLibrary.h>

/**
 * The name of the key associated with this PTNielsenTracker instance.
 */
extern NSString *const PTNielsenTrackingMetadataKey;

/**
 * PTNielsenTrackingMetadata instance provides the information necessary to initialize a PTNielsenTracker instance
 * and required channel and video metadata information.
 */
@interface PTNielsenTrackingMetadata : PTMetadata

/** @name Properties */
/**
 * Channel metadata information dictionary
 */
@property (nonatomic, retain) NSDictionary *channelInfo;

/** @name Properties */
/**
 * Metadata information dictionary from content. If available, metadata should come from video cms.
 */
@property (nonatomic, retain) NSDictionary *metadataInfo;

@end

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
//  PSDKNielsenTracker.h
//  PSDKLibrary
//
//  Created by Venkat Jonnadula on 6/15/14.
//  Copyright (c) 2014 Adobe Systems Inc. All rights reserved.
//

@class PTMediaPlayer;

/**
 * PTNielsenTracker instance provided Nielsen tracking capability for PSDK playable streams
 */
@interface PTNielsenTracker : NSObject

/**
 * Initializes the tracker instance with an app information dictionary
 */
- (id)initWithAppInfo:(NSDictionary *)info;

/**
 * Begins tracking with the given media player instance
 */
- (void)attachMediaPlayer:(PTMediaPlayer *)mediaPlayer;

/**
 * Load metadata from content or ad.
 * @param metadata A dictionary of metadata that needs to be provided for tracking
 */
- (void)loadMetadata:(NSDictionary *)metadata;

/**
 * Get the URL of the web page that is used for giving user a chance to
 * opt out from the Nielsen measurements. Returns nil if there is no valid Nielsen tracker instance.
 */
- (NSString *)optOutURLString;

/**
 * Disable metering for the app due to user opt out. This method does nothing if there is no valid Nielsen tracker instance.
 * Returns YES if the opt out is handled and NO otherwise.
 * @param optOut string to disable or enable
 */
- (BOOL)userOptOut:(NSString *)optOut;

/**
 * Retrieve Nielsen ID for user opt-in or opt-out purpose. Returns nil if there is no valid Nielsen tracker instance
 */
- (NSString *)getNielsenId;

@end

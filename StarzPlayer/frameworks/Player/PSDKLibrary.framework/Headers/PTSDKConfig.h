//
//  PSDKConfig.h
//  PSDKLibrary
//
//  Created by Prerna Vij on 4/30/13.
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

#import <Foundation/Foundation.h>

/**
 * PTSDKConfig is a static class that exposes PSDK global settings.
 */
@interface PTSDKConfig:NSObject

/**
 * Sets the array of custom ad markers that the player will accept in addition to default ones.
 * Each tag in the array is expected to be a NSString. For example: #EXT-X-AD, #EXT-X-CUE-OUT etc.
 */
+ (void)setAdTags:(NSArray *)adTags;

/**
 * Returns the array of ad markers being used by the player. 
 * If no custom ad markers are set, player uses default only ad markers.
 */
+ (NSArray *)adTags;

/**
 * Sets the array of HLS tags that the player notifies about.
 * Each tag in the array is expected to be a NSString. For example: #EXT-OATCLS-SCTE35.
 */
+ (void)setSubscribedTags:(NSArray *)subscribedTags;

/**
 * Returns the array of current subscribed tags.
 */
+ (NSArray *)subscribedTags;

@end

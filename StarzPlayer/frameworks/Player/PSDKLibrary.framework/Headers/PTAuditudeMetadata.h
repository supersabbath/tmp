/*************************************************************************
 * ADOBE CONFIDENTIAL
 * ___________________
 *
 *  Copyright 2012 Adobe Systems Incorporated
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
//  PTAuditudeMetadata.h
//
//  Created by Catalin Dobre on 3/25/12.
//

#import <Foundation/Foundation.h>

#import "PTAdMetadata.h"


/**
 * PTAuditudeMetadata class provides properties that should be configured for resolving auditude ads for a given media item.
 * All the required properties must be set to configure the player for successfully resolving ads.
 */
@interface PTAuditudeMetadata : PTAdMetadata

/** @name Properties */
/**
 * The domain from which ads should be fetched. The value of this property cannot be nil and must always
 * refer to a valid ad domain.
 */
@property (nonatomic, retain) NSString *domain;

/** @name Properties */
/**
 * The zoneId associated with the publisher. The value of this property must not be nil.
 */
@property (nonatomic) NSInteger zoneId;

/** @name Properties */
/**
 * A dictionary of key-values used for ad targeting. A nil value can be used if key-value targeting is not configured on the
 * publisher account.
 */
@property (nonatomic, retain) NSDictionary *targetingParameters;

/** @name Properties */
/**
 * A dictionary of key-values used as pass-through parameters.
 */
@property (nonatomic, retain) NSDictionary *customParameters;

/** @name Properties */
/**
 * The default media Id associated with the auditude publisher account.
 */
@property (nonatomic, retain) NSString *defaultMediaId;

/** @name Properties */
/**
 * The user agent string to use for ad requests and tracking pings made through Auditude Ad Resolver.
 * If not specified, the default user agent assigned by the OS is used.
 */
@property (nonatomic, retain) NSString *userAgent;

/** @name Properties */
/**
 * Enable/Disable Dynamic Creative Re-Packaging feature.
 */
@property (nonatomic) BOOL isCreativeRepackagingEnabled;

@end

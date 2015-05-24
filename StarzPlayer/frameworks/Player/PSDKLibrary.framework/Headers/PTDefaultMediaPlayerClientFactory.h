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
//  PTMediaPlayerClientDefaultFactory.h
//  MediaPlayer
//
//  Created by - on 1/23/14.
//

#import <Foundation/Foundation.h>
#import "PTMediaPlayerClientFactory.h"
#import "PTOpportunityResolver.h"
#import "PTContentResolver.h"
#import "PTAdPolicySelector.h"

/**
 * PTMediaPlayerClientDefaultFactory class is the default PTMediaPlayerClientFactory implementation. It provides the available PTOpportunityResolver, PTContentResolver and PTAdPolicySelector instances.
 */

@interface PTDefaultMediaPlayerClientFactory : NSObject <PTMediaPlayerClientFactory>

+ (PTDefaultMediaPlayerClientFactory *)defaultFactory;

#pragma mark Set/Get Opportunity resolvers

/** @name registerOpportunityResolver: */
/**
 * Register a Class following the PTOpportunityResolverDelegate protocol used for custom opportunity resolving.
 */
- (void)registerOpportunityResolver:(id<PTOpportunityResolver>) opportunityResolver;

/** @name clearOpportunityResolver: */
/**
 * Unregisters a Class following the PTOpportunityResolverDelegate protocol used for custom opportunity resolving.
 */
- (void)clearOpportunityResolver:(id<PTOpportunityResolver>) opportunityResolver;

/** @name clearOpportunityResolvers: */
/**
 * Unregisters all the stored Classes used for custom opportunity resolving.
 * WARNING: This also clears the default oportunity resolver used for resolve default ad cue markers. Use it only if this is the intended behavior.
 */
- (void)clearOpportunityResolvers;

/** @name retrieveOpportunityDetectors */
/**
 * Returns the currently available PTOpportunityResolver instances
 */
- (NSArray *)retrieveOpportunityResolvers;

#pragma mark Set/Get Content/Ad resolvers

/** @name registerContentResolver: */
/**
 * Register a Class following the PTContentResolver protocol used for custom ad/content resolving.
 */
- (void)registerContentResolver:(id<PTContentResolver>) contentResolver;

/** @name clearOpportunityResolverClass: */
/**
 * Unregisters a Class following the PTContentResolver protocol used for custom ad/content resolving
 */
- (void)clearContentResolver:(id<PTContentResolver>) contentResolver;

/** @name clearContentResolvers: */
/**
 *  Unregisters all the stored instances used for custom content/ad resolving.
 *  Warning: Removes the PTDefaultAdContentResolver
 */
- (void)clearContentResolvers;

/** @name retrieveContentResolvers */
/**
 * Returns the currently available PTContentResolver instances
 */
- (NSArray *)retrieveContentResolvers;


#pragma mark Set/Get Ad Policy Selector

/** @name Ad Policy Selector */
/**
 * Registers an ad policy selector instance for defining ad behaviors.
 * Provide a nil argument to use the default ad policy selector provided by PSDK.
 * Unless a new isntance is provided, the same ad policy selector instance will be used.
 * If the application requires specific logic for each content, register a new ad policy selector before playing each content
 * or update the data provided to the instance
 */
- (void)registerAdPolicySelector:(id<PTAdPolicySelector>)adPolicySelector;

/** @name Ad Policy Selector */
/**
 * Returns the ad policy selector for defining ad behaviors
 */
- (id<PTAdPolicySelector>)retrieveAdPolicySelector;


@end
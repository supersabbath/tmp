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
//  PTPlacementOpportunity.h
//  MediaPlayer
//
//  Created by - on 1/23/14.
//

#import <Foundation/Foundation.h>
#import "PTMetadata.h"
#import "PTTimedMetadata.h"
#import "PTAdMetadata.h"

/**
 * PTPlacementOpportunity class represents a point in time of the stream where there is a content placement opportunity.
 * A PTOpportunityResolver creates the PTPlacementOpportunity when required based on the provided PTTimedMetadata.
 */

typedef enum
{
    PTOpportunityTypeNone = 0,
	PTOpportunityTypeAdvertisement,
	PTOpportunityTypeBlackout,
} PTOpportunityType;

typedef enum
{
	PTPlacementTypeAdPreroll = 0,
	PTPlacementTypeAdMidroll,
    PTPlacementTypeAdPostroll,
    PTPlacementTypeAdTimeline,
    PTPlacementTypeNone
} PTPlacementType;


@interface PTPlacementOpportunity : NSObject

@property (nonatomic, retain) NSString *opportunity_id;
@property (nonatomic, retain) NSMutableDictionary *attributes;
@property (nonatomic, assign) PTPlacementType placement;
@property (nonatomic, assign) PTOpportunityType type;
@property (nonatomic, assign) CMTime time;
@property (nonatomic, assign) double duration;
@property (nonatomic, retain) PTTimedMetadata *timedMetadata;
@property (nonatomic, retain) PTMetadata *metadata;

- (id)initWithTimedMetadata:(PTTimedMetadata *)timedMetadata;

/** @name Advertisement Opportunity */
/**
 * Returns a PTPlacementOpportunity of type PTOpportunityTypeAdvertisement
 */
+ (PTPlacementOpportunity *) advertisementOpportunityWithTimedMetadata:(PTTimedMetadata *)timedMetadata;

/** @name Blackout Opportunity */
/**
 * Returns a PTPlacementOpportunity of type PTOpportunityTypeBlackout
 */
+ (PTPlacementOpportunity *) blackoutOpportunityWithTimedMetadata:(PTTimedMetadata *)timedMetadata;

/** @name Empty Opportunity */
/**
 * Returns a PTPlacementOpportunity of type PTOpportunityTypeNone
 */
+ (PTPlacementOpportunity *) emptyOpportunityWithTimedMetadata:(PTTimedMetadata *)timedMetadata;

@end

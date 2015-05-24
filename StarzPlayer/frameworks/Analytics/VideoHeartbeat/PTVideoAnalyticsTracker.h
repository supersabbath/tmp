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

@class PTMediaPlayer;

/**
 * PTVideoAnalyticsTracker is the primary class to enable Video Heartbeat Tracking with PSDK.
 * A new tracker instance must be created for each media player item that is played through a PTMediaPlayer instance.
 * Before a new video content is played, the previous tracker instance must be released and a new tracker must be created and initialized.
 * NOTE: Do not release the tracker instance during a video complete or a status complete notification. This may interfere
 * with certain video tracking events.
 */
@interface PTVideoAnalyticsTracker : NSObject

/**
 * Initializes the tracker for a given media player.
 */
- (id) initWithMediaPlayer:(PTMediaPlayer *)mediaPlayer;

@end

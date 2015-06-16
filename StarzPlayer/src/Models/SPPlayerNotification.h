//
//  SPPlayerNotification.h
//  StarzPlayer
//
//  Created by Fernando Canon on 08/06/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPPlayerViewController;
@class PTSVideoItem;

@interface SPPlayerNotification : NSNotification


/*
 Notfication Types .. Objects registered to these notifications must implement SPPlayerControllerObserverProtocol
 */

FOUNDATION_EXPORT NSString *const SPPlayerChangeContentNotification;
FOUNDATION_EXPORT NSString *const SPPlayerDidLoadNotification;
FOUNDATION_EXPORT NSString *const SPPlayerStatusPlayingNotification;

FOUNDATION_EXPORT NSString *const SPPlayerPlaybackWillFinish;
FOUNDATION_EXPORT NSString *const SPPlayerStatusPausedNotification;
FOUNDATION_EXPORT NSString *const SPPlayerStatusStoppedNotification;
FOUNDATION_EXPORT NSString *const SPPlayerStatusCompletedNotification;
FOUNDATION_EXPORT NSString *const SPPPlayerStatusErrorNotification;
FOUNDATION_EXPORT NSString *const SPPlayerWillStopNotification;

@property(atomic, retain) id object;

+(id) notificationForplayer:(SPPlayerViewController*)player Item:(PTSVideoItem*)currentItem andIdentifier:(NSString*) identfier;
/*
 This expects to receive a dictionary with error an current item
 */
+(id) notificationForplayer:(SPPlayerViewController*)player withUserInfo:(NSDictionary*) userInf andIdentifier:(NSString*) identfier ;

-(instancetype)initWithObject:(id) player userInfo:(NSDictionary*) userdic andIdentifier:(NSString*) identifier;

-(NSString*) name;

-(NSDictionary*) userInfo;

//-(id) object;

-(PTSVideoItem*) currentVideo;
@end

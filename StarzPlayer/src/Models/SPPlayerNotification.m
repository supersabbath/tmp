//
//  SPPlayerNotification.m
//  StarzPlayer
//
//  Created by Fernando Canon on 08/06/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import "SPPlayerNotification.h"
#import "PTSVideoItem.h"
#import "SPPlayerViewController.h"

@implementation SPPlayerNotification {
    id object;
    NSDictionary *userInfo;
    NSString *name;
}

@synthesize object;
/*
 Notifications Read header file
 @see: SPPlayerControllerObserverProtocol
 **/
NSString *const SPPlayerChangeContentNotification =@"SPPlayerChangeContentNotification";
NSString *const SPPlayerDidLoadNotification = @"SPPlayerDidLoadNotification";
NSString *const SPPlayerStatusPlayingNotification = @"SPPlayerStatusPlayingNotification";

NSString *const SPPlayerPlaybackWillFinish = @"SPPlayerPlaybackWillFinish";
NSString *const SPPlayerStatusPausedNotification = @"SPPlayerStatusPausedNotification";
NSString *const SPPlayerStatusStoppedNotification = @"SPPlayerStatusStoppedNotification";
NSString *const SPPlayerStatusCompletedNotification = @"SPPlayerStatusCompletedNotification";
NSString *const SPPPlayerStatusErrorNotification = @"SPPPlayerStatusErrorNotification";
NSString *const SPPlayerWillStopNotification = @"SPPlayerWillStopNotification";

/*
 Notfication Types .. Objects registered to these notifications must implement SPPlayerControllerObserverProtocol
 */

+(id) notificationForplayer:(SPPlayerViewController*)player Item:(PTSVideoItem*)currentItem andIdentifier:(NSString*) identfier {
    
    SPPlayerNotification *noty = [[SPPlayerNotification alloc] initWithObject:player userInfo:@{@"videoAsset":currentItem} andIdentifier:identfier];
    return noty;
}

+(id) notificationForplayer:(SPPlayerViewController*)player withUserInfo:(NSDictionary*) userInf andIdentifier:(NSString*) identfier {
    
    SPPlayerNotification *noty = [[SPPlayerNotification alloc] initWithObject:player userInfo:userInf andIdentifier:identfier];
    return noty;
}

- (instancetype)initWithObject:(id) player userInfo:(NSDictionary*) userdic andIdentifier:(NSString*) identifier
{
    
    if (self) {
        self.object = player;
        self.userInfo = userdic;
        self.name = identifier;
    }
    return self;
}


//-(void) setObject:(id)newObj
//{
//
//    object = newObj;
//}

//-(id) object {
//    return object;
//}

-(void) setUserInfo:(NSDictionary *)infoDic {
    
    userInfo = [infoDic copy] ;
}

-(void) setName:(NSString*)newName
{
    name = [newName copy];
}



-(NSString*) name

{
    return name;
    
}

-(NSDictionary*) userInfo {
    
    return  userInfo;
    
}


-(PTSVideoItem*) currentVideo {
    
    return self.userInfo[@"videoAsset"];
}

@end




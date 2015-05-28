/************************************************************************************************
 
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2013 Adobe Systems Incorporated
 * All Rights Reserved.
 
 * NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the
 * terms of the Adobe license agreement accompanying it.  If you have received this file from a
 * source other than Adobe, then your use, modification, or distribution of it requires the prior
 * written permission of Adobe.
 
************************************************************************************************/

//
//  PTSVideoItem.m
//  PrimetimeSDKSample
//
//  Created by Venkat Jonnadula on 1/31/13.
//

#import "PTSVideoItem.h"

@implementation PTSVideoItem


@synthesize url,title,mediaId,streamType,contentDescription,drmToken,drmUserName,drmUserPassword,thumbnail,stripContentUrl;

- (id)initWithDictionary:(NSDictionary *)info
{
    if (self = [super init])
    {
        if (info)
        {
            
              
     /**       NSString *sessionPath = [[NSBundle mainBundle] pathForResource:@"SessionData" ofType:@"plist"];
                
            NSDictionary *sessionData = [NSDictionary dictionaryWithContentsOfFile:sessionPath];
        */    
           // url = [sessionData objectForKey:@"videoURL"];//[info objectForKey:@"ContentURL"];
            url = [info objectForKey:@"ContentURL"];
            title = [info objectForKey:@"Title"];
            mediaId = [info objectForKey:@"MediaID"];
            streamType = [info objectForKey:@"StreamType"];
            contentDescription = [info objectForKey:@"Description"];
            drmToken = [info objectForKey:@"DrmToken"];
            drmUserName =[info objectForKey:@"DrmUserName"]; // @"http://mps.theplatform.com/data/Account/2458698081";//
            drmUserPassword = [info objectForKey:@"DrmUserPassword"];//[sessionData objectForKey:@"token"];
        
            thumbnail = [info objectForKey:@"Thumbnail"];
            stripContentUrl =@"http://mena-cdn-lb.aws.playco.com/MGM/GIRLWITHTHEDRAGONTATTOOY2011M/GIRLWITHTHEDRAGONTATTOOY2011M.fs";
 
        }
    }
    
    return self;
}



@end

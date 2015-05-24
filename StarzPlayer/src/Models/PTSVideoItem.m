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

@synthesize url = _url;
@synthesize title = _title;
@synthesize mediaId = _mediaId;
@synthesize streamType = _streamType;
@synthesize description = _description;
@synthesize drmToken = _drmToken;
@synthesize drmUserName = _drmUserName;
@synthesize drmUserPassword = _drmUserPassword;
@synthesize thumbnail = _thumbnail;
@synthesize tags = _tags;
@synthesize auditudeInfo = _auditudeInfo;

- (id)initWithDictionary:(NSDictionary *)info
{
    if (self = [super init])
    {
        if (info)
        {
            
              
            NSString *sessionPath = [[NSBundle mainBundle] pathForResource:@"SessionData" ofType:@"plist"];
                
            NSDictionary *sessionData = [NSDictionary dictionaryWithContentsOfFile:sessionPath];
            
            _url = [sessionData objectForKey:@"videoURL"];//[info objectForKey:@"ContentURL"];
            //_url = [info objectForKey:@"ContentURL"];
            _title = [info objectForKey:@"Title"];
            _mediaId = [info objectForKey:@"MediaID"];
            _streamType = [info objectForKey:@"StreamType"];
            _description = [info objectForKey:@"Description"];
            _drmToken = [info objectForKey:@"DrmToken"];
            _drmUserName = @"http://mps.theplatform.com/data/Account/2458698081";// [info objectForKey:@"DrmUserName"];
            _drmUserPassword =[sessionData objectForKey:@"token"];
            // [info objectForKey:@"DrmUserPassword"];
            _thumbnail = [info objectForKey:@"Thumbnail"];
//            _tags = [[NSMutableArray alloc] init];
//            
//            NSString *tagString = [info objectForKey:@"Tags"];
//            if (tagString)
//            {
//                NSArray *rawTags = [tagString componentsSeparatedByString:@","];
//                for (int i = 0; i < rawTags.count; i++)
//                {
//                    [_tags addObject:[[rawTags objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
//                }
//            }
//            
//            NSDictionary *auditudeDict = [info objectForKey:@"Auditude"];
//            if (auditudeDict)
//            {
//                _auditudeInfo = [NSMutableDictionary dictionaryWithDictionary:auditudeDict];
//            }
        }
    }
    
    return self;
}

- (BOOL)hasTag:(NSString *)tag
{
    return [_tags indexOfObject:tag] != NSNotFound;
}


@end

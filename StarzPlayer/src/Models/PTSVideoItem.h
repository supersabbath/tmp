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
//  PTSVideoItem.h
//  PrimetimeSDKSample
//
//  Created by Venkat Jonnadula on 1/31/13.
//

@interface PTSVideoItem : NSObject
{
    NSString *url;
    NSString *title;
    NSString *mediaId;
    NSString *streamType;
    NSString *description;
    NSString *drmToken;
    NSString *drmUserName;
    NSString *drmUserPassword;
    NSString *thumbnail;
 
}

- (id)initWithDictionary:(NSDictionary *)info;
- (BOOL)hasTag:(NSString *)tag;

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *mediaId;
@property (nonatomic, strong) NSString *streamType;
@property (nonatomic, strong) NSString *contentDescription;
@property (nonatomic, strong) NSString *drmToken;
@property (nonatomic, strong) NSString *drmUserName;
@property (nonatomic, strong) NSString *drmUserPassword;
@property (nonatomic, strong) NSString *thumbnail;
@property (nonatomic, strong) NSString * stripContentUrl;

@end

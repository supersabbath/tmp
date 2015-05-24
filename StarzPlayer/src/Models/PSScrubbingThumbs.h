//
//  PSScrubbingThumbs.h
//  StarzPlayer
//
//  Created by Fernando Canon on 21/05/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PSScrubbingCompletion)(BOOL);

@interface PSScrubbingThumbs : NSObject

@property (assign, nonatomic) int height;
@property (assign, nonatomic) int width;
@property (assign, nonatomic) int startTime;
@property (assign, nonatomic) int endTime;
@property (assign, nonatomic) int imageCount;

@property (strong, nonatomic) NSArray * thumbnails;
@property (strong, nonatomic) NSURL * url;

-(void) fetchThumbsWithCompletion:(PSScrubbingCompletion) callback;

@end


@interface PSScrubbingThumbModel : NSObject

@property (strong, nonatomic) NSString * data;

@property (strong, nonatomic, readonly) UIImage * image;

@end
//
//  NSDate.h
//  Viasat
//
//  Copyright (c) 2011 Accedo Broadband AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (VSExtras)

+ (NSDate *) unadjustedLocalDate;
+ (NSDate *) localDate;

+ (NSDate *) localDay;

+ (NSTimeInterval) localTimeIntervalSinceLocalDay;
+ (NSTimeInterval) localTimeIntervalSinceDay:(NSDate *)dayDate;

+ (NSDate *)dayAfterDay:(NSDate *)date;
+ (NSDate *)dayBeforeDay:(NSDate *)date;

-(NSDate *) toGlobalTime;
-(NSDate *) toLocalTime;
@end

//
//  NSDate.m
//  Viasat
//
//  Copyright (c) 2011 Accedo Broadband AB. All rights reserved.
//
#import <Foundation/Foundation.h>

@implementation NSDate (VSExtras)

+ (NSDate *) unadjustedLocalDate {
    NSDate *current = [NSDate dateWithTimeInterval:[[NSTimeZone localTimeZone] secondsFromGMT] sinceDate:[NSDate date]];
    return current;
}

+ (NSDate *) localDate {
    NSDate *current = [self unadjustedLocalDate];
   // NSDate *adjusted = [current dateByAddingTimeInterval:[VSSDPApplicationManager sharedApplicationManager].boxTimeDelta];
    return current;
}

+ (NSDate *) localDay {
    NSDate *localNow = [NSDate localDate];
    int daysSince1970 = [localNow timeIntervalSince1970] / 86400;
    return [NSDate dateWithTimeIntervalSince1970:daysSince1970 * 86400];
}

+ (NSTimeInterval) localTimeIntervalSinceLocalDay {
    NSDate *localNow = [NSDate localDate];
    int daysSince1970 = [localNow timeIntervalSince1970] / 86400;
    NSDate *localDay = [NSDate dateWithTimeIntervalSince1970:daysSince1970 * 86400];
    return [localNow timeIntervalSinceDate:localDay];
}

+ (NSTimeInterval) localTimeIntervalSinceDay:(NSDate *)dayDate {
    NSDate *localNow = [NSDate localDate];
    return [localNow timeIntervalSinceDate:dayDate];
}

+ (NSDate *)dayAfterDay:(NSDate *)date {
    int days = [date timeIntervalSince1970] / 86400;
    NSDate *nextDay = [NSDate dateWithTimeIntervalSince1970:(days + 1) * 86400];
    return nextDay;
}
+ (NSDate *)dayBeforeDay:(NSDate *)date {
    int days = [date timeIntervalSince1970] / 86400;
    NSDate *nextDay = [NSDate dateWithTimeIntervalSince1970:(days - 1) * 86400];
    return nextDay;
}

-(NSDate *) toLocalTime
{
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: self];
    return [NSDate dateWithTimeInterval: seconds sinceDate: self];
}

-(NSDate *) toGlobalTime
{
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSInteger seconds = -[tz secondsFromGMTForDate: self];
    return [NSDate dateWithTimeInterval: seconds sinceDate: self];
}

@end

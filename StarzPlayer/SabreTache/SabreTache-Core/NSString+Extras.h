//
//  NSString+Extras.h
//  Viasat
//
//  Copyright (c) 2011 Accedo Broadband AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (VSExtras)


- (NSString *)urlEncode;

- (NSString *)md5;

+ (NSString *) uuidString;

@end

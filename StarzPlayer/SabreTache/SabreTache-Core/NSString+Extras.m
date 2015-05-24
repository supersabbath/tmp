//
//  NSString+Extras.m
//  Viasat
//
//  Copyright (c) 2011 Accedo Broadband AB. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (VSExtras)

-(NSString *)urlEncode {
    CFStringRef ref = CFURLCreateStringByAddingPercentEscapes(NULL,
                                            (CFStringRef)self,
                                            NULL,
                                            (CFStringRef)@"!*'();:@+$,/?%#[]=&",
                                            kCFStringEncodingUTF8);
    NSString * final = [(__bridge NSString *)ref copy];
    CFRelease(ref);
    return final;
}

- (NSString *)md5 {
	const char *cString = [self UTF8String];
	unsigned char result[16];
	CC_MD5(cString, (unsigned int)strlen(cString), result);
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], 
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];
}

+ (NSString *) uuidString {
	CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
	CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuid);
	NSString *uuidNSString = [NSString stringWithString:(__bridge NSString *)uuidString];
	CFRelease(uuidString);
	CFRelease(uuid);
	return [uuidNSString lowercaseString];
}

@end

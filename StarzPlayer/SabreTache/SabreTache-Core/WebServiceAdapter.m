//
//  WSAdapter.m
//
//  Created by Csaba Tűz on 2014.02.22..
//  Copyright (c) 2014 All rights reserved.
//
#import <SystemConfiguration/SystemConfiguration.h>

#import "WebServiceAdapter.h"
#import "WebServiceAdapter_internal.h"

#import "BaseWebServiceResource.h"
#import "LanguageManager.h"

static AFNetworkReachabilityStatus prevStatus;

@interface WebServiceAdapter()

@property (retain, nonatomic, readwrite) NSURL * baseURL;

@property (retain, nonatomic) NSOperationQueue * requestQueue;
@property (retain, nonatomic) NSDictionary* requestPathsDictionary;
@end

static BOOL alreadyAlerted = NO;

@implementation WebServiceAdapter

@synthesize httpClient;
@synthesize objectManager;

- (id)initWithBaseURL:(NSURL *)baseURL {
    self = [super init];
    if (self) {
        NSAssert(baseURL != nil, @"Base URL must be provided for WebServiceAdapter");
        self.baseURL = baseURL;
        self.httpClient = [[AFHTTPClient alloc] initWithBaseURL:self.baseURL];
        
        self.objectManager = [[RKObjectManager alloc] initWithHTTPClient:self.httpClient];
        __weak WebServiceAdapter* weakSelf = self;
        [self.objectManager.HTTPClient setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            @synchronized([WebServiceAdapter class])
            {
                if (!alreadyAlerted && status == AFNetworkReachabilityStatusNotReachable && prevStatus != status) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ACLocalizedString(@"key_webServiceAlert_alert")
                                                                    message:ACLocalizedString(@"key_webServiceAlert_networkError")
                                                                   delegate:nil
                                                          cancelButtonTitle:ACLocalizedString(@"key_webServiceAlert_ok")
                                                          otherButtonTitles:nil];
                    [alert show];
                    [weakSelf.requestQueue cancelAllOperations];
                    alreadyAlerted = YES;
                }
                
                if (status != AFNetworkReachabilityStatusNotReachable)
                {
                    alreadyAlerted = NO;
                }
                prevStatus = status;

            }
        }];
        
        self.cookies = [NSMutableArray array];
        
        self.requestQueue = [[NSOperationQueue alloc] init];
        [self.requestQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
        
        self.defaultRequestTimeout = 30;
    }
    return self;
}

- (void)setHTTPUsername:(NSString *)username andPassword:(NSString *)password
{
    [self.httpClient setAuthorizationHeaderWithUsername:username password:password];
    self.defaultCredential = [NSURLCredential credentialWithUser:username password:password persistence:NSURLCredentialPersistenceForSession];
    [self.httpClient setDefaultCredential:self.defaultCredential];
}

- (void)setMaxConcurrent:(int)maxConcurrent
{
    [self.requestQueue setMaxConcurrentOperationCount:maxConcurrent];
}

- (void)updateBaseURL:(NSURL *)newBaseURL
{
    //NSAssert(newBaseURL != nil, @"Base URL must be provided for WebServiceAdapter");
    self.baseURL = newBaseURL;
}

- (void)dealloc {
    self.httpClient = nil;
    self.objectManager = nil;
    
    [self.requestQueue cancelAllOperations];
    self.requestQueue = nil;
}

#pragma mark - Cookie handling

- (NSArray *)cookies
{
    NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSMutableArray * result = [NSMutableArray array];
    for (NSHTTPCookie * cookie in cookies)
    {
        if ([cookie.domain isEqual:self.baseURL.host] && ([self.baseURL.path length] == 0 || [cookie.path hasPrefix:self.baseURL.path]))
        {
            [result addObject:cookie];
        }
    }
    return result;
}

/*! Duplicates the received cookie, but rewrites the 'domain' property to the
 *  base URL of this WebServiceAdapter.
 */
- (NSHTTPCookie *)ownCookieFromCookie:(NSHTTPCookie *)source previousOwner:(WebServiceAdapter *)prevOwner
{
    NSMutableDictionary *properties = [source.properties mutableCopy];
    
    [properties setValue:self.baseURL.host forKey:NSHTTPCookieDomain];
    if ([self.baseURL.scheme isEqualToString:@"https"])
    {
        [properties setValue:@"TRUE" forKey:NSHTTPCookieSecure];
    }
    else
    {
        [properties removeObjectForKey:NSHTTPCookieSecure];
    }
    
    if (prevOwner)
    {
        NSURL *prevBaseURL = prevOwner.baseURL;
        NSString * currentPath = [source valueForKey:NSHTTPCookiePath];
        NSString * prevPath = prevBaseURL.path;
        if ([currentPath hasPrefix:prevPath])
        {
            NSString * newPath = [currentPath stringByReplacingCharactersInRange:NSMakeRange(0, [prevPath length]) withString:self.baseURL.path];
            [properties setValue:newPath forKey:NSHTTPCookiePath];
        }
    }
    return [NSHTTPCookie cookieWithProperties:properties];
}


- (void)addCookie:(NSHTTPCookie *)cookie previousOwner:(WebServiceAdapter *)prevOwner
{
    NSHTTPCookie *ourCookie = [self ownCookieFromCookie:cookie previousOwner:prevOwner];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:ourCookie];
}

- (void)removeCookie:(NSHTTPCookie *)cookie
{
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
}

- (void)clearCookies
{
    for (NSHTTPCookie * cookie in [self cookies])
    {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

- (void)enqueueOperation:(NSOperation *)operation
{
    [self.requestQueue addOperation:operation];
}

- (void)setRequestPaths:(NSDictionary *)requestPaths {
    self.requestPathsDictionary = requestPaths;
}

- (NSString *)requestPathForKey:(NSString *)key {
    return [self.requestPathsDictionary valueForKeyPath:key];
}
- (NSString *)requestErrorCodeForKey:(NSString *)key {
    return [self.requestPathsDictionary valueForKeyPath:key];
}
@end

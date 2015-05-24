//
//  WSAdapter.h
//
//  Created by Csaba Tűz on 2014.02.22..
//  Copyright (c) 2014 All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import <RestKit/RestKit.h>
#import "WebServiceComponent.h"

@class BaseWebServiceResource;

/**
 A `WebServiceAdapter` is a general WebService Client class, which encapsulates the
 HTTP client and Object Mapping framework, and maintains a collection of `BaseWebServiceResource`
 singleton instances.
 
 Using the provided convenience macros, an intuitive WebService client hierarchy can be produced.
 
 ## Subclassing notes
 
 If your app needs to call an HTTP service which is conforming to a specfic behaviour, you can
 subclass `WebServiceAdapter` to encapsulate the inner logic of that service.
 
 The client will be represented by a tree of `WebServiceComponent` instances, with a 
 `WebServiceAdapter` as a root node.
 
 
 The main benefit of this solution is a very intuitive and consistent usage pattern:
 
        [[MyNeatService instance].user getById:userid onSuccess:^(User * result) {
          [self updateWithUser:result];
        } onFailure:^(NSError * error) {
          [self myCoolErrorHandler:error];
        }];
 
 The hierarchy can be as deep as necessary. The nodes do not have to correspond to
 request paths on the service, however in most cases that gives a reasonable structure
 and can be a good starting point.
 
 @see `BaseWebServiceResource` for more details.
 */
@interface WebServiceAdapter : WebServiceComponent

@property (assign, nonatomic) NSTimeInterval defaultRequestTimeout;

/*
 To make the contained `WebServiceComponent`s less redundant, we hold the Base URL
 of all the calls under this `WebServiceAdapter` here.
 
 If a different Base URL is needed (e.g. DEV, STAGE, PROD setups) either two separate
 instances, or different subclasses are recommended.
 */
@property (retain, nonatomic, readonly) NSURL * baseURL;
/*
 The `AFHTTPClient` instance which we use for the HTTP calls.
 
 The property is accessible read-only, so that if it's necessary, users of the
 class can go below the interface provided by these utilities.
 */
@property (readonly, retain) AFHTTPClient *httpClient;
/*
 The `RKObjectManager` will be responsible for mapping the HTTP responses to
 model objects.
 
 @see `RKObjectManager`
 */
@property (readonly, retain) RKObjectManager *objectManager;

/** Inits this `WebServiceAdapter` with `baseURL`. */
- (id)initWithBaseURL:(NSURL *)baseURL;

/**
 If the WS base address tends to change due to internal application logic,
 the Base URL can be changed on-the-fly using this method.
 */
- (void)updateBaseURL:(NSURL *)newBaseUrl;

/**
 This method can be used to set an external source of paths used in this
 `WebServiceAdapter`.
 */
- (void)setRequestPaths:(NSDictionary *)requestPaths;
/**
 By intent, the `WebServiceComponents` contained in this `WebServiceAdapter`
 can use this method to obtain request paths, without being aware of the
 source of these request paths.
 */
- (NSString *)requestPathForKey:(NSString *)key;

- (NSString *)requestErrorCodeForKey:(NSString *)key;
/**
 If the HTTP calls need basic authentication, the credentials can be set
 using this method.
 */
- (void)setHTTPUsername:(NSString *)username andPassword:(NSString *)password;

#pragma mark - Cookie handling

/**
 Returns the cookies in `[NSHTTPCookieStorage sharedHTTPCookieStorage]` for the Base URL of this
 `WebServiceAdaptor`
 */
- (NSArray *)cookies;

/**
 Adds a cookie with the specified parameters, rewriting the host to the Base URL
 of this WebServiceAdapter.
 */
- (void)addCookie:(NSHTTPCookie *)cookie previousOwner:(WebServiceAdapter *)prevOwner;

/**
 Removes the cookie for the Base URL of this WebServiceAdapter.
 If the cookie is available for other hosts, those are not touched.
 */
- (void)removeCookie:(NSHTTPCookie *)cookie;

/*! Removes all the cookies corresponding to the Base URL of this WebServiceAdapter.
 */
- (void)clearCookies;

/**
 Can be used to control the maximum number of simultaneous requests to the given backend.
 */
- (void)setMaxConcurrent:(int)maxConcurrent;

- (void)enqueueOperation:(NSOperation *)operation;

@end

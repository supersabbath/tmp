//
//  WSAdapter_internal.h
//
//  Created by Csaba Tűz on 2014.02.22..
//  Copyright (c) 2014 All rights reserved.
//

#import "WebServiceAdapter.h"

@interface WebServiceAdapter ()

@property (retain, nonatomic) AFHTTPClient *httpClient;

@property (retain, nonatomic) NSURLCredential *defaultCredential;

@property (retain, nonatomic) RKObjectManager *objectManager;

@property (retain, nonatomic) NSMutableArray *cookies;

@end

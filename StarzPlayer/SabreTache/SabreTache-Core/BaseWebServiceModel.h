//
//  FNModel.h
//
//  Created by Csaba Tűz on 2014.02.14..
//  Copyright (c) 2014. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import <RestKit/RestKit.h>
#import <objc/runtime.h>

extern const char *getPropertyType(objc_property_t property);


@protocol ResponseMappable

+ (void)configureObjectMapping:(RKObjectMapping *)mapping;

+ (void)configureDynamicMapping:(RKDynamicMapping *)mapping;

+ (RKMapping *)prototypeMapping;

+ (RKMapping *)mapping;

+ (RKObjectMapping *)inverseMapping;

+ (id)finalMappingResult:(RKMappingResult *)mappingResult;

+ (id)finalMappingResult:(RKMappingResult *)mappingResult forceCollection:(BOOL)forceCollection;

@end

@protocol RequestMappable
@end

@protocol CacheableModel

- (BOOL)shouldCache;

@optional
- (BOOL)shouldCache:(id)requestObjects;

+ (NSString *)uniqueId:(id)requestObjects;

@optional

- (NSTimeInterval)cacheExpiration;
- (NSTimeInterval)cacheExpiration:(id)requestObjects;

@end

@protocol PayloadConfigurer

- (void)configurePayloadForRequest:(NSMutableURLRequest *)request params:(NSDictionary *)params;

@end

typedef NS_ENUM(NSInteger, JSONConvention)
{
    CamelUppercase,
    CamelLowercase,
    LowercaseUnderscore
};

@interface BaseWebServiceModel : NSObject<ResponseMappable, NSCoding, NSCopying>

@property (retain, nonatomic) NSDictionary * responseHeaders;

+ (RKRelationshipMapping *)arrayMappingFromKeyPath:(NSString *)fromKeyPath
                                         toKeyPath:(NSString *)toKeyPath
                                           content:(Class)clazz;

+ (void)configureObjectMapping:(RKObjectMapping *)mapping;

+ (void)configureInverseMapping:(RKObjectMapping *)mapping;

+ (void)configureReflectionMapping:(RKObjectMapping *)mapping convention:(JSONConvention)convention;

+ (void)configureReflectionMapping:(RKObjectMapping *)mapping;

#pragma mark - Multipart Form utils

- (BaseWebServiceModel *)prepareForMultipart:(NSMutableURLRequest *)request params:(NSDictionary *)params;

- (BaseWebServiceModel *)appendFileData:(NSData *)data name:(NSString *)name filename:(NSString *)filename mimeType:(NSString *)mimeType;

- (BaseWebServiceModel *)finalizeMultipart;

@end

@interface EmptyEntity : BaseWebServiceModel
@end

@interface PlaintextEntity : BaseWebServiceModel
@end

@interface RootArrayEntity : BaseWebServiceModel<CacheableModel>

@property (retain, nonatomic) Class clazz;
@property (retain, nonatomic) NSArray * items;

@end

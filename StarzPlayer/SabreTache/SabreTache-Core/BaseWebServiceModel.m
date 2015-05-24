//
//  FNModel.h
//
//  Created by Csaba Tűz on 2014.02.14..
//  Copyright (c) 2014 All rights reserved.
//
#import "BaseWebServiceModel.h"
#import "AbstractClassUtils.h"
#import "WebServiceAdapter.h"
#import "Logging.h"

#import <NSObject-NSCoding/NSObject+NSCoding.h>

static NSMutableDictionary *OBJECT_MAPPINGS;
static dispatch_once_t OBJECT_MAPPINGS_once;

static NSMutableDictionary *INVERSE_OBJECT_MAPPINGS;
static dispatch_once_t INVERSE_OBJECT_MAPPINGS_once;

@interface BaseWebServiceModel()

@property (retain, nonatomic) NSMutableData * multipartData;
@property (retain, nonatomic) NSMutableURLRequest * multipartRequest;

@end

@implementation BaseWebServiceModel

- (NSDictionary *)propertiesForClass:(Class)klass
{
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(klass, &outCount);
    for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        
        NSString *pname = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        NSString *pattrs = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
        
        NSArray * attrs = [pattrs componentsSeparatedByString:@","];
        if ([attrs containsObject:@"R"])
        {
            continue;
        }
        pattrs = [attrs objectAtIndex:0];
        pattrs = [pattrs substringFromIndex:1];
        
        [results setObject:pattrs forKey:pname];
    }
    free(properties);
    
    if ([klass superclass] != [NSObject class]) {
        [results addEntriesFromDictionary:[self propertiesForClass:[klass superclass]]];
    }
    
    return results;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [self autoEncodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        [self autoDecode:aDecoder];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return nil;
}

+ (NSMutableDictionary *)ObjectMappings {
    dispatch_once(&OBJECT_MAPPINGS_once, ^{
        OBJECT_MAPPINGS = [NSMutableDictionary dictionary];
    });
    return OBJECT_MAPPINGS;
}

+ (NSMutableDictionary *)InverseObjectMappings {
    dispatch_once(&INVERSE_OBJECT_MAPPINGS_once, ^{
        INVERSE_OBJECT_MAPPINGS = [NSMutableDictionary dictionary];
    });
    return INVERSE_OBJECT_MAPPINGS;
}

+ (RKMapping *)mapping {
    RKMapping *mapping;
    mapping = [[self ObjectMappings] objectForKey:self];
    if (mapping == nil) {
        @synchronized([self ObjectMappings]) {
            mapping = [self prototypeMapping];
            [[self ObjectMappings] setObject:mapping forKey:(id<NSCopying>)self];
            
            [self configureMapping:mapping];
        }
    }
    return mapping;
}

+ (RKObjectMapping *)inverseMapping {
    if (![self conformsToProtocol:@protocol(RequestMappable)]) return nil;
    
    if ([[self mapping] isKindOfClass:[RKObjectMapping class]])
    {
        RKObjectMapping *mapping;
        mapping = [[self InverseObjectMappings] objectForKey:self];
        if (mapping == nil) {
            @synchronized(self) {
                mapping = [(RKObjectMapping *)[self mapping] inverseMapping];
                
                [[self InverseObjectMappings] setObject:mapping forKey:(id<NSCopying>)self];
                
                [self configureInverseMapping:mapping];
            }
        }
        return mapping;
    }
    return nil;
}

+ (RKMapping *)prototypeMapping
{
    return [RKObjectMapping mappingForClass:self];
}

+ (void)configureMapping:(RKMapping *)mapping {
    if ([mapping isKindOfClass:[RKObjectMapping class]])
    {
        [self configureObjectMapping:(RKObjectMapping *)mapping];
    }
    else if ([mapping isKindOfClass:[RKDynamicMapping class]])
    {
        [self configureDynamicMapping:(RKDynamicMapping *)mapping];
    }
}

+ (void)configureObjectMapping:(RKObjectMapping *)mapping
{
    [self configureReflectionMapping:mapping];
}

+ (void)configureInverseMapping:(RKObjectMapping *)mapping
{
    
}

+ (void)configureDynamicMapping:(RKDynamicMapping *)mapping
{
    ABSTRACT_METHOD
}

+ (id)finalMappingResult:(RKMappingResult *)mappingResult forceCollection:(BOOL)forceCollection
{
    if ([mappingResult.array count] > 1 || forceCollection)
    {
        RootArrayEntity * result = [RootArrayEntity new];
        result.items = mappingResult.array;
        return result;
    }
    return [mappingResult firstObject];
}

+ (id)finalMappingResult:(RKMappingResult *)mappingResult
{
    return [self finalMappingResult:mappingResult forceCollection:NO];
}

+ (RKRelationshipMapping *)arrayMappingFromKeyPath:(NSString *)fromKeyPath toKeyPath:(NSString *)toKeyPath content:(Class)clazz
{
    NSAssert([clazz isSubclassOfClass:[BaseWebServiceModel class]], @"Class must inherit BaseWebServiceModel");
    return [RKRelationshipMapping relationshipMappingFromKeyPath:fromKeyPath
                                                       toKeyPath:toKeyPath
                                                     withMapping:[clazz mapping]];
}

+ (NSString *)camelToUnderscore:(NSString *)src
{
    NSMutableString * result = [NSMutableString string];
    for (int i = 0; i < [src length]; ++i)
    {
        char c = [src characterAtIndex:i];
        [result appendFormat:(isupper(c) ? @"_%c" : @"%c"), tolower(c)];
    }
    return result;
}

+ (NSString *)uppercaseFirstLetter:(NSString *)src
{
    NSMutableString * result = [NSMutableString string];
    for (int i = 0; i < [src length]; ++i)
    {
        char c = [src characterAtIndex:i];
        [result appendFormat:@"%c", ((i == 0 && islower(c)) ? toupper(c) : c)];
    }
    return result;
}

const char *getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    //printf("attributes=%s\n", attributes);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // it's a C primitive type:
            /*
             if you want a list of what will be returned for these primitives, search online for
             "objective-c" "Property Attribute Description Examples"
             apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
             */
            switch (attribute[1])
            {
                case 'c': return "char";
                case 'd': return "double";
                case 'i': return "enum";
                case 'l': return "long";
                case 's': return "short";
            }
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            NSString *name = [[NSString alloc] initWithBytes:attribute + 3 length:strlen(attribute) - 4 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
    }
    return "";
}

+ (void)configureReflectionMapping:(RKObjectMapping *)mapping
{
    [self configureReflectionMapping:mapping convention:LowercaseUnderscore];
}

+ (void)configureReflectionMapping:(RKObjectMapping *)mapping convention:(JSONConvention)convention
{
    unsigned int outCount, i;
    Class current = self;
    while (![current isEqual:[BaseWebServiceModel class]])
    {
        objc_property_t * properties = class_copyPropertyList(current, &outCount);
        for (i = 0; i < outCount; ++i)
        {
            objc_property_t property = properties[i];
            const char * propName = property_getName(property);
            if (propName)
            {
                NSString * attributes = [NSString stringWithCString:property_getAttributes(property) encoding:[NSString defaultCStringEncoding]];
                if ([[attributes componentsSeparatedByString:@","] containsObject:@"R"])
                {
                    DLog(@"Skipping property because it's read-only");
                    continue;
                }
                const char * propType = getPropertyType(property);
                NSString *propertyName = [NSString stringWithCString:propName
                                                            encoding:[NSString defaultCStringEncoding]];
                NSString *propertyType = [NSString stringWithCString:propType
                                                            encoding:[NSString defaultCStringEncoding]];
                Class cls = NSClassFromString(propertyType);
                if ([[[mapping propertyMappingsByDestinationKeyPath] allKeys] containsObject:propertyName])
                {
                    DLog(@"Skipping %@, as mapping is already added", propertyName);
                }
                else
                {
                    if ([cls isSubclassOfClass:[BaseWebServiceModel class]])
                    {
                        NSString * sourceName = nil;
                        switch (convention)
                        {
                            case LowercaseUnderscore:
                                sourceName = [self camelToUnderscore:propertyName];
                                break;
                            case CamelLowercase:
                                sourceName = propertyName;
                                break;
                            case CamelUppercase:
                                sourceName = [self uppercaseFirstLetter:propertyName];
                                break;
                        }
                        // This is a mapped object, add relationship mapping
                        [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:sourceName
                                                                                                toKeyPath:propertyName
                                                                                              withMapping:[cls mapping]]];
                    }
                    else if ([@[@"NSNumber", @"NSString", @"NSURL", @"NSDate", @"int", @"NSInteger",@"char", @"double", @"enum", @"long", @"short"] containsObject:propertyType])
                    {
                        switch (convention)
                        {
                            case LowercaseUnderscore:
                                [mapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:[self camelToUnderscore:propertyName]
                                                                                                  toKeyPath:propertyName]];
                                break;
                            case CamelLowercase:
                                [mapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:propertyName
                                                                                                  toKeyPath:propertyName]];
                                break;
                            case CamelUppercase:
                                [mapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:[self uppercaseFirstLetter:propertyName]
                                                                                                  toKeyPath:propertyName]];
                                break;
                        }
                        
                    }
                    else
                    {
                        WLog(@"No reflective mapping is possible for property: %@", propertyName);
                    }
                }
            }
        }
        current = [current superclass];
        if (properties)
            free(properties);
    }
}

#pragma mark - Multipart utils


static NSString * const boundary = @"------VohpleBoundary4QuqLuM1cE5lMwCy";

- (BaseWebServiceModel *)prepareForMultipart:(NSMutableURLRequest *)request params:(NSDictionary *)params
{
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    // add params (all params are strings)
    for (NSString *param in params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    self.multipartData = body;
    self.multipartRequest = request;
    
    return self;
}

- (BaseWebServiceModel *)finalizeMultipart
{
    [self.multipartData appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [self.multipartRequest setHTTPBody:self.multipartData];
    self.multipartRequest = nil;
    self.multipartData = nil;
    
    return self;
}

- (BaseWebServiceModel *)appendFileData:(NSData *)data name:(NSString *)name filename:(NSString *)filename mimeType:(NSString *)mimeType
{
    NSMutableData * body = self.multipartData;
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name, filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimeType] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:data];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return self;
}

@end

@implementation EmptyEntity

+ (void)configureObjectMapping:(RKObjectMapping *)mapping
{
    [[self ObjectMappings] setObject:[RKObjectMapping mappingForClass:[NSNull class]]
                              forKey:(id<NSCopying>)self];
}

@end

@implementation PlaintextEntity

+ (void)configureObjectMapping:(RKObjectMapping *)mapping
{
    [[self ObjectMappings] setObject:[RKObjectMapping mappingForClass:[NSString class]]
                              forKey:(id<NSCopying>)self];
}

@end

@implementation RootArrayEntity

- (BOOL)shouldCache
{
    BOOL shouldCache = YES;
    for (BaseWebServiceModel * m in self.items)
    {
        if ([m conformsToProtocol:@protocol(CacheableModel)])
        {
            if ([m respondsToSelector:@selector(shouldCache)])
            {
                shouldCache &= [(id<CacheableModel>)m shouldCache];
            }
        }
        else
        {
            return NO;
        }
    }
    return YES;
}

- (BOOL)shouldCache:(id)requestObjects
{
    BOOL shouldCache = YES;
    for (BaseWebServiceModel * m in self.items)
    {
        if ([m conformsToProtocol:@protocol(CacheableModel)])
        {
            if ([m respondsToSelector:@selector(shouldCache:)])
            {
                shouldCache &= [(id<CacheableModel>)m shouldCache:requestObjects];
            }
        }
        else
        {
            return NO;
        }
    }
    return YES;
}

@end

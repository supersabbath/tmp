//
//  BaseWebServiceComponent.h
//
//  Created by Csaba Tűz on 2014.03.05..
//  Copyright (c) 2014 All rights reserved.
//

#import <Foundation/Foundation.h>

@class BaseWebServiceResource;

#define RESOURCE(name, type)\
- (type *)name\
{\
  return (type *)[self resource:[type class]]; \
}

@interface WebServiceComponent : NSObject

- (BaseWebServiceResource *)resource:(Class)clazz;
@end

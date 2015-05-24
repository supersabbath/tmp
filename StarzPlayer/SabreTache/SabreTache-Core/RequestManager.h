
#import <Foundation/Foundation.h>

@class RequestHandle;

/**
 `RequestManager` is a utility class to allow grouping, and batch cancellation of
 requests issued by and arbitrary `BaseWebServiceResource` subclass.
 
 @see `RequestHandle`
 */
@interface RequestManager : NSObject

/** 
 Only one `RequestManager` is needed, so we implement the singleton pattern 
 */
+ (RequestManager *)instance;

/**
 @param request The `RequestHandle` instance which represents the request.
 @param groupId Arbitrary group key to assign the request to.
 */
- (void)addRequest:(RequestHandle *)request toGroup:(id<NSCopying>)groupId;

/**
 @param request The `RequestHandle` instance which represents the request.
 @param groupId Arbitrary group key to assign the request to.
 */
- (void)removeRequest:(RequestHandle *)request fromGroup:(id<NSCopying>)groupId;

/**
 Cancels all requests in the group keyed by `groupId`
 @param groupId Arbitrary group key to assign the request to.
 */
- (void)cancelAllRequestsInGroup:(id<NSCopying>)groupId;

@end

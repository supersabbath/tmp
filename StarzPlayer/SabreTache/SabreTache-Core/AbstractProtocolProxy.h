#import <Foundation/Foundation.h>

@interface AbstractProtocolProxy : NSObject

@property (nonatomic, assign) id core;

- (id)initWithCore:(id)core;

@end

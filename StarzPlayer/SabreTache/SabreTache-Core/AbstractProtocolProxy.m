#import "AbstractProtocolProxy.h"

@implementation AbstractProtocolProxy

/*+ (NSArray *)selectorsToForward
{
    uint32_t outCount;
    Protocol **protos = class_copyProtocolList(self, &outCount);
    
    for (int i = 0; i < outCount; ++i)
    {
        Protocol *proto = protos[i];
        uint32_t methodCount;
        struct objc_method_description *methods = protocol_copyMethodDescriptionList(proto, YES, YES, &methodCount);
        for (int j = 0; j < methodCount; ++j)
        {
            SEL selector = methods[i].name;
        }
    }
    
    free(protos);
    return nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    NSMethodSignature *sig = [super methodSignatureForSelector:sel];
    if(!sig)
    {
        for(id obj in self)
            if((sig = [obj methodSignatureForSelector:sel]))
                break;
    }
    return sig;
}

- (void)forwardInvocation:(NSInvocation *)inv
{
    for(id obj in self)
        [inv invokeWithTarget:obj];
}*/

- (id)initWithCore:(id)core
{
    self = [super init];
    if (self)
    {
        self.core = core;
    }
    return self;
}

- (void)dealloc
{
    self.core = nil;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL iRespond = [super respondsToSelector:aSelector];
    BOOL coreResponds = [_core respondsToSelector:aSelector];
    return iRespond || coreResponds;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    NSMethodSignature *sig = [super methodSignatureForSelector:sel];
    if(!sig)
    {
        sig = [_core methodSignatureForSelector:sel];
    }
    return sig;
}

- (void)forwardInvocation:(NSInvocation *)inv
{
    if ([super respondsToSelector:inv.selector])
    {
        [inv invokeWithTarget:nil];
    }
    else if (_core != nil && [_core respondsToSelector:inv.selector])
    {
        [inv invokeWithTarget:_core];
    }
    else
    {
        [super forwardInvocation:inv];
    }
}

@end

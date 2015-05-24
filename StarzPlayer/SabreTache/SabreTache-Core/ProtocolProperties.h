#import <objc/runtime.h>

#ifndef ProtocolProperties_h
#define ProtocolProperties_h

/**
 Helper macros to define properties in Objective C categories.
 
 By doing this, we aim to create a kind of mixins, where a given
 set of functionality can be ,,mixed in'' to a class, e.g. `UIViewController`
 without the need of subclassing.
 
 Another benefit of this approach, that it allows multiple feature sets to be
 mixed in independently, which would actually be impossible, due to lack of
 multiple inheritance.
 */

#define CATEGORY_PROPERTY(type, name) \
@property (retain, getter=get##name, setter=set##name:) type name;

#define CATEGORY_PROPERTY_SIMPLE(type, name) \
@property (assign, getter=get##name, setter=set##name:) type name;

#define SYNTHESIZE_CATEGORY_PROPERTY_GENERIC(type, name, initial_value, assoc_type) \
char const * const propKey_##name = "ivar_" #name;\
dispatch_once_t propOnce_##name;\
\
- (type)get##name \
{ \
    dispatch_once(&propOnce_##name, ^{\
        objc_setAssociatedObject(self, propKey_##name, initial_value, assoc_type);\
    });\
    return objc_getAssociatedObject(self, propKey_##name);\
} \
\
- (void)set##name:(type)newVal \
{ \
    dispatch_once(&propOnce_##name, ^{\
        objc_setAssociatedObject(self, propKey_##name, initial_value, assoc_type);\
    });\
    objc_setAssociatedObject(self, propKey_##name, newVal, assoc_type);\
} \

#define SYNTHESIZE_CATEGORY_PROPERTY(name, initial_value) SYNTHESIZE_CATEGORY_PROPERTY_GENERIC(id, name, initial_value, OBJC_ASSOCIATION_RETAIN_NONATOMIC)

#endif

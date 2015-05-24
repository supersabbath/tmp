#pragma mark - Macro weaving tools

#define STRINGIFY2( x) #x
#define STRINGIFY(x) STRINGIFY2(x)
#define PASTE2( a, b) a##b
#define PASTE( a, b) PASTE2( a, b)


#pragma mark - iPhone/iPad tell-apart tools

#ifdef UI_USER_INTERFACE_IDIOM
#define IS_IPAD \
(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#else
#define IS_IPAD NO
#endif

#ifdef UI_USER_INTERFACE_IDIOM
#define DO_FOR_IPAD_IPHONE(a, b)                              \
(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ?    \
(a) : (b)

#define BLOCK_FOR_IPAD_IPHONE(a, b) \
(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? a() : b()
#else
#define DO_FOR_IPAD_IPHONE(a, b)    a

#define BLOCK_FOR_IPAD_IPHONE(a, b) a()
#endif

// iOS Software version

#define iOSVersion  [[[UIDevice currentDevice] systemVersion] floatValue]

#pragma mark - UIColor tools

#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define RGB(r, g, b) RGBA(r, g, b, 1)
#define BWA(w, a) [UIColor colorWithWhite:w/255.0 alpha:a]
#define BW(w) BWA(w, 1)

#pragma mark - Singleton VC tools

#define SYNTHESIZE_SINGLETON_VC(type, nibName) \
static type * vc_instance_##type; \
static dispatch_once_t vc_once_##type; \
  + (type *)instance \
{ \
  dispatch_once(&vc_once_##type, ^{ \
    vc_instance_##type = [[type alloc] initWithNibName:nibName bundle:nil]; \
  }); \
  return vc_instance_##type; \
} \
\
  + (void)resetVCInstance \
{ \
  vc_once_##type = 0; \
  vc_instance_##type = nil; \
}

#define SYNTHESIZE_SINGLETON_VC_NONIB(type) \
static type * vc_instance_##type; \
static dispatch_once_t vc_once_##type; \
+ (type *)instance \
{ \
dispatch_once(&vc_once_##type, ^{ \
vc_instance_##type = [[type alloc] init]; \
}); \
return vc_instance_##type; \
} \
\
+ (void)resetVCInstance \
{ \
vc_once_##type = 0; \
vc_instance_##type = nil; \
}

#pragma mark - Objective-C smarties

#define CONSTSTR(key, v) NSString * const key = v;

#define FMT(f, ...) [NSString stringWithFormat:f, ##__VA_ARGS__];

#define VFK(c, k) [c valueForKey:k]
#define VFKP(c, k) [c valueForKeyPath:k]
#define OFK(P, K) [P objectForKey : K]

#define NUMBOOL(x) [NSNumber numberWithBool:x]

#define NUMLONG(x) [NSNumber numberWithLong:x]

#define NUMLONGLONG(x) [NSNumber numberWithLongLong:x]

#define NUMINT(x) [NSNumber numberWithInt:x]

#define NUMUINT(x) [NSNumber numberWithUnsignedInteger:x]

#define NUMDOUBLE(x) [NSNumber numberWithDouble:x]

#define NUMFLOAT(x) [NSNumber numberWithFloat:x]

#define STRINT(x) [NSString stringWithFormat:@"%d", x]
#define STRDOUBLE(x) [NSString stringWithFormat:@"%f", x]
#define STRFLOAT(x) [NSString stringWithFormat:@"%f", x]

#pragma mark - Language direction

#define LEFTTORIGHTLANG \
    (UIUserInterfaceLayoutDirectionLeftToRight == [UIApplication sharedApplication].userInterfaceLayoutDirection)

#define IS_IPHONE4SCREEN ( [ [ UIScreen mainScreen ] bounds ].size.height == 480 )

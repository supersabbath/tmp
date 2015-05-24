//
//  LocalizationSystem.m
//  Filmnet
//
//  Created by Csaba Tűz on 2014.04.02..
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//
#import "LanguageManager.h"
#import "Logging.h"

@interface LanguageManager()

@property (nonatomic, retain) NSMutableArray * appleLanguagesCache;

@end

@implementation LanguageManager

//Singleton instance
static LanguageManager *_sharedLocalSystem = nil;

//Current application bungle to get the languages.
static NSBundle *bundle = nil;

+ (LanguageManager *)sharedLocalSystem
{
    static dispatch_once_t localSystem_once;
    dispatch_once(&localSystem_once, ^{
        _sharedLocalSystem = [[self alloc] init];
    });
    
	return _sharedLocalSystem;
}

+(id)alloc
{
	@synchronized([LanguageManager class])
	{
		NSAssert(_sharedLocalSystem == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedLocalSystem = [super alloc];
		return _sharedLocalSystem;
	}
	// to avoid compiler warning
	return _sharedLocalSystem;
}


- (id)init
{
    if ((self = [super init])) 
    {
		//empty.
		bundle = [NSBundle mainBundle];
        networkTranslations = [[NSMutableDictionary alloc] init];
	}
    return self;
}


- (void)dealloc {
    networkTranslations = nil;
   }

// Gets the current localized string as in NSLocalizedString.
//
// example calls:
// AMLocalizedString(@"Text to localize",@"Alternative text, in case hte other is not find");
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment {
    NSString* result = nil;
    NSString* lang = [self getLanguage];

    if ([key isEqual:[NSNull null]] ) {
        return @"";
    }
    
    if ([networkTranslations objectForKey:lang] ) {
        NSString* stringForKey = [[networkTranslations valueForKey:lang] valueForKey:key];

        if (stringForKey == nil || [stringForKey isEqual:[NSNull null]]) {
          return [bundle localizedStringForKey:key value:comment table:nil];   
        }

        result = stringForKey;
    } else {
	  result = [bundle localizedStringForKey:key value:comment table:nil];
    }

    if ([key isEqual:result]) {
        WLog(@"WARN: The localized string for key '%@' is probably missing", key);
    }

    return result;
}

- (NSString *)locStringForKey:(NSString *)key {
	return [self localizedStringForKey: key value: nil];
}


// Sets the desired language of the ones you have.
// example calls:
// LocalizationSetLanguage(@"Italian");
// LocalizationSetLanguage(@"German");
// LocalizationSetLanguage(@"Spanish");
// 
// If this function is not called it will use the default OS language.
// If the language does not exists y returns the default OS language.
- (void) setLanguage:(NSString*) l {
    DLog(@"preferredLang: %@", l);

    if (!l) {
        WLog(@"Language is nil. Not setting");
        return;
    }

	NSString *path = [[NSBundle mainBundle] pathForResource:l ofType:@"lproj"];

	if (path == nil) {
		//in case the language does not exists
		[self resetLocalization];
	} else {
		bundle = [NSBundle bundleWithPath:path] ;
    }

    self.appleLanguagesCache = [[NSArray arrayWithObjects:l, nil] mutableCopy];
    [[NSUserDefaults standardUserDefaults] setObject:self.appleLanguagesCache
                                              forKey: @"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSMutableArray *)appleLanguages
{
    if (self.appleLanguagesCache == nil)
    {
        self.appleLanguagesCache = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    }
    return self.appleLanguagesCache;
}

// Just gets the current setted up language.
// returns "es","fr",...
//
// example call:
// NSString * currentL = LocalizationGetLanguage;
- (NSString*) getLanguage {
    NSString *preferredLang = [self appleLanguages][0];

	return preferredLang;
}

- (NSArray*) getLanguages {
    NSArray* languages = [self appleLanguages];

	return languages;
}

// Resets the localization system, so it uses the OS default language.
//
// example call:
// LocalizationReset;
- (void) resetLocalization {
	bundle = [NSBundle mainBundle];
}

- (void)updateTextsForLang:(NSString*)lang withTranslations:(NSDictionary*)translations {
    [networkTranslations setValue:translations forKey:lang];
}

@end

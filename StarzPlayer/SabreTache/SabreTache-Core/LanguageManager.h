//
//  LocalizationSystem.h
//  Filmnet
//
//  Created by Csaba Tűz on 2014.04.02..
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ACSetLanguage(language) \
    [[LanguageManager sharedLocalSystem] setLanguage : (language)]

#define ACGetLanguage \
    [[LanguageManager sharedLocalSystem] getLanguage]

#define ACLocalizationReset \
    [[LanguageManager sharedLocalSystem] resetLocalization]

#define ACUpdateLocalizedStrings(language, texts) \
    [[LanguageManager sharedLocalSystem] updateTextsForLang:(language) withTranslations:(texts)];

#define ACLocalizedString(s) [[LanguageManager sharedLocalSystem] locStringForKey:s]

/**
 `LanguageManager` is a utility class, which provides app localization related features, like
 changing app language, or providing localizations from a different source than the
 Localizable.strings files in the bundle.
 
 ## Example usage
 
 Scenario 1:
      NSData * remoteLocalizationData;
      ...
      NSDictionary * englishTexts = [NSJSONSerialization JSONObjectFromData:remoteLocalizationData error:nil];
      [[LanguageManager sharedLocalSystem] updateTextsForLang:@"en" withTranslations:englishTexts];
      ...
      <later in the app>
      nameLabel.text = [[LanguageManager sharedLocalSystem] localizedStringForKey:@"txtNameLabel"];
 
 This is really handy, however a bit verbose. In order to help with the widespread use of this tool,
 there are several macros available to decrease the amount of boilerplate.
 
 Here's how a typical usage would be done.
 
 Scenario 1b:
      NSData * remoteLocalizationData;
      ...
      NSDictionary * englishTexts = [NSJSONSerialization JSONObjectFromData:remoteLocalizationData error:nil];
      ACUpdateLocalizedStrings(@"en", englishTexts);
      ...
      <later in the app>
      nameLabel.text = ACLocalizedString(@"txtNameLabel");
 
 This way the usage has negligible overhead over typical NSLocalizedString usage.
 
 ## Interaction with standard localization methods
 
 By default, `LanguageManager` is using the standard Localizable.strings data in the resource
 bundle. If you use only local texts, this tool might still be useful to change the app language on
 the fly.
 
 However if you use remote translations, then if a key is defined both remotely and locally, the
 remote value will be used. If the key is available only locally, the local translations will still
 be used.
 
 In case, when the key is not available neither in remote, nor in local translation, the key is
 returned, and a warning is emitted.
 
 */
@interface LanguageManager : NSObject {
    NSString *language;
    NSMutableDictionary *networkTranslations;
}

+ (LanguageManager *)sharedLocalSystem;

// gets the string localized
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment;
- (NSString *)locStringForKey:(NSString *)key;

- (void)updateTextsForLang:(NSString *)lang withTranslations:(NSDictionary *)translations;

// sets the language
- (void)setLanguage:(NSString *)language;

// gets the current language
- (NSString *)getLanguage;

// gets supported language
- (NSArray *)getLanguages;

// resets this system.
- (void)resetLocalization;

@end

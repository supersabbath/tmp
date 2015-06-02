//
//  SPPlayerUIStyle.m
//  StarzPlayer
//
//  Created by Fernando Canon on 27/05/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import "SPPlayerUIStyle.h"
// title lable
NSString *const kFontMainTitleLabel = @"kFontMainTitleLabel";
NSString *const kTintMainTitleLabel =  @"kTintMainTitleLabel" ;

//  !!  TIME LABELS
NSString *const kFontTimeLabel = @"kFontTimeLabel";
NSString *const kTintColorTimeLabel = @"kTintColorTimeLabel";
// subtitle label
NSString *const kFontSubtimeLabel = @"kFontSubtimeLabel" ;
NSString *const kTintColorSubtimeLabel = @"kTintColorSubtimeLabel";
// Lang Button
NSString *const kFontLangButton = @"kFontLangButton";
NSString *const kTextColorLangButton = @"kTextColorLangButton";
NSString *const kTextColorLangButtonHighligthed = @"kTextColorLangButtonHighligthed";
//tables
NSString *const kBackgroundColorMetadataTables = @"kBackgroundColorMetadataTables";
NSString *const kHeaderTableViewTextColor = @"kHeaderTableViewTextColor";
NSString *const kFontHeaderTableView = @"kFontHeaderTableView";

// Control
NSString *const kBackgroundColorControlView = @"kBackgroundColorControlView";
// Slider images names
NSString *const kSliderMinImageName = @"kSliderMinImageName";
NSString *const kSliderMaxImageName = @"kSliderMaxImageName";


@interface SPPlayerUIStyle ()
{
    NSMutableDictionary *propertiesDictionary;
}

@end

@implementation SPPlayerUIStyle

- (instancetype) init
{
    self = [super init];
    if (self) {
        [self initializeDefauldValues];
    }
    return self;
}

#pragma mark -
#pragma mark Setter
-(void) addProperty:(id) uiProperty forKey:(NSString*) validKey
{
    [propertiesDictionary setObject:uiProperty forKey:validKey];
}


-(void) setActivateDebugMode:(BOOL)activateDebugMode
{
    _activateDebugMode = activateDebugMode;
    NSMutableDictionary *newProperties = [NSMutableDictionary dictionaryWithCapacity:propertiesDictionary.count];
    [propertiesDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if ([obj isKindOfClass:[UIColor class]]) {
            [newProperties setObject:[UIColor colorWithWhite:0.2 alpha:0.8] forKey:key];
        }else{
            [newProperties setObject:obj forKey:key];
        }
    }];
}
-(void) initializeDefauldValues
{
    propertiesDictionary = [@{} mutableCopy];
    
    [propertiesDictionary setObject:[UIColor colorWithWhite:0.0 alpha:0.2] forKey:kBackgroundColorControlView];
    [propertiesDictionary setObject:[UIColor grayColor] forKey:kBackgroundColorMetadataTables];
    [propertiesDictionary setObject:[UIFont systemFontOfSize:12] forKey:kFontLangButton];
    [propertiesDictionary setObject:[UIColor whiteColor] forKey:kTextColorLangButton];
    [propertiesDictionary setObject:[UIColor whiteColor] forKey:kTintColorSubtimeLabel];
    
    [propertiesDictionary setObject:[UIColor whiteColor] forKey:kTintColorSubtimeLabel];
    [propertiesDictionary setObject:[UIFont systemFontOfSize:12] forKey:kFontTimeLabel];
    [propertiesDictionary setObject:[UIFont systemFontOfSize:12] forKey:kFontSubtimeLabel];
    [propertiesDictionary setObject:[UIFont systemFontOfSize:10] forKey:kFontHeaderTableView];
    [propertiesDictionary setObject:[UIColor whiteColor] forKey:kHeaderTableViewTextColor];
    
    [propertiesDictionary setObject:[UIColor whiteColor] forKey:kTintMainTitleLabel];
    [propertiesDictionary setObject:[UIFont systemFontOfSize:15] forKey:kFontMainTitleLabel];
}

#pragma mark -
#pragma mark Getter
-(UIColor*) tintColorForMainTitleLabel
{
    return propertiesDictionary[kTintMainTitleLabel];
}

-(UIFont*) fontForMainTitleLabel
{
  return propertiesDictionary[kFontMainTitleLabel];
    
}

-(UIFont*) fontForTimeLabel
{
    return propertiesDictionary[kFontTimeLabel];
    
}

-(UIColor*) tintColorForTimeLabel
{
    return propertiesDictionary[kTintColorTimeLabel];
}

-(UIColor*) tintColorForSubtitleLabel
{
    return propertiesDictionary[kTintColorSubtimeLabel];
}


-(UIFont*) fontForSutimeLabel
{
    return propertiesDictionary[kFontSubtimeLabel];
}

-(UIColor*) titleColorForLangButtonStateNormal
{
    return propertiesDictionary[kTextColorLangButton];
}

-(UIColor*) titleColorForLangButtonStateHighlighted
{
    return propertiesDictionary[kTextColorLangButtonHighligthed];
}

-(UIFont*) fontForLangButton
{
    return propertiesDictionary[kFontLangButton];
}

-(UIColor*) backgroundColorForMetadataTablesViews
{
    return propertiesDictionary[kBackgroundColorMetadataTables];
}
/*
 These methods will call UIImage imageWithName: ...]. Make sure the image is included in the bundle
 sliderMaximunImage
 sliderMinimunImage
 */
-(UIImage*) sliderMinimunImage
{
    NSString *imageName = propertiesDictionary[kSliderMinImageName];
    return [UIImage imageNamed:imageName];
}

-(UIImage*) sliderMaximunImage
{
    NSString *imageName  = propertiesDictionary[kSliderMaxImageName];
    return [UIImage imageNamed:imageName];
}

-(UIColor*) backgroundColorForControlView
{
    return propertiesDictionary[kBackgroundColorControlView];
    
}

-(UIFont*) fontForMetadataTableHeader
{
    return propertiesDictionary[kFontHeaderTableView];
}

-(UIColor*) tableHeaderTextColor
{
    return propertiesDictionary[kHeaderTableViewTextColor];
}
@end
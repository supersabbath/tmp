//
//  SPPlayerUIStyle.h
//  StarzPlayer
//
//  Created by Fernando Canon on 27/05/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import <Foundation/Foundation.h>
// Main Title Label
FOUNDATION_EXPORT  NSString *const kFontMainTitleLabel;
FOUNDATION_EXPORT  NSString *const kTintMainTitleLabel;

// time lable
FOUNDATION_EXPORT  NSString *const kFontTimeLabel;
FOUNDATION_EXPORT  NSString *const kTintColorTimeLabel;
// subtitle label
FOUNDATION_EXPORT  NSString *const kFontSubtimeLabel;
FOUNDATION_EXPORT  NSString *const kTintColorSubtimeLabel;
// Lang Button
FOUNDATION_EXPORT  NSString *const kFontLangButton;
FOUNDATION_EXPORT  NSString *const kTextColorLangButton;
FOUNDATION_EXPORT  NSString *const kTextColorLangButtonHighligthed;
// Tableview
FOUNDATION_EXPORT  NSString *const kBackgroundColorMetadataTables;
FOUNDATION_EXPORT  NSString *const kHeaderTableViewTextColor;
FOUNDATION_EXPORT  NSString *const kFontHeaderTableView;

// Control
FOUNDATION_EXPORT  NSString *const kBackgroundColorControlView;
// Slider images names
FOUNDATION_EXPORT  NSString *const kSliderMinImageName;
FOUNDATION_EXPORT  NSString *const kSliderMaxImageName;




@interface SPPlayerUIStyle : NSObject

@property (nonatomic , readwrite) BOOL activateDebugMode;

/*Setter method*/
-(void) addProperty:(id) uiProperty forKey:(NSString*) validKey;

/*Getter methodos*/
-(UIFont*) fontForTimeLabel;            // kFontTimeLabel
-(UIColor*) tintColorForTimeLabel;     // kTintColorTimeLabel

-(UIColor*) tintColorForMainTitleLabel;
-(UIFont*) fontForMainTitleLabel;

-(UIColor*) tintColorForSubtitleLabel;  // kFontSubtimeLabel
-(UIFont*) fontForSutimeLabel;          // kFontSubtimeLabel

-(UIColor*) titleColorForLangButtonStateNormal;    // kTextColorLangButton
-(UIColor*) titleColorForLangButtonStateHighlighted; // kTextColorLangButtonHighligthed
-(UIFont*) fontForLangButton;           // kFontLangButton


/*
 These methods will call UIImage imageWithName: ...]. Make sure the image is included in the bundle
    sliderMaximunImage
    sliderMinimunImage
 */
-(UIImage*) sliderMinimunImage; // kSliderMinImageName
-(UIImage*) sliderMaximunImage; // kSliderMaxImageName

-(UIColor*) backgroundColorForControlView; // kBackgroundColorControlView

/*
Tables Header color and Font
*/

-(UIFont*) fontForMetadataTableHeader;
-(UIColor*) tableHeaderTextColor;
-(UIColor*) backgroundColorForMetadataTablesViews; // kBackgroundColorMetadataTables

@end

//
//  PSLangSelectorCell.m
//  Starz
//
//  Created by Tüz Csaba on 25/11/14.
//  Copyright (c) 2014 accedo. All rights reserved.
//

#import "PSLangSelectorCell.h"

//#import "PSFonts.h"
//#import "UIColor+PSColors.h"

//#import <SabreTache-Core/LanguageManager.h>

@interface PSLangSelectorCell()

@property (assign, nonatomic) BOOL offMode;
@property (assign, nonatomic) BOOL offSelected;

@property (weak, nonatomic) IBOutlet UILabel * titleLabel;

@property (weak, nonatomic) IBOutlet UIImageView * checkImage;

@property (retain, nonatomic) PTMediaSelectionOption * option;

@end

@implementation PSLangSelectorCell

- (void)awakeFromNib {
    
   // self.titleLabel.font = [FontUtil fontWithKey:IS_IPAD ? PSFontPNRS : PSFontPNRXS];
    
    [self setHighlighted:false];
  //  self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_32_c3.png"]];

    [self setHighlighted:false];
    
    self.backgroundColor = [UIColor blackColor];
    self.contentView.backgroundColor = [UIColor blackColor];
    
    self.selectedBackgroundView = [UIView new];
    self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
}

- (void)setupForOffSelected:(BOOL)selected
{
    self.option = nil;
    
   // self.titleLabel.text = [ACLocalizedString(@"key_langSelector_none") uppercaseString];
    self.titleLabel.text = NSLocalizedString(@"key_langSelector_none",nil);
    [self setSelected:selected animated:NO];
    self.checkImage.hidden = !selected;
    
    self.offMode = YES;
    self.offSelected = selected;
    if (selected)
    {
        self.titleLabel.textColor =[UIColor colorWithRed:0xD8/255.0 green: 0xCD/255.0 blue:0xB0/255.0 alpha:1]; // silly code copied from accedo [Color PSColorC4]
    }
    else
    {
        self.titleLabel.textColor = [UIColor colorWithRed:0x84/255.0 green: 0x77/255.0 blue:0x58/255.0 alpha:1];//  PSColorC4];
    }
}

- (void)updateWithSelectionOption:(PTMediaSelectionOption *)option
{
    self.option = option;
    
  //
    self.titleLabel.text = NSLocalizedString([option.title uppercaseString],nil);
    
//    self.titleLabel.text = option.title;
    self.offMode = NO;
    
    [self setSelected:option.selected animated:NO];
    
    [self updateForSelected];
}

- (void)updateForSelected
{
    self.checkImage.hidden = !self.option.selected;
    [self updateForHighlight];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    [self updateForHighlight];
}

- (void) updateForHighlight
{
    if (self.highlighted || (self.option && self.option.selected) || (self.offMode && self.offSelected))
    {
        self.titleLabel.textColor =[UIColor colorWithRed:0xD8/255.0 green: 0xCD/255.0 blue:0xB0/255.0 alpha:1];
    }
    else
    {
        self.titleLabel.textColor = [UIColor colorWithRed:0x84/255.0 green: 0x77/255.0 blue:0x58/255.0 alpha:1];
    }
}

@end

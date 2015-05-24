//
//  PSLangSelectorCell.h
//  Starz
//
//  Created by Tüz Csaba on 25/11/14.
//  Copyright (c) 2014 accedo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PSDKLibrary/PSDKLibrary.h>

@interface PSLangSelectorCell : UITableViewCell

- (void)setupForOffSelected:(BOOL)selected;

- (void)updateWithSelectionOption:(PTMediaSelectionOption *)option;

@end

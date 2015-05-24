//
//  PSScrubbingThumbCell.h
//  Starz
//
//  Created by Tüz Csaba on 13/11/14.
//  Copyright (c) 2014 accedo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PSScrubbingThumbModel;

FOUNDATION_EXTERN  NSString * const scrubbingCellIdentifier;
 
@interface PSScrubbingThumbCell : UICollectionViewCell

- (void)setScale:(CGFloat)f;

- (void)updateWithThumb:(PSScrubbingThumbModel *)thumb;

@end

//
//  PSScrubbingThumbCell.m
//  Starz
//
//  Created by Tüz Csaba on 13/11/14.
//  Copyright (c) 2014 accedo. All rights reserved.
//

#import "PSScrubbingThumbCell.h"
#import "PSScrubbingThumbs.h"

static CGFloat MIN_SCALE = 1.0;
static CGFloat MAX_SCALE = 1.3;

NSString * const scrubbingCellIdentifier =@"ScrubbingCellId";

@interface PSScrubbingThumbCell()
{
    CGFloat scale;
}

@property (retain, nonatomic) PSScrubbingThumbModel * thumb;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint * imageLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * imageTopConstraint;

@property (weak, nonatomic) IBOutlet UIImageView * imageView;

@end

@implementation PSScrubbingThumbCell

- (void)awakeFromNib {
}

- (void)updateWithThumb:(PSScrubbingThumbModel *)thumb
{
    self.thumb = thumb;
    
    UIImage * image = thumb.image;
    
    [self.imageView setImage:image];
    
  //  scale = 1.0;
    
   // self.alpha = 0.8;
    
  //  [self setImageConstraintsForScale];
}

- (void)setScale:(CGFloat)f
{
    f = MAX(MIN_SCALE, f);
    
    f = MIN(MAX_SCALE, f);
    
    if (f > 1.0)
    {
        [self.superview bringSubviewToFront:self];
        
        scale = f;
        
        [self setImageConstraintsForScale];
    }
}

- (void)setImageConstraintsForScale
{
    CGSize originalSize = self.thumb.image.size;
    
    CGSize newSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);
    
    CGFloat top = (newSize.height - originalSize.height) / 2;
    CGFloat left = (newSize.width - originalSize.width) / 2;
    
    self.imageLeftConstraint.constant = -left;
    self.imageTopConstraint.constant = -top;
    
    [self.imageView setNeedsUpdateConstraints];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

@end

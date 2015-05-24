//
//  AbstractCustomControlUICollectionViewCell.m
//  Filmnet
//
//  Created by Csaba Tűz on 2014.04.29..
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//

#import "AbstractCustomControlUICollectionViewCell.h"
#import "AbstractClassUtils.h"
#import "Logging.h"

@interface AbstractCustomControlUICollectionViewCell(){
    BOOL constraintsSetUp;
}

@end

@implementation AbstractCustomControlUICollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        constraintsSetUp = NO;
        [self setUpCustomControl];
    }
    return self;
}

- (void)awakeFromNib
{
    constraintsSetUp = NO;
    [self setUpCustomControl];
}

- (void)dealloc
{
    self.control = nil;
}

- (UIViewController *)customControl
{
    return ABSTRACT_METHOD;
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (constraintsSetUp) return;
    
    [self setUpConstraints];
    
    constraintsSetUp = YES;
}

- (void)setUpConstraints
{
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[control]-(0)-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{@"control":self.control.view}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[control]-(0)-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{@"control":self.control.view}]];
}

- (void)setUpCustomControl
{
    //   self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    self.control = [self customControl];
       self.control.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
       self.control.view.frame = self.contentView.bounds;
    //[self.control.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.contentView addSubview:self.control.view];
    
     //[self updateConstraints];
    
    DLog(@"%@", self);
}

- (void)attachToViewController:(UIViewController*)controller {
    if (self.control.parentViewController) {
        if ([self.control.parentViewController isEqual:controller]) {
            return;
        } else {
            [self.control removeFromParentViewController];
        }
    }
    [controller addChildViewController:self.control];
}

@end

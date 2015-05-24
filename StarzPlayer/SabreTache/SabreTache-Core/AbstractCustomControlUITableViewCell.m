//
//  UICustomControlTableViewCell.m
//  Filmnet
//
//  Created by Csaba Tűz on 2014.03.02..
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//

#import "AbstractCustomControlUITableViewCell.h"

#import "AbstractClassUtils.h"
#import "Logging.h"
#import "Macros.h"

@interface AbstractCustomControlUITableViewCell(){
    BOOL constraintsSetUp;
}

@end

@implementation AbstractCustomControlUITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        constraintsSetUp = NO;
        [self setUpCustomControl];
    }
    return self;
}

- (void)awakeFromNib
{
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
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
    if (iOSVersion < 8.0)
    {
    }
    
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
   // self.control.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.control.view.frame = self.contentView.bounds;
    [self.control.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.contentView addSubview:self.control.view];
     
   // [self updateConstraints];
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

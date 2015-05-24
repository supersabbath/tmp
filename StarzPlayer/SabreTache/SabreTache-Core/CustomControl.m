//
//  CustomControl.m
//  Starz
//
//  Created by Csaba Tűz on 2014.06.09..
//  Copyright (c) 2014 socialmultipass. All rights reserved.
//

#import "CustomControl.h"

@interface CustomControl()

@end

@implementation CustomControl

+ (id) loadFromNib {
    NSString* nibName = NSStringFromClass([self class]);
    NSArray* elements = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    for (NSObject* anObject in elements) {
        if ([anObject isKindOfClass:[self class]]) {
            return anObject;
        }
    }
    return nil;
}

- (id) awakeAfterUsingCoder:(NSCoder*)aDecoder {
    BOOL theThingThatGotLoadedWasJustAPlaceholder = ([[self subviews] count] == 0);
    if (theThingThatGotLoadedWasJustAPlaceholder) {
        CustomControl * theRealThing = [[self class] loadFromNib];
        
        // pass properties through
        theRealThing.frame = self.frame;
        theRealThing.autoresizingMask = self.autoresizingMask;
        theRealThing.alpha = self.alpha;
        theRealThing.hidden = self.hidden;
        theRealThing.userInteractionEnabled = self.userInteractionEnabled;
        
        for (NSLayoutConstraint * c in [self.constraints copy])
        {
            if (c.firstItem == self && c.secondItem == nil)
            {
                [theRealThing addConstraint:[NSLayoutConstraint constraintWithItem:theRealThing
                                                                         attribute:c.firstAttribute relatedBy:c.relation toItem:c.secondItem attribute:c.secondAttribute multiplier:c.multiplier constant:c.constant]];
            }
            else if (c.secondItem == self && c.firstItem == nil)
            {
                [theRealThing addConstraint:[NSLayoutConstraint constraintWithItem:c.firstItem
                                                                         attribute:c.firstAttribute relatedBy:c.relation toItem:theRealThing attribute:c.secondAttribute multiplier:c.multiplier constant:c.constant]];
            }
        }
        [theRealThing setNeedsUpdateConstraints];
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        theRealThing.translatesAutoresizingMaskIntoConstraints = NO;
        
        return theRealThing;
    }
    return self;
}

@end

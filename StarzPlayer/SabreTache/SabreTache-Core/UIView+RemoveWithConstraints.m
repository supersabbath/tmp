
#import "UIView+RemoveWithConstraints.h"

@implementation UIView (RemoveWithConstraints)

- (void)removeFromSuperviewWithConstraints {
    UIView *s = self.superview;
    NSMutableArray *toRemove = [NSMutableArray array];
    if (s != nil) {
        for (NSLayoutConstraint *c in [s.constraints copy]) {
            if (c.firstItem == self || c.secondItem == self) {
                [toRemove addObject:c];
            }
        }
    }
    
    [s removeConstraints:toRemove];
    
    [self removeFromSuperview];
}

@end

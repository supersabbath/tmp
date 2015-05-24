
#import "SubtitleProvider.h"

NSString * const SubtitleProviderDidSelectSubtitleNotification;

@implementation SubtitleRef

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[SubtitleRef class]]) return NO;
    SubtitleRef * other = (SubtitleRef *)object;
    return [other.title isEqualToString:self.title] && ((other.locale == nil && self.locale == nil) || [other.locale isEqual:self.locale]);
}

@end


@implementation SubtitleEntry

@end

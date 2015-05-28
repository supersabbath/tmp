//
//  UIButton+Utils.m
//  Starz
//
//  Created by Tüz Csaba on 21/11/14.
//  Copyright (c) 2014 accedo. All rights reserved.
//

#import "UIButton+Player.h"

 

@implementation UIButton (Player)

- (void)setProvidedAssetAsBackgroundImage:(NSString *)asset
{
    UIImage * resizableNormal = [[UIImage imageNamed:[NSString stringWithFormat:@"%@n.png", asset]] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    UIImage * resizableDisabled = [[UIImage imageNamed:[NSString stringWithFormat:@"%@d.png", asset]] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    UIImage * resizablePressed = [[UIImage imageNamed:[NSString stringWithFormat:@"%@p.png", asset]] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [self setBackgroundImage:resizableNormal forState:UIControlStateNormal];
    [self setBackgroundImage:resizablePressed forState:UIControlStateSelected];
    [self setBackgroundImage:resizableDisabled forState:UIControlStateDisabled];
    [self setBackgroundImage:resizablePressed forState:UIControlStateHighlighted];
}

- (void) setProvidedAssetAsImage:(NSString *)asset
{
    UIImage * resizableNormal = [UIImage imageNamed:[NSString stringWithFormat:@"%@n.png", asset]];
    UIImage * resizableDisabled = [UIImage imageNamed:[NSString stringWithFormat:@"%@d.png", asset]];
    UIImage * resizablePressed = [UIImage imageNamed:[NSString stringWithFormat:@"%@p.png", asset]];
    [self setImage:resizableNormal forState:UIControlStateNormal];
    [self setImage:resizableDisabled forState:UIControlStateDisabled];
    [self setImage:resizablePressed forState:UIControlStateHighlighted];
    [self setBackgroundImage:resizablePressed forState:UIControlStateSelected];
}

//+ (NSMutableAttributedString *)buttonAttributedString:(NSString *)text
//{
//    return [[[NSAttributedString
//              withString:text]
//             withTracking:IS_IPAD ? 2 : 3] withFont:[FontUtil fontWithKey:IS_IPAD ? PSFontPDRS : PSFontPDRXXS]];
//}

//- (void)updateWatchButtonTitleForState:(PSWatchlistType)watchListType color:(UIColor *)c
//{
//    NSString* watchTitleStr = nil;
//    switch (watchListType) {
//        case PSWatchlistTypeWatchedlist:
//            watchTitleStr = ACLocalizedString(@"key_playButtonTitle_watchAgain");
//            break;
//        case PSWatchlistTypeWatchlist:
//            watchTitleStr = ACLocalizedString(@"dict_series_resume");
//            break;
//        case PSWatchlistTypeNone:
//        case PSWatchlistTypeWishlist:
//        default:
//            watchTitleStr = ACLocalizedString(@"dict_movies_whatchnow");
//            break;
//    }
//    watchTitleStr = [watchTitleStr uppercaseString];
//    
//    NSMutableAttributedString * watchTitle = [UIButton buttonAttributedString:watchTitleStr];
//    
//    [self setAttributedTitle:[[watchTitle mutableCopy] withColor:c] forState:UIControlStateNormal];
//    [self setAttributedTitle:[[watchTitle mutableCopy] withColor:c] forState:UIControlStateHighlighted];
//}

@end

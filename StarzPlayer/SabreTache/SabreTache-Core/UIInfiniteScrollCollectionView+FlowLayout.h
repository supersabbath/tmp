//
//  UIInfiniteScrollCollectionView+FlowLayout.h
//  Filmnet
//
//  Created by Csaba Tűz on 2014.03.01..
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//

#import "UIInfiniteScrollCollectionView.h"

@interface UIInfiniteScrollCollectionView (FlowLayout)

- (NSInteger)flowLayout_scrollRedundancy;

- (CGRect)flowLayout_paddedFrameForItemFrame:(CGRect)sourceFrame;

@end

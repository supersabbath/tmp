//
//  UIInfiniteScrollCollectionView+FlowLayout.m
//  Filmnet
//
//  Created by Csaba Tűz on 2014.03.01..
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//

#import "UIInfiniteScrollCollectionView+FlowLayout.h"
#import "UIInfiniteScrollCollectionView_Private.h"

@implementation UIInfiniteScrollCollectionView (FlowLayout)

- (NSInteger)flowLayout_scrollRedundancy
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    // This is the minimal value, as we need elements both before and after the canonical ones.
    int redundancy = 3;
    
    CGSize itemSize = [flowLayout itemSize];
    int paddingHorizontal = flowLayout.minimumInteritemSpacing;
    int paddingVertical = flowLayout.minimumLineSpacing;
    
    CGFloat height = 0;
    CGFloat width = 0;
    if (flowLayout.scrollDirection == UICollectionViewScrollDirectionVertical)
    {
        height = (itemSize.height + paddingVertical) * [self.dataSourceProxy.core collectionView:self numberOfItemsInSection:0];
        width = itemSize.width;
    }
    else if (flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal)
    {
        height = itemSize.height;
        width = (itemSize.width + paddingHorizontal) * [self.dataSourceProxy.core collectionView:self numberOfItemsInSection:0];
    }
    
    CGSize contentSize = CGSizeMake(width, height);
    
    
    // Now we check what multiply of the actual content width we need
    // to be able to fill the screen with dummy elements.
    // A demonstration of correctness of this algorithm for flow layouts:
    // -
    int i = 1;
    if (flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal)
    {
        if (contentSize.width > 0)
        {
            CGFloat viewPortWidth = self.frame.size.width;
            
            while (i * contentSize.width < viewPortWidth) {
                redundancy += 2;
                ++i;
            }
        }
    }
    else
    {
        if (contentSize.height > 0)
        {
            CGFloat viewPortHeight = self.frame.size.height;
            
            while (i * contentSize.height < viewPortHeight) {
                redundancy += 2;
                ++i;
            }
        }
    }
    
    return redundancy;
}

- (CGRect)flowLayout_paddedFrameForItemFrame:(CGRect)sourceFrame
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    
    int paddingHorizontal = flowLayout.minimumInteritemSpacing;
    int paddingVertical = flowLayout.minimumLineSpacing;
    
    switch (flowLayout.scrollDirection)
    {
        case UICollectionViewScrollDirectionHorizontal:
            sourceFrame.size.width += paddingHorizontal;
            break;
        case UICollectionViewScrollDirectionVertical:
            sourceFrame.size.height += paddingVertical;
            break;
    }
    
    return sourceFrame;
}

@end

//
//  UIInfiniteScrollCollectionView.m
//  Filmnet
//
//  Created by Csaba Tűz on 2014.03.01..
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//

#import "UIInfiniteScrollCollectionView.h"
#import "UIInfiniteScrollCollectionView_Private.h"

#import "UIInfiniteScrollCollectionView+FlowLayout.h"

@implementation NSCopyIndexPath

- (NSIndexPath *)toRenderIndexPathWithModelSize:(NSInteger)modelSize
{
    return [NSIndexPath indexPathForItem:self.copyIdx * modelSize + self.item inSection:self.section];
}

+ (NSCopyIndexPath *)fromRenderIndexPath:(NSIndexPath *)indexPath withModelSize:(NSInteger)modelSize
{
    NSUInteger indices[2];
    indices[0] = indexPath.section;
    if (modelSize == 0)
    {
        indices[1] = 0;
    }
    else
    {
        indices[1] = indexPath.item % modelSize;
    }
    NSCopyIndexPath *p = [[NSCopyIndexPath alloc] initWithIndexes:indices length:2];
    if (modelSize == 0)
    {
        p.copyIdx = 0;
    }
    else
    {
        p.copyIdx = indexPath.item / modelSize;
    }
    return p;
}

@end

@implementation UIInfiniteScrollCollectionViewDataSourceProxy

- (id)initWithRealDataSource:(id<UICollectionViewDataSource>)dataSource forCollectionView:(UIInfiniteScrollCollectionView *)collectionView
{
    self = [super initWithCore:dataSource];
    if (self)
    {
        self.collectionView = collectionView;
    }
    return self;
}

- (void)dealloc
{
    self.core = nil;
    self.collectionView = nil;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger sup = 1;
    if ([self.core respondsToSelector:@selector(numberOfSectionsInCollectionView:)])
    {
        sup = [self.core numberOfSectionsInCollectionView:collectionView];
    }
    NSAssert(sup <= 1, @"Multi-section infinite scrolling is not yet supported.");
    return sup;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger sup = [self.core collectionView:collectionView numberOfItemsInSection:section];
    
    return sup * self.collectionView.scrollRedundancy;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger elementCount = [self.core collectionView:self.collectionView numberOfItemsInSection:indexPath.section];
    NSIndexPath *p = [NSCopyIndexPath fromRenderIndexPath:indexPath withModelSize:elementCount];
    return [self.core collectionView:self.collectionView cellForItemAtIndexPath:p];
}

@end

@implementation UIInfiniteScrollCollectionViewDelegateProxy

- (id)initRealDelegate:(id<UICollectionViewDelegate>)realDelegate forCollectionView:(UIInfiniteScrollCollectionView *)collectionView;
{
    self = [super initWithCore:realDelegate];
    if (self)
    {
        self.collectionView = collectionView;
    }
    return self;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger elementCount = [self.collectionView.dataSourceProxy.core collectionView:self.collectionView numberOfItemsInSection:indexPath.section];
    if ([self.core respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)])
    {
        [self.core collectionView:self.collectionView didSelectItemAtIndexPath:[NSCopyIndexPath fromRenderIndexPath:indexPath withModelSize:elementCount]];
    }
}

@end

@interface UIInfiniteScrollCollectionView()
{
    CGFloat width;
    CGFloat height;
}

@end

@implementation UIInfiniteScrollCollectionView

@synthesize canonicalBounds = _canonicalBounds;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setDataSource:(id<UICollectionViewDataSource>)dataSource
{
    if (self.dataSourceProxy)
    {
        self.dataSourceProxy.core = nil;
    }
    if (dataSource != nil)
    {
        self.dataSourceProxy = [[UIInfiniteScrollCollectionViewDataSourceProxy alloc] initWithRealDataSource:dataSource forCollectionView:self];
    }
    else
    {
        self.dataSourceProxy = nil;
    }
    [super setDataSource:self.dataSourceProxy];
}

- (void)setDelegate:(id<UICollectionViewDelegate>)delegate
{
    if (self.delegateProxy)
    {
        self.delegateProxy.core = nil;
    }
    if (delegate != nil)
    {
        self.delegateProxy = [[UIInfiniteScrollCollectionViewDelegateProxy alloc] initRealDelegate:delegate forCollectionView:self];
    }
    else
    {
        self.delegateProxy = nil;
    }
    [super setDelegate:self.delegateProxy];
}

/* The minimal redundancy necessary to be able to create the impression of
 *  infinite scrolling.
 *  This number is determined with simple math, considering the following factors:
 *  - There always have to be a full screen of dummy elements all around the Canonical Domain.
 *  - To simplify calculations, Scroll Redundancy is an integer, so that we can work with
 *    modulo arithmetic.
 *
 *  It is important to minimize scrollRedundancy, as it affects the CollectionView performance
 *  due to the necessity of calculating layout attributes for the redundant items too.
 */
- (NSInteger)scrollRedundancy
{
    if ([self isFlowLayout])
    {
        return [self flowLayout_scrollRedundancy];
    }

    return 10;
}

- (BOOL)isFlowLayout
{
    return ([self.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]);
}

- (CGRect)paddedFrameForItemFrame:(CGRect)sourceFrame
{
    if ([self isFlowLayout])
    {
        return [self flowLayout_paddedFrameForItemFrame:sourceFrame];
    }
    else
    {
        return sourceFrame;
    }
}

- (CGPoint)modelContentOffset
{
    CGRect canonical = [self canonicalBounds];
    int y = self.contentOffset.y;
    int x = self.contentOffset.x - canonical.origin.x;
    return CGPointMake(x, y);
}

- (void)setModelContentOffset:(CGPoint)contentOffset
{
    CGRect canonical = [self canonicalBounds];
    
    while (contentOffset.x >= canonical.origin.x)
    {
        contentOffset.x -= canonical.size.width;
    }
    
    CGPoint currentOffset = self.contentOffset;
    currentOffset.x = canonical.origin.x + contentOffset.x;
}

/*! The canonical bounds is the rectangle, where the reference copy of the model
 * is placed in the collection view. It's 'x' property is depending on the 'scrollRedundany'
 * property of the CollectionView, it's 'width' depends on the itemSizes and number of elements
 * in the model.
 */
- (CGRect)canonicalBounds
{
    if (_canonicalBounds.size.width <= 0) {
        NSInteger elementCount = [self.dataSourceProxy.core collectionView:self numberOfItemsInSection:0];
        
        CGRect res = CGRectZero;
        res.size.width = -1;
        
        NSInteger skippedElements = (self.scrollRedundancy / 2) * elementCount;
        if ([[self indexPathsForVisibleItems] count] > 0)
        {
            for (NSInteger i = skippedElements; i < skippedElements + elementCount; ++i) {
                
                UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
                CGRect fr = [self paddedFrameForItemFrame:attr.frame];
                if (res.size.width == -1) {
                    res = fr;
                } else {
                    res = CGRectUnion(res, fr);
                }
            }
        }
        _canonicalBounds = res;
    }
    return _canonicalBounds;
}

- (id)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath isKindOfClass:[NSCopyIndexPath class]])
    {
        NSCopyIndexPath *cpIdxPath = (NSCopyIndexPath *)indexPath;
        NSInteger elementCount = [self.dataSourceProxy.core collectionView:self numberOfItemsInSection:indexPath.section];
        NSIndexPath *dequePath = [cpIdxPath toRenderIndexPathWithModelSize:elementCount];
        return [super dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:dequePath];
    }
    return [super dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
}

- (void)reloadData
{
    self.canonicalBounds = CGRectMake(0, 0, -1, 0);
    
    [super reloadData];
}

- (void)reloadItemsAtIndexPaths:(NSArray *)indexPaths
{
    NSMutableArray *renderIndexPaths = [NSMutableArray array];
    for (NSIndexPath *path in indexPaths)
    {
        NSInteger elementCount = [self.dataSourceProxy.core collectionView:self numberOfItemsInSection:path.section];
        if ([path isKindOfClass:[NSCopyIndexPath class]])
        {
            [renderIndexPaths addObject:[(NSCopyIndexPath *)path toRenderIndexPathWithModelSize:elementCount]];
        }
        else
        {
            NSInteger scrollRedundancy = [self scrollRedundancy];
            for (int i = 0; i < scrollRedundancy; ++i)
            {
                NSIndexPath *p = [NSIndexPath indexPathForItem:i * elementCount + path.item  inSection:path.section];
                [renderIndexPaths addObject:p];
            }
        }
    }
    
    [super reloadItemsAtIndexPaths:renderIndexPaths];
}

- (CGPoint)pointBackToCanonical:(CGPoint)f
{
    CGRect canonical = [self canonicalBounds];
    if (canonical.size.width > 0)
    {
        CGFloat d1 = canonical.origin.x - f.x;
        if (d1 > 0)
        {
            f.x += ceil(d1 / canonical.size.width) * canonical.size.width;
        }
        CGFloat d2 = f.x - canonical.origin.x - canonical.size.width;
        if (d2 >= 0)
        {
            f.x -= ceil(d2 / canonical.size.width) * canonical.size.width;
        }
    }
    return f;
}

/**
 * We create the impression of infinite scrolling, by checking if our 'x'
 * coordinate is inside the canonical interval or not.
 * If it's not inside the interval, we keep adding multiplies of the canonical
 * content width, until we end up in the canonical rect.
 * Resetting the Content offset in 'layoutSubviews' preserves velocity and deceleration
 * in a smooth way.
 */
- (void)layoutSubviews
{
    if (width != self.frame.size.width || height != self.frame.size.height)
    {
        self.canonicalBounds = CGRectZero;
        width = self.frame.size.width;
        height = self.frame.size.height;
    }
    
    [super layoutSubviews];
    self.contentOffset = [self pointBackToCanonical:self.contentOffset];
}

@end

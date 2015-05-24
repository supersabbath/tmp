//
//  UIInfiniteScrollCollectionView_Private.h
//  Filmnet
//
//  Created by Csaba Tűz on 2014.03.01..
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//

#import "UIInfiniteScrollCollectionView.h"
#import "AbstractProtocolProxy.h"
/*!
 * In order so that users of UIInfiniteScrollCollectionView don't have to 
 * bother with redundancy, we need to send them model IndexPaths for render
 * IndexPaths. To achieve this we need to Proxy the original DataSource.
 *
 * This proxy handles the translation of render indexPaths to model indexPaths.
 * Based on the model IndexPath, user of the class can map to its model, while
 * thanks to the 'copyIdx' property of NSCopyIndexPath we will be able to reconstruct
 * render IndexPath for cell dequing.
 */
@interface UIInfiniteScrollCollectionViewDataSourceProxy : AbstractProtocolProxy<UICollectionViewDataSource>

@property (weak, nonatomic) UIInfiniteScrollCollectionView *collectionView;
@property (weak, nonatomic) id<UICollectionViewDataSource> core;

@end

@interface UIInfiniteScrollCollectionViewDelegateProxy : AbstractProtocolProxy<UICollectionViewDelegate>

@property (weak, nonatomic) UIInfiniteScrollCollectionView *collectionView;
@property (weak, nonatomic) id<UICollectionViewDelegate> core;

@end

/*! These properties define an internal set of data required to achieve the goal
 *  of infinite scrolling.
 *
 *  For this we have to define the concept of Canonical Domain on the CollectionView.
 *  The Canonical Domain is a selected copy of the Model data in the middle of the CollectionView
 *  which we hold as a reference, where the CollectionView always ,,wants to go back''.
 *
 *  The Scroll Redundancy is the number of identical copies of the original model data, both
 *  visually, and regarding content.
 */
@interface UIInfiniteScrollCollectionView()

@property (retain, nonatomic) UIInfiniteScrollCollectionViewDataSourceProxy *dataSourceProxy;
@property (retain, nonatomic) UIInfiniteScrollCollectionViewDelegateProxy *delegateProxy;

/*! The frame in the CollectionView's coordinate system of the Canonical Domain */
@property (assign, nonatomic) CGRect canonicalBounds;
/*! The Scroll Redundancy of the CollectionView */
- (NSInteger)scrollRedundancy;

@end

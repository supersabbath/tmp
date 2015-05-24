//
//  UIInfiniteScrollCollectionView.h
//  Filmnet
//
//  Created by Csaba Tűz on 2014.03.01..
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//

#import <UIKit/UIKit.h>

/*! Special NSIndexPath, which assumes that the same indexPath
 *  coordinates can belong to multiple copies of the same data.
 *  Thus it adds the copyIdx to identify which copy we refer to.
 *  This extra property allows us to define a 1-1 mapping between the
 *  IndexPaths in the model space and IndexPaths in the render space.
 */
@interface NSCopyIndexPath : NSIndexPath

@property (assign, nonatomic) NSInteger copyIdx;

- (NSIndexPath *)toRenderIndexPathWithModelSize:(NSInteger)modelSize;

@end

/*! UICollectionView implementation, which renders its cells in an infinite
 *  way.
 *  It achieves this, by defining a Canonical Domain containing the presentation
 *  of the data according to users's specs, and tiling the space around this domain
 *  with visually equivalent copies.
 *
 *  After this, upon layout it uses transformations, so that when it leaves the 
 *  Canonical Domain, it goes back to it in a way, that presentation of data is 
 *  visually equivalent after the transformation.
 *
 *  Usage is identical to any conventional UICollectionViews. Users of this class
 *  should not add any redundancy to their original model to provide impression of
 *  infinite scrolling, it is handled by the control.
 *
 *  TODO: Currently only UICollectionViewFlowLayout is supported.
 */
@interface UIInfiniteScrollCollectionView : UICollectionView

/*! The frame in the CollectionView's coordinate system of the Canonical Domain */
@property (assign, nonatomic, readonly) CGRect canonicalBounds;

@end

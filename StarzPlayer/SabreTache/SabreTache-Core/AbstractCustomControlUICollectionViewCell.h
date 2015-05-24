//
//  AbstractCustomControlUICollectionViewCell.h
//  Filmnet
//
//  Created by Csaba Tűz on 2014.04.29..
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CustomControlCell.h"

/**
 `AbstractCustomControlUICollectionViewCell` is a `CustomControlCell` implementation to be used
 as `UICollectionView` cells.
 */
@interface AbstractCustomControlUICollectionViewCell : UICollectionViewCell<CustomControlCell>

/** The managed `UIViewController` instance */
@property (retain, nonatomic) UIViewController *control;

@end

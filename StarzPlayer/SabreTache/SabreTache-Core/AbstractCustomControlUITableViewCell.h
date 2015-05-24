//
//  UICustomControlTableViewCell.h
//  Filmnet
//
//  Created by Csaba Tűz on 2014.03.02..
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomControlCell.h"

/**
 `AbstractCustomControlUITableViewCell` is a `CustomControlCell` implementation to be used
 as `UITableView` cells.
 */
@interface AbstractCustomControlUITableViewCell : UITableViewCell<CustomControlCell>

/** The managed `UIViewController` instance */
@property (retain, nonatomic) UIViewController * control;

@end

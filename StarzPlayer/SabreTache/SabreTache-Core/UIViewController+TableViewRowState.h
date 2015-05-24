//
//  UITableViewController+RowState.h
//  Filmnet
//
//  Created by Csaba Tűz on 2014.03.04..
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProtocolProperties.h"
#import "AbstractClassUtils.h"

/**
  @category TableViewRowState
 
  Provides a unified interface which allows `UIViewControllers` presenting 
  `UITableView` to maintain states for the individual rows of the UITableView.
 
  It allows grouping of states using a string key, which is useful e.g. to
  maintain the states of multiple UITableViews with different models using the same
  unified interface.
 */
@interface UIViewController(TableViewRowState)

CATEGORY_PROPERTY(NSMutableDictionary*, tableViewStates)

- (void)clearStatesForGroup:(NSString *)group;

- (void)stateGroup:(NSString *)group updateState:(id<StateProvider>)target forIndexPath:(NSIndexPath *)indexPath;

- (void)stateGroup:(NSString *)group saveState:(id<StateProvider>)target forIndexPath:(NSIndexPath *)indexPath;

@end

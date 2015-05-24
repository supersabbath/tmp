//
//  UITableViewController+RowState.m
//  Filmnet
//
//  Created by Csaba Tűz on 2014.03.04..
//  Copyright (c) 2014 se.filmnet. All rights reserved.
//
#import "UIViewController+TableViewRowState.h"

@implementation UIViewController (TableViewRowState)

SYNTHESIZE_CATEGORY_PROPERTY(tableViewStates, [NSMutableDictionary new])

- (NSMutableDictionary *)stateForGroup:(NSString *)group
{
    NSMutableDictionary *states = [self.tableViewStates objectForKey:group];
    if (states == nil)
    {
        states = [NSMutableDictionary new];
        [self.tableViewStates setObject:states forKey:group];
    }
    return states;
}

- (void)clearStatesForGroup:(NSString *)group
{
    NSMutableDictionary *states = [self stateForGroup:group];
    
    [states removeAllObjects];
}

- (void)stateGroup:(NSString *)group saveState:(id<StateProvider>)target forIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *states = [self stateForGroup:group];
    
    [states setObject:[target currentState] forKey:indexPath];
}

- (void)stateGroup:(NSString *)group updateState:(id<StateProvider>)target forIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *states = [self stateForGroup:group];
    
    [target updateObjectState:[states objectForKey:indexPath]];
}

@end
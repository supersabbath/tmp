#import "UIViewController+PagedLoading.h"

#import <libkern/OSAtomic.h>

#import "Logging.h"

#import "LanguageManager.h"

@implementation UIViewController (PagedLoading)

@dynamic fetching;
@dynamic entries;
@dynamic tableView;
@dynamic collectionView;
@dynamic totalNumberOfRows;
@dynamic currentPage;
@dynamic pageSize;
@dynamic rowHeightCache;
@dynamic refreshControl;

- (void)PagedLoading_setup
{
    if ([self respondsToSelector:@selector(collectionView)])
    {
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CollectionLoadingCellIdentifier];
    }
}

- (void)PagedLoading_setUpRefreshControl
{
    if (self.refreshControl == nil)
    {
        self.tableView.alwaysBounceVertical = YES;
        
        self.refreshControl = [[UIRefreshControl alloc] init];
        
        self.refreshControl.tintColor = [UIColor whiteColor];
        
        [self.refreshControl addTarget:self action:@selector(fetchNewData:) forControlEvents:UIControlEventValueChanged];
        [self.tableView addSubview:self.refreshControl];
        self.tableView.alwaysBounceVertical = YES;
        
        [self.tableView sendSubviewToBack:self.refreshControl];
    }
}

- (void)PagedLoading_cleanupRefreshControl
{
    [self.refreshControl removeFromSuperview];
    self.refreshControl = nil;
}

- (void)PagedLoading_setUpCollectionViewRefreshControl
{
    if (self.refreshControl == nil)
    {
        self.collectionView.alwaysBounceVertical = YES;
        
        self.refreshControl = [[UIRefreshControl alloc] init];
        
        self.refreshControl.tintColor = [UIColor whiteColor];
        
        [self.refreshControl addTarget:self action:@selector(fetchNewData:) forControlEvents:UIControlEventValueChanged];
        [self.collectionView addSubview:self.refreshControl];
        self.collectionView.alwaysBounceVertical = YES;
    }
}

- (void)PagedLoading_cleanUpPagedLoading
{
    if ([self respondsToSelector:@selector(refreshControl)])
    {
        [self.refreshControl removeFromSuperview];
        self.refreshControl = nil;
    }
}



- (void)PagedLoading_resetData
{
    @synchronized(self)
    {
#warning - what about this?
        //[RequestHandle cancelAllRequestsOwnedBy:self];
        
        self.entries = [NSMutableArray array];
        self.currentPage = 0;
        self.totalNumberOfRows = -1;
        
        self.rowHeightCache = [NSMutableDictionary dictionary];
        
        if ([self respondsToSelector:@selector(tableView)])
        {
            [self.tableView reloadData];
        }
        if ([self respondsToSelector:@selector(collectionView)])
        {
            [self.collectionView reloadData];
        }
        
        [self fetchAndAppendPage:1 onComplete:nil];
    }
}

- (void)PagedLoading_updateData
{
    if (self.entries == nil || [self.entries count] == 0)
    {
        [self PagedLoading_resetData];
    }
    else
    {
        [self fetchNewData:nil];
    }
}

- (void)fetchNewData:(id)sender
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int totalNumRowsBefore = self.totalNumberOfRows;
        
        __block int firstPtr = 0;
        __block id currentFirst = [self.entries firstObject];
        NSMutableArray *newElements = [NSMutableArray array];
        __block int i = 0;
        __block BOOL done = NO;
        NSCondition * ready = [[NSCondition alloc] init];
        
        void(^failure)(NSError *) = ^(NSError *error) {
            [ready lock];
            DLog(@"Can't get status feed");
            [self.refreshControl endRefreshing];
            DLog(@"Model size: %d/%d", [self.entries count], self.totalNumberOfRows);
            done = YES;
            [ready signal];
            [ready unlock];
        };
        
        __weak void(^weak_success)(id<PagedModel>);
        void(^success)(id);
        weak_success = success = ^(id<PagedModel> result) {
            [ready lock];
            self.totalNumberOfRows = result.totalNumberOfRows;
            if ([result.pageContent count] == 0)
            {
                done = YES;
                [ready signal];
                [ready unlock];
                return;
            }
            if ([result.pageContent count] > 0)
            {
                for (id e in result.pageContent)
                {
                    if ([e isEqual:currentFirst])
                    {
                        if ([newElements count] == self.totalNumberOfRows - totalNumRowsBefore)
                        {
                            done = YES;
                            [ready signal];
                            break;
                        }
                        else
                        {
                            ++firstPtr;
                            if ([self.entries count] > firstPtr)
                            {
                                currentFirst = self.entries[firstPtr];
                            }
                        }
                    }
                    else
                    {
                        [self.entries insertObject:e atIndex:firstPtr];
                        [newElements addObject:e];
                    }
                }
                if (!done)
                {
                    if (i < self.currentPage)
                    {
                        ++i;
                        [[(id<PageLoadingProtocol>)self fetchDataForPage:i count:self.pageSize onSuccess:weak_success onFailure:failure] own:self];
                    }
                    else
                    {
                        done = YES;
                        [ready signal];
                    }
                }
            }
            [ready unlock];
        };
        
        
        [[(id<PageLoadingProtocol>)self fetchDataForPage:i count:self.pageSize onSuccess:success onFailure:failure] own:self];
        [ready lock];
        
        while (!done)
        {
            [ready waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        }
        
        [ready unlock];
        
        DLog(@"%d new elements.", [newElements count]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            
            self.rowHeightCache = [NSMutableDictionary dictionary];
            if ([self respondsToSelector:@selector(tableView)])
                [self.tableView reloadData];
            if ([self respondsToSelector:@selector(collectionView)])
            {
                [self.collectionView reloadData];
                [self PagedLoading_scrollViewDidScroll:self.collectionView];
            }
        });
    });
}

- (void)fetchAndAppendPage:(NSInteger)page onComplete:(void(^)(void))complete
{
    if (self.fetching) return;
    self.fetching = YES;
    __block void(^bComplete)(void) = complete;
    [[(id<PageLoadingProtocol>)self fetchDataForPage:page count:self.pageSize onSuccess:^(id<PagedModel> result) {
        self.totalNumberOfRows = result.totalNumberOfRows;
        if ([result.pageContent count] > 0)
        {
            [self appendData:result];
            
            self.currentPage = page;
        }
        else
        {
            DLog(@"No more data.");
            
        }
        self.rowHeightCache = [NSMutableDictionary dictionary];
        if ([self respondsToSelector:@selector(tableView)])
            [self.tableView reloadData];
        if ([self respondsToSelector:@selector(collectionView)])
        {
            [self.collectionView reloadData];
            [self PagedLoading_scrollViewDidScroll:self.collectionView];
        }
        
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        DLog(@"Model size: %d/%d", [self.entries count], self.totalNumberOfRows);
        
        
        if (bComplete)
        {
            bComplete();
        }
        
        self.fetching = NO;
    } onFailure:^(NSError *error) {
        DLog(@"Can't get status feed");
        DLog(@"Model size: %d/%d", [self.entries count], self.totalNumberOfRows);
      
        if (bComplete)
        {
            bComplete();
        }
        self.fetching = NO;
    }] own:self];
}

#pragma mark - Data manipulation

- (void)updateWitData:(id<PagedModel>)statusFeed
{
    self.entries = [statusFeed.pageContent mutableCopy];
    self.totalNumberOfRows = statusFeed.totalNumberOfRows;
    self.rowHeightCache = [NSMutableDictionary dictionary];
    if ([self respondsToSelector:@selector(tableView)])
        [self.tableView reloadData];
    if ([self respondsToSelector:@selector(collectionView)])
    {
        [self.collectionView reloadData];
    }
}

- (void)appendData:(id<PagedModel>)statusFeed
{
    if (self.entries == nil) self.entries = [NSMutableArray array];
    [self.entries addObjectsFromArray:statusFeed.pageContent];
}

#pragma mark - Special UITableViewDelegate methods

- (BOOL)PagedLoading_shouldShowLoadingCell
{
    return [self.entries count] < self.totalNumberOfRows && self.totalNumberOfRows > -1;
}

- (UITableViewCell *)PagedLoading_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.entries count])
    {
        UITableViewCell * cell = [[UITableViewCell alloc] init];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIActivityIndicatorView * activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [cell.contentView addSubview:activity];
        activity.center = CGPointMake(cell.contentView.bounds.size.width / 2, cell.contentView.bounds.size.height / 2);
        activity.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        
        [activity startAnimating];
        activity.hidden = NO;
        
        return cell;
    }
    return nil;
}

static NSString * const CollectionLoadingCellIdentifier = @"CollectionLoadingCell";

- (UICollectionViewCell *)PagedLoading_collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.entries count])
    {
        UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionLoadingCellIdentifier forIndexPath:indexPath];
        UILabel * label = (UILabel *)[cell viewWithTag:987];
        if (!label)
        {
            label = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
            label.tag = 987;
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            [cell.contentView addSubview:label];
        }
        [label setText:ACLocalizedString(@"dict_index_loading")];
        
        return cell;
    }
    return nil;
}

- (void)PagedLoading_tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.entries count])
    {
        [self fetchAndAppendPage:self.currentPage + 1 onComplete:nil];
    }
}

- (void)PagedLoading_scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self PagedLoading_scrollViewWillBeginDecelerating:scrollView];
}

- (void)PagedLoading_scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView && !self.fetching && ((scrollView.contentOffset.x > scrollView.contentSize.width - 2 * scrollView.frame.size.width)) && [self.entries count] < self.totalNumberOfRows)
    {
        
        [self fetchAndAppendPage:self.currentPage + 1 onComplete:nil];
    }
}

- (void)PagedLoading_fetchAllPagesWithLimit:(NSInteger)limit onComplete:(void(^)(void))complete
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        __block int ready = 0;
        
        __block __weak void(^weak_success)(void);
        void(^success)(void);
        weak_success = success = ^{
            if ([self.entries count] < limit)
            {
                [self fetchAndAppendPage:self.currentPage + 1 onComplete:weak_success];
            }
            else
            {
                OSAtomicIncrement32(&ready);
                dispatch_semaphore_signal(sema);
                if (complete)
                {
                    complete();
                }
            }
        };
        
        success();
        
        if (ready == 0)
        {
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }
    });
}

- (BOOL)truncateToPage
{
    if (self.pageSize == 0) return NO;
    BOOL neededRemove = NO;
    while ([self.entries count] > self.pageSize && [self.entries count] % self.pageSize != 0)
    {
        [self.entries removeLastObject];
        neededRemove = YES;
    }
    return neededRemove;
}

/**
 * Removes and item from the model, while keeping the paged loading
 * in a consistent state, so that it will operate properly further.
 */
- (void)PagedLoading_deleteItemAtIndex:(NSInteger)index
{
    
    [self.entries removeObjectAtIndex:index];
    self.totalNumberOfRows -= 1;
    
    [self truncateToPage];
   
    self.currentPage -= 1;
}

- (void)PagedLoading_addItemAtFront:(id)item
{
    [self PagedLoading_addItem:item atIndex:0];
}

- (void)PagedLoading_addItem:(id)item atIndex:(NSInteger)index
{
    [self.entries insertObject:item atIndex:index];
    self.totalNumberOfRows += 1;
    
    [self truncateToPage];
}

@end

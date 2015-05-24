#import <UIKit/UIKit.h>

#import "BaseWebServiceResource.h"

#import "ProtocolProperties.h"
#import "PagedLoadingMacros.h"

@class MyEternityPagingResult;
@class RequestHandle;

@protocol PagedModel

@property (assign, nonatomic) NSInteger page;
@property (retain, nonatomic, readonly) NSArray * pageContent;
@property (assign, nonatomic) NSInteger totalNumberOfRows;

@end

@protocol PageLoadingProtocol

- (RequestHandle *)fetchDataForPage:(NSInteger)page count:(NSInteger)count onSuccess:(void(^)(id<PagedModel>))success onFailure:(FailureBlock)failure;

@end



@interface UIViewController (PagedLoading)

PAGE_LOADING_PROPERTIES

PAGE_LOADING_TABLEVIEW

PAGE_LOADING_COLLECTIONVIEW
/** Be sure to call PagedLoading_setup once for each instance of the user view controller. */
- (void)PagedLoading_setup;

- (void)PagedLoading_resetData;
- (void)PagedLoading_updateData;


- (BOOL)PagedLoading_shouldShowLoadingCell;

- (void)PagedLoading_cleanupRefreshControl;
- (void)PagedLoading_setUpRefreshControl;
- (void)PagedLoading_setUpCollectionViewRefreshControl;

- (void)PagedLoading_cleanUpPagedLoading;

- (UITableViewCell *)PagedLoading_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (UICollectionViewCell *)PagedLoading_collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)PagedLoading_tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)PagedLoading_scrollViewDidScroll:(UIScrollView *)scrollView;

- (void)PagedLoading_scrollViewWillBeginDecelerating:(UIScrollView *)scrollView;

- (void)PagedLoading_fetchAllPagesWithLimit:(NSInteger)limit onComplete:(void(^)(void))complete;

- (void)fetchAndAppendPage:(NSInteger)page onComplete:(void(^)(void))complete;

- (void)PagedLoading_deleteItemAtIndex:(NSInteger)index;

- (void)PagedLoading_addItemAtFront:(id)item;

- (void)PagedLoading_addItem:(id)item atIndex:(NSInteger)index;

@end

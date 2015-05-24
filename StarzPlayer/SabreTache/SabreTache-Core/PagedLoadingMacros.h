#define PAGE_LOADING_PROPERTIES \
@property (retain, nonatomic) NSMutableArray * entries;\
@property (assign, nonatomic) NSInteger totalNumberOfRows; \
@property (assign, nonatomic) NSInteger currentPage; \
@property (assign, nonatomic) NSInteger pageSize; \
@property (retain, nonatomic) NSMutableDictionary * rowHeightCache; \
@property (assign, nonatomic) BOOL fetching;\
@property (retain, nonatomic) UIRefreshControl * refreshControl;

#define PAGE_LOADING_TABLEVIEW \
@property (retain, nonatomic) IBOutlet UITableView * tableView;

#define PAGE_LOADING_COLLECTIONVIEW \
@property (retain, nonatomic) IBOutlet UICollectionView * collectionView;
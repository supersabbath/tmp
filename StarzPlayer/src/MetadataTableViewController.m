//
//  MetadataTableViewController.m
//  StarzPlayer
//
//  Created by Fernando Canon on 21/05/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import "MetadataTableViewController.h"
#import "PSLangSelectorCell.h"

@interface MetadataTableViewController () {
    
    PTMediaPlayerItem *currentItem;
}

@property (nonatomic,weak) IBOutlet UIView * metadataHeaderView;
@property (strong, nonatomic) NSMutableArray * subtitleDataSource;

@end


@implementation MetadataTableViewController

-(id) initWithAVPlayerItem:(PTMediaPlayerItem*) item {
    
    self = [[MetadataTableViewController alloc] initWithNibName:@"MetadataTableViewController" bundle:nil];
    if (self) {
        currentItem = item;
            }
    return self;
}

-(void) reloadDataForItem:(PTMediaPlayerItem*) item
{
    currentItem = item;
    [_audiosTableView reloadData];
    [_subtitlesTableView reloadData];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerTablesForCellNib];
}

-(void) registerTablesForCellNib
{

    UINib * langSelectorCellNib = [UINib nibWithNibName:@"PSLangSelectorCell" bundle:nil];
    [self.audiosTableView registerNib:langSelectorCellNib forCellReuseIdentifier:@"PSLangSelectorCellID"];
    [self.subtitlesTableView registerNib:langSelectorCellNib forCellReuseIdentifier:@"PSLangSelectorCellID"];
    
 //   _subtitlesTableView.tableHeaderView = [self customHeaderView];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIView *) customHeaderView {
  
    if (!_metadataHeaderView) {
        [[NSBundle mainBundle] loadNibNamed:@"MetadataHeaderView" owner:self options:nil];
    }
    
    return _metadataHeaderView;
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    PSLangSelectorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PSLangSelectorCellID" forIndexPath:indexPath];
    
    if (tableView == self.audiosTableView)
    {
        NSArray * audioOptions = [currentItem audioOptions];
        
        PTMediaSelectionOption * option = audioOptions[indexPath.row];
        
        [cell updateWithSelectionOption:option];
        
    }
    else if (tableView == self.subtitlesTableView)
    {
        NSArray * subtitlesOptions = [currentItem  subtitlesOptions];
        if (indexPath.row == 0)
        {
            BOOL isAnySelected = NO;
            for (PTMediaSelectionOption * opt in subtitlesOptions)
            {
                isAnySelected |= opt.selected;
            }
            if ([self isSubtitlesOptionDefault])
                isAnySelected = NO;
            
            [cell setupForOffSelected:!isAnySelected];
        }
        else
        {
            PTMediaSelectionOption * option = subtitlesOptions[indexPath.row - 1];
            [cell updateWithSelectionOption:option];
        }

        
    }
    
    return cell;
}

-(BOOL) isSubtitlesOptionDefault
{
    NSArray * subtitleOptions = [ currentItem subtitlesOptions];
    PTMediaSelectionOption *subtitleOption = subtitleOptions.firstObject;
    return [subtitleOption.title isEqualToString:@"Default"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.audiosTableView)
    {
        NSArray * audioOptions = [currentItem audioOptions];
        PTMediaSelectionOption * audioOption = audioOptions[indexPath.row];
        [currentItem selectAudioOption:audioOption];
        [self.audiosTableView reloadData];
        
    }
    else if (tableView == self.subtitlesTableView)
    {
        NSArray * subtitleOptions = [currentItem subtitlesOptions];
        if (indexPath.row == 0)
        {
            [currentItem selectSubtitleOption:[PTMediaSelectionOption emptyOption]];
            [self sendCloseCaptionMessageToDelegateEnable:NO];
          
        }
        else
        {
            PTMediaSelectionOption * subtitleOption = subtitleOptions[indexPath.row - 1];
            [currentItem selectSubtitleOption:subtitleOption];
            [self sendCloseCaptionMessageToDelegateEnable:YES];
          
        }
       [self.subtitlesTableView reloadData];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (tableView == self.audiosTableView)
    {
        NSArray * audioOptions = [currentItem audioOptions];
        
        return [audioOptions count];
    }
    else if (tableView == self.subtitlesTableView)
    {
        // Solution for the case where there is no subtitles
        NSArray * subtitleOptions = [currentItem subtitlesOptions];
        if ([self isSubtitlesOptionDefault]) {
            return   [subtitleOptions count];
        }
        
        return [subtitleOptions count] + 1;
    }
    return 0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.audiosTableView)
        return @"AUDIOS";
    else
        return @"SUBTITLES";
    
}

#pragma mark - Helper

-(NSArray*) dataSourceForSubtitles:(NSArray*) adobeSubtitles
{
    if (self.subtitleDataSource == nil)
    {      self.subtitleDataSource =[@[] mutableCopy];
        
        PTMediaSelectionOption *subtitleOption = adobeSubtitles.firstObject;
        
        if (subtitleOption.isDefault) {
            PTMediaSelectionOption* option = [[PTMediaSelectionOption alloc] init];
            [self.subtitleDataSource addObject:option];
        }
        [self.subtitleDataSource addObjectsFromArray:adobeSubtitles];
    }
    
    return self.subtitleDataSource ;
}


-(void) sendCloseCaptionMessageToDelegateEnable:(BOOL) enabled
{
    if ([self.delegate respondsToSelector:@selector(metadataTableViewController:didSelectCloseCaptionOption:)])
    {
        [_delegate metadataTableViewController:self didSelectCloseCaptionOption:enabled];
    }
}


@end

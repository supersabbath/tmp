//
//  MetadataTableViewController.m
//  StarzPlayer
//
//  Created by Fernando Canon on 21/05/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import "MetadataTableViewController.h"
#import "PSLangSelectorCell.h"


#ifndef PLAYER_AS_IS_MODE
#import "LanguageManager.h"
#endif

#define HEADER_TEXT_LABEL_TAG 222


@interface MetadataTableViewController () {
    
    PTMediaPlayerItem *currentItem;

}

@property (weak, nonatomic) IBOutlet UILabel *subtitlesLabel;

@property (weak, nonatomic) IBOutlet UILabel *audiosLabel;

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
    
#ifdef PLAYER_AS_IS_MODE
    [self.audiosLabel setText: NSLocalizedString(@"key_moviePlayer_audio",nil)];
    [self.subtitlesLabel setText: NSLocalizedString(@"key_moviePlayer_subtitles", nil)];
#endif

#ifndef PLAYER_AS_IS_MODE
    
    [self.audiosLabel setText: ACLocalizedString(@"key_moviePlayer_audio")];
    [self.subtitlesLabel setText: ACLocalizedString(@"key_moviePlayer_subtitles")];
#endif
    [self registerTablesForCellNib];
}

-(void) registerTablesForCellNib
{

    UINib * langSelectorCellNib = [UINib nibWithNibName:@"PSLangSelectorCell" bundle:nil];
    [self.audiosTableView registerNib:langSelectorCellNib forCellReuseIdentifier:@"PSLangSelectorCellID"];
    [self.subtitlesTableView registerNib:langSelectorCellNib forCellReuseIdentifier:@"PSLangSelectorCellID"];
 
}



-(void) configureBackgroundColorInTables:(UIColor*) color
{
    [_audiosTableView setBackgroundColor:color];
    [_subtitlesTableView setBackgroundColor:color];
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



- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    view.tintColor = [UIColor blackColor];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    UILabel * textLabel = ( UILabel *) [header viewWithTag:HEADER_TEXT_LABEL_TAG];
    
    if (_headerFont)
    {
      
        
        [textLabel setFont:_headerFont];
        [textLabel setTextColor:(_headerTextColor)?_headerTextColor:[UIColor whiteColor]];
    }

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


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return  0;
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

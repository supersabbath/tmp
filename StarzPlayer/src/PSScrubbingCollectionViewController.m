//
//  PSScrubbingCollectionViewController.m
//  StarzPlayer
//
//  Created by Fernando Canon on 21/05/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import "PSScrubbingCollectionViewController.h"
#import "PSScrubbingThumbs.h"
#import "PSScrubbingThumbCell.h"

@interface PSScrubbingCollectionViewController ()

@property (strong, nonatomic) PSScrubbingThumbs * thumbnails;
@end

@implementation PSScrubbingCollectionViewController



static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"PSScrubbingThumbCell" bundle:nil] forCellWithReuseIdentifier:scrubbingCellIdentifier];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadScrubberIfNeeded];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}
#pragma mark - Public


- (void)fetchScrubbingImagesForULR:(NSString*) url
{
    PSScrubbingCollectionViewController __weak * weakSelf = self;
    
    self.thumbnails =[[PSScrubbingThumbs alloc] init];
    _thumbnails.url = [NSURL URLWithString:url];
    
    [_thumbnails fetchThumbsWithCompletion:^(BOOL succeded) {
        if (succeded) {
          
            [weakSelf.collectionView reloadData];
        }
    }];
}

-(void) reloadScrubberIfNeeded
{
    
    if (self.thumbnails.thumbnails) return;
        
    [_thumbnails fetchThumbsWithCompletion:^(BOOL succeded) {
        if (succeded) {
            
            [self.collectionView reloadData];
        }
    }];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.thumbnails.thumbnails count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PSScrubbingThumbCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:scrubbingCellIdentifier forIndexPath:indexPath];

    PSScrubbingThumbModel * thumb = self.thumbnails.thumbnails[indexPath.item ];
    [cell updateWithThumb:thumb];
    
    return cell;
}

@end

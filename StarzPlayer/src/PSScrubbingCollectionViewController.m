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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - Public

- (void)fetchScrubbingImagesForULR:(NSString*) url
{
    PSScrubbingCollectionViewController __weak * weakSelf = self;
    
    PSScrubbingThumbs *thunmbails =[[PSScrubbingThumbs alloc] init];
    thunmbails.url = [NSURL URLWithString:url];
    
    [thunmbails fetchThumbsWithCompletion:^(BOOL succeded) {
        if (succeded) {
            weakSelf.thumbnails = thunmbails;
            [weakSelf.collectionView reloadData];
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

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
    
   // [self.view setBackgroundColor:[UIColor purpleColor]];
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

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    CGFloat H = collectionView.bounds.size.height;
//    
//    CGFloat w = self.thumbnails.width * H / self.thumbnails.height;
//    return CGSizeMake(w, self.thumbnails.height);
//}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
//{
//    return 10;
//}

//- (void) scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    CGFloat offset = scrollView.contentOffset.x;
//    
//    CGFloat center = offset + scrollView.bounds.size.width / 2;
//    
//    for (NSIndexPath * idx in [self.collectionView indexPathsForVisibleItems])
//    {
//        PSScrubbingThumbCell * cell = (PSScrubbingThumbCell *)[self.collectionView cellForItemAtIndexPath:idx];
//        [cell setScale:1.0];
//    }
//    
//    NSIndexPath * idx = [self.collectionView indexPathForItemAtPoint:CGPointMake(center, scrollView.contentOffset.y)];
//    
//    PSScrubbingThumbCell * cell = (PSScrubbingThumbCell *)[self.collectionView cellForItemAtIndexPath:idx];
//    
//    NSInteger centerItem = idx.item;
//    
//    CGFloat itemLeft = centerItem * (self.thumbnails.width + 10);
//    CGFloat itemRight = itemLeft + self.thumbnails.width;
//    CGFloat itemCenter = (itemLeft + itemRight) / 2.0;
//    
//    [cell setScale:1.3 - 0.3 * (2 * ABS(center - itemCenter) / self.thumbnails.width) ];
//}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end

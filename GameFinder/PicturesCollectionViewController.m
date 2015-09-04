//
//  PicturesCollectionViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 9/3/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "PicturesCollectionViewController.h"
#import <Parse/Parse.h>
#import "UIImageView+WebCache.h"
#import "PicturesCollectionViewCell.h"

@interface PicturesCollectionViewController ()

@end

@implementation PicturesCollectionViewController

static NSString * const reuseIdentifier = @"PictureCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.picturesArray = self.mutableArray;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {


    return self.picturesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PicturesCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    PFFile *file = [self.picturesArray objectAtIndex:indexPath.row];
    NSURL *url = [NSURL URLWithString:file.url];
    cell.pictureImageView.clipsToBounds = YES;
    cell.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.layer.borderWidth = 2.0f;
    cell.layer.cornerRadius = 4.0f;
    [cell.pictureImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"loading"]];
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(collectionView.frame.size.width-10, collectionView.frame.size.height-100);
}


@end

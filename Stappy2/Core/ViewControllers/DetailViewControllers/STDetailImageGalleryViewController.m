//
//  STDetailImageGalleryViewController.m
//  Stappy2
//
//  Created by Cynthia Codrea on 25/04/2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STDetailImageGalleryViewController.h"
#import "ImagePreviewCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIScrollView+Utils.h"

NSString *const kImagesPreviewCollectionViewIdentifier = @"ImagePreviewCollectionViewCell";

@interface STDetailImageGalleryViewController ()
@property (weak, nonatomic) IBOutlet UIPageControl *galeryPageControll;
@property(nonatomic,strong)NSArray* galleryDataSource;

@end

@implementation STDetailImageGalleryViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andDataSource:(NSArray*)dataSource {
    if (self = [super initWithNibName:nibNameOrNil bundle:nil]) {
        self.galleryDataSource = dataSource;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UINib * nib = [UINib nibWithNibName:@"ImagePreviewCollectionViewCell" bundle:nil];
    [self.detailImageGallery registerNib:nib forCellWithReuseIdentifier:kImagesPreviewCollectionViewIdentifier];
    
    // Set the number of pages
    self.galeryPageControll.numberOfPages = self.galleryDataSource.count;
}

#pragma mark - PrivateMethods

-(void)updatePageControll {
    self.galeryPageControll.currentPage = self.detailImageGallery.currentPage;
}

#pragma mark - UICollecitonView datasource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.galleryDataSource.count;
   
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *collectionCell = [[UICollectionViewCell alloc] init];
    collectionCell = [collectionView dequeueReusableCellWithReuseIdentifier:kImagesPreviewCollectionViewIdentifier forIndexPath:indexPath];
    ImagePreviewCollectionViewCell *cell = (ImagePreviewCollectionViewCell*)collectionCell;
    NSURL * imageUrl = [[NSURL alloc] initWithString:self.galleryDataSource[indexPath.row]];
    [cell.galleryImage sd_setImageWithURL:imageUrl];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize newSize = CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height);
    return newSize;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updatePageControll];
}

@end

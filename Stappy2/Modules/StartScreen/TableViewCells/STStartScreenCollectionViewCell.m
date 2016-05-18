//
//  STStartScreenCollectionViewCell.m
//  Stappy2
//
//  Created by Cynthia Codrea on 09/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STStartScreenCollectionViewCell.h"
#import "STStartTableCellCollectionViewCell.h"
#import "STStartModel.h"
#import "STWebViewDetailViewController.h"
#import "STAppSettingsManager.h"
#import "Utils.h"

@implementation STStartScreenCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    UINib * nib = [UINib nibWithNibName:@"STStartTableCellCollectionViewCell" bundle:nil];
    [self.categoryItemsCollection registerNib:nib forCellWithReuseIdentifier:@"collectionStartCell"];
    
    [self.categoryItemsCollection setPagingEnabled:YES];
    self.categoryLabel.lineBreakMode = NSLineBreakByWordWrapping;
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.categoryItemsCollection.collectionViewLayout;
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
}

#pragma mark - UICollectionView data source

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numberOfItems = [self.dataForItemsTable count];
    
    if (numberOfItems == 1) {
        self.itemScrollPageControl.hidden = YES;
    } else {
        self.itemScrollPageControl.hidden = NO;
        self.itemScrollPageControl.totalNumberOfPages = numberOfItems;
        self.itemScrollPageControl.currentIndicator = 0;
    }
    
    return numberOfItems;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"collectionStartCell";
    STStartTableCellCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.titleLabel.attributedText = [Utils text:((STStartModel*)self.dataForItemsTable[indexPath.row]).title withSpacing:2 lineBreakMode:NSLineBreakByWordWrapping];
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *categoryLabelFont = [settings customFontForKey:@"startscreen.collectionview.cell.font"];
    UIFont *titleLabelFont = [settings customFontForKey:@"startscreen.tablecellcollectionviewcell.cell.font"];
    
    if (titleLabelFont) {
        cell.titleLabel.font = titleLabelFont;
    }
    
    if (categoryLabelFont) {
        self.categoryLabel.font = categoryLabelFont;
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds), 50.0f);
}

#pragma mark - UICollectionView delegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    //go to items detail screen
    if ([self.startCellCollectionDelegate respondsToSelector:@selector(showDetailScreenForItem:)]) {
        [self.startCellCollectionDelegate showDetailScreenForItem:(STStartModel*)self.dataForItemsTable[indexPath.row]];
    }
}

-(void)showOverview:(id)sender {
    //call delegate method
    [self.startCellCollectionDelegate showOverviewForIndex:((UIButton*)sender).tag andCellType:1];
}

#pragma mark - UIScrollView delegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //pass current page index to page control inside cell
    CGFloat pageWidth = self.categoryItemsCollection.frame.size.width;
    self.itemScrollPageControl.currentIndicator = self.categoryItemsCollection.contentOffset.x / pageWidth;
}

@end

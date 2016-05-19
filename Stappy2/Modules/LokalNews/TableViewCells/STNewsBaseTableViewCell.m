//
//  STNewsBaseTableViewCell.m
//  Stappy2
//
//  Created by Cynthia Codrea on 13/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STNewsBaseTableViewCell.h"
#import "STNewsTableCellCollectionViewCell.h"
#import "STNewsModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "STTableSecondaryKeyObject.h"
#import "STNewsTableCollectionExpandedHeader.h"
#import "STNewsTableCollectionExpandedFooter.h"
#import "STRequestsHandler.h"
#import "STWebViewDetailViewController.h"
#import "STAppSettingsManager.h"
#import "Utils.h"
#import "STEventsModel.h"
#import "Indicators.h"

static NSString* kNewsTableCollectionCellID = @"STNewsTableCellCollectionViewCell";
static NSString* kNewsTableCollectionExpandedCellID = @"collectionInsideNewsExpandedCell";
static NSString* kSectionHeaderViewID = @"sectionCollectionHeaderItemId";
static NSString* kSectionFooterViewID = @"sectionCollectionFooterItemId";

@implementation STNewsBaseTableViewCell

-(void)setExpanded:(BOOL)expanded {
    _expanded = expanded;
    self.backgroundBottomContraint.constant = expanded ? 0 : 8;
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    if (self) {
        [self.newsCellCollectionView registerNib:[UINib nibWithNibName:@"STNewsTableCellCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:kNewsTableCollectionCellID];
        [self.newsCellCollectionView registerNib:[UINib nibWithNibName:@"STNewsTableCellCollectionExpanded" bundle:nil] forCellWithReuseIdentifier:kNewsTableCollectionExpandedCellID];
        
        [self.newsCellCollectionView registerClass:[STNewsTableCollectionExpandedHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSectionHeaderViewID];
        
        [self.newsCellCollectionView registerClass:[STNewsTableCollectionExpandedFooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kSectionFooterViewID];
        
        self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap)];
        self.doubleTap.numberOfTapsRequired = 2;
        self.doubleTap.delaysTouchesBegan = YES;
        [self.contentView addGestureRecognizer:self.doubleTap];
    }
    
    [self initStadtwerkLayout];
}

-(void)initStadtwerkLayout
{
    //Font
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *categoryNameLabelFont = [settings customFontForKey:@"news.base_cell.category.font"];
    UIColor *categoryNameLabelColor = [settings customColorForKey:@"news.base_cell.category.color"];
    
    if (categoryNameLabelFont) {
        [self.categoryNameLabel setFont:categoryNameLabelFont];
    }
    if (categoryNameLabelColor) {
        [self.categoryNameLabel setTextColor:categoryNameLabelColor];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)updateCellWithDataObject:(STTableSecondaryKeyObject*)secondaryKeyObject {
    
    self.collectionDataSourceNewsArray = secondaryKeyObject.secondaryKeyArray;
    STNewsModel *newsModel = self.collectionDataSourceNewsArray.firstObject;
    self.categoryNameLabel.text = [newsModel.secondaryKey uppercaseString];
    self.pageControl.hidden = self.collectionDataSourceNewsArray.count == 1;

    if (![newsModel isKindOfClass:[STEventsModel class]]) {
        self.eventCategoryWidthConstraint.constant = 0;
    }
    else {
        self.eventCategoryImage.image = [UIImage imageNamed: [[Utils replaceSpecialCharactersFrom: newsModel.secondaryKey] lowercaseString]];
    }
    
    [self.newsCellCollectionView reloadData];
    self.pageControl.totalNumberOfPages = secondaryKeyObject.secondaryKeyArray.count;
    self.pageControl.currentIndicator = 0;
}

#pragma mark - cell delegate methods

-(void)onDoubleTap {
    [self.delegate onDoubleTap:self];
}

#pragma mark - UICollectionView data source

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.collectionDataSourceNewsArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    STNewsTableCellCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kNewsTableCollectionCellID forIndexPath:indexPath];
    
    STNewsModel *newsModel = self.collectionDataSourceNewsArray[indexPath.row];
    
    cell.descriptionLabel.attributedText = [Utils text:newsModel.title withSpacing:4];
    cell.timeLabel.text = [[newsModel.dateToShow componentsSeparatedByString:@" "] componentsJoinedByString:@"  ·  "];
    
    NSString* imageStringUrl;
    if ([newsModel.image hasPrefix:@"/"]) {
        imageStringUrl = [[STAppSettingsManager sharedSettingsManager].baseUrl stringByAppendingString:newsModel.image];
    }
    else {
        imageStringUrl = newsModel.image;
    }
    NSURL *imageUrl = [NSURL URLWithString:imageStringUrl];
    [cell.dataImgeView sd_setImageWithURL:imageUrl  placeholderImage:[UIImage imageNamed:@"image_content_article_default_thumb"]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    STMainModel* itemDetails = ((STMainModel*)self.collectionDataSourceNewsArray[indexPath.row]);
    [self.delegate onTap:itemDetails];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 16, 119.0f);
}

#pragma mark - UIScrollView delegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //pass current page index to page control inside cell
    CGFloat pageWidth = self.newsCellCollectionView.frame.size.width;
    self.pageControl.currentIndicator = ((NSInteger)(self.newsCellCollectionView.contentOffset.x / pageWidth));
}

@end

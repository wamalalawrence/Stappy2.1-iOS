//
//  STNewsBaseTableViewCell.h
//  Stappy2
//
//  Created by Cynthia Codrea on 13/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STTableSecondaryKeyObject;
@class STNewsModel;
@class STMainModel;
@class Indicators;

static NSString *CollectionViewCellIdentifier = @"CollectionViewCellIdentifier";

@class STNewsBaseTableViewCell;

@protocol STNewsBaseTableViewCellDelegate <NSObject>
@required
-(void)onTap:(STMainModel *)detailData;
-(void)onDoubleTap:(STNewsBaseTableViewCell *)sender;
@end

@interface STNewsBaseTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *eventCategoryWidthConstraint;

@property (weak, nonatomic) IBOutlet Indicators *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *newsCellCollectionView;
@property(nonatomic,strong)NSArray *collectionDataSourceNewsArray;
@property(nonatomic,strong)UITapGestureRecognizer *doubleTap;
@property(nonatomic,strong)UITapGestureRecognizer *tap;

@property (nonatomic, assign) id<STNewsBaseTableViewCellDelegate> delegate;
@property (nonatomic, assign, getter=isExpanded) BOOL expanded;
@property (weak, nonatomic) IBOutlet UIImageView *eventCategoryImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundBottomContraint;

-(void)updateCellWithDataObject:(STTableSecondaryKeyObject*)secondaryKeyObject;

@end

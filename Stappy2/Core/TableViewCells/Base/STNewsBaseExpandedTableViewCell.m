//
//  STNewsBaseExpandedTableViewCell.m
//  Stappy2
//
//  Created by Cynthia Codrea on 01/12/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STNewsBaseExpandedTableViewCell.h"
#import "STNewsTableCellCollectionViewCell.h"
#import "STMainModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "STNewsTableCollectionExpandedHeader.h"
#import "STNewsTableCollectionExpandedFooter.h"
#import "ExpandedBottomTableViewCell.h"
#import "STAppSettingsManager.h"

static NSString* kNewsTableCollectionCellID = @"STNewsTableCellCollectionViewCell";
static NSString* kNewsTableCollectionExpandedCellID = @"collectionInsideNewsExpandedCell";
static NSString* kNewsTableCollectionExpandedFooterCellID = @"collectionInsideNewsExpandedFooterCell";
static NSString* kSectionHeaderViewID = @"sectionCollectionHeaderItemId";
static NSString* kSectionFooterViewID = @"sectionCollectionFooterItemId";
static NSString* kNewsTableBottomCollectionExpandedCellID = @"ExpandedBottomTableViewCell";

@implementation STNewsBaseExpandedTableViewCell

-(void)awakeFromNib {
    [super awakeFromNib];
    
    [self initStadtwerkLayout];
}

-(void)initStadtwerkLayout
{
    //Font
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *fontDatetime = [settings customFontForKey:@"news.base_cell_expanded.datetime.font"];
    UIFont *fontDescription = [settings customFontForKey:@"news.base_cell_expanded.description.font"];
    UIColor *datetimeColor = [settings customColorForKey:@"news.base_cell_expanded.datetime.color"];
    
    if (fontDescription) {
        [self.descriptionLabel setFont:fontDescription];
    }
    if (fontDatetime) {
        [self.timeLabel setFont:fontDatetime];
    }
    if (datetimeColor) {
        [self.timeLabel setTextColor:datetimeColor];
    }
}
#pragma mark - UICollection view data source

//override some of the collection view data source methods for customization


@end

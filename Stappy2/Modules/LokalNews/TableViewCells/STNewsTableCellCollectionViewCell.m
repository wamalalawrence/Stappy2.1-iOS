//
//  STNewsTableCellCollectionViewCell.m
//  Stappy2
//
//  Created by Cynthia Codrea on 13/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STNewsTableCellCollectionViewCell.h"
#import "STAppSettingsManager.h"

@implementation STNewsTableCellCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    [self initStadtwerkLayout];
}


-(void)initStadtwerkLayout
{
    //Font
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *fontDatetime = [settings customFontForKey:@"news.collection_view_cell.datetime.font"];
    UIFont *fontDescription = [settings customFontForKey:@"news.collection_view_cell.description.font"];
    UIColor *datetimeColor = [settings customColorForKey:@"news.collection_view_cell.datetime.color"];
    
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


@end

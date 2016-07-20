//
//  XMLListTableViewCell.m
//  Stappy2
//
//  Created by Pavel Nemecek on 26/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STReportListTableViewCell.h"
#import "STReportListModel.h"
#import "STAppSettingsManager.h"
@implementation STReportListTableViewCell

-(void)setupWithReportListModel:(STReportListModel*)reportListModel
{

    self.titleLabel.text = reportListModel.title;
    self.descriptionLabel.text = reportListModel.descriptionString;
    
    NSDateFormatter*dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd. MM. yyyy";
  
    self.dateLabel.text = [dateFormatter stringFromDate:reportListModel.publishDate];

}


- (void)awakeFromNib {
    [super awakeFromNib];

    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *dateFont = [settings customFontForKey:@"xmlfeed.datetime.font"];
    UIFont *descriptionFont = [settings customFontForKey:@"xmlfeed.description.font"];
    UIFont *titleFont = [settings customFontForKey:@"xmlfeed.title.font"];

    if (dateFont) {
        self.dateLabel.font = dateFont;
    }
    
    if (descriptionFont) {
        self.descriptionLabel.font = descriptionFont;
        self.titleLabel.font = descriptionFont;
    }
    if (titleFont) {
        self.titleLabel.font = titleFont;
    }


}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

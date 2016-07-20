//
//  XMLListTableViewCell.m
//  Stappy2
//
//  Created by Pavel Nemecek on 26/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STXMLListTableViewCell.h"
#import "STXMLFeedModel.h"
#import "STAppSettingsManager.h"
@implementation STXMLListTableViewCell

-(void)setupWithFeedModel:(STXMLFeedModel*)feedModel{

    self.titleLabel.text = feedModel.title;
    self.descriptionLabel.text = feedModel.descriptionString;
    
    NSDateFormatter*dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd. MM. yyyy";
  
    self.dateLabel.text = [dateFormatter stringFromDate:feedModel.publishDate];

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

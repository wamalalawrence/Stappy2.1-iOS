//
//  STReportTypeTableViewCell.m
//  Stappy2
//
//  Created by Pavel Nemecek on 10/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STReportTypeTableViewCell.h"
#import "STAppSettingsManager.h"
@implementation STReportTypeTableViewCell

-(void)setupWithReportType:(STReportType*)reportType{
    self.nameLabel.text = reportType.name;
 }

- (void)awakeFromNib {
    [super awakeFromNib];
    UIFont *cellFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"reporter.cellText.font"];
    if (cellFont) {
        self.nameLabel.font = cellFont;
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        self.selectionIcon.image = [UIImage imageNamed:@"icon_tick_active"];
    }
    else{
        self.selectionIcon.image = [UIImage imageNamed:@"icon_tick"];
    }
}

@end

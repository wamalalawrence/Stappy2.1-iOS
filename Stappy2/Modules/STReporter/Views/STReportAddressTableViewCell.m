//
//  STReportAddressTableViewCell.m
//  Stappy2
//
//  Created by Pavel Nemecek on 10/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STReportAddressTableViewCell.h"
#import "STAppSettingsManager.h"
@implementation STReportAddressTableViewCell

-(void)setupWithPrediction:(STPrediction*)predition{
    self.addressLabel.text = predition.descriptionField;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UIFont *cellFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"reporter.cellText.font"];
    
    if (cellFont) {
        self.addressLabel.font = cellFont;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

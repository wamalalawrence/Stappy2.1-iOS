//
//  STRegionPickerSearchTableViewCell.m
//  EndiosRegionPicker
//
//  Created by Thorsten Binnewies on 20.04.16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STRegionPickerSearchTableViewCell.h"
#import "STAppSettingsManager.h"

#define kRegionPickerCellFont [UIFont fontWithName:@"RWEHeadline-RegularCondensed" size:15]


@implementation STRegionPickerSearchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

    self.titleTextLabel.font =kRegionPickerCellFont;
    self.shortTextLabel.font = kRegionPickerCellFont;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

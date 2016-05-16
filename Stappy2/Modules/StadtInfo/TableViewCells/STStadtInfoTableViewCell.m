//
//  STStadtInfoTableViewCell.m
//  Stappy2
//
//  Created by Cynthia Codrea on 25/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STStadtInfoTableViewCell.h"
#import "STAppSettingsManager.h"
#import "UIColor+STColor.h"

@implementation STStadtInfoTableViewCell

- (void)awakeFromNib {
    // Initialization code

    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *tileFont = [settings customFontForKey:@"stadtinfos.cell.font"];
    UIFont *headerFont = [settings customFontForKey:@"stadtinfos.cell.headerFont"];
    if (tileFont) [self.title setFont:tileFont];
    if (headerFont) {
        [self.openingTime setFont:headerFont];
    }
    [self.openingTime setTextColor:[UIColor partnerColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  SideMenuTableViewCell.m
//  Stappy2
//
//  Created by Andrei Neag on 11/17/15.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "SideMenuTableViewCell.h"
#import "Utils.h"
#import "UIColor+STColor.h"

@implementation SideMenuTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.firstSideTableCell = true;
    self.showIconBackground = true;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.selectionIndicator.backgroundColor = [UIColor partnerColor];
    self.separatorLeadingConstraint.constant = 0;
    // Configure the view for the selected state
    self.selectionIndicator.hidden = !selected;
    if (self.firstSideTableCell) {
        self.iconBackground.hidden = !selected;
    } else {
        if (self.showIconBackground) {
            self.iconBackground.hidden = selected;
            self.separatorLeadingConstraint.constant = 50;
        } else {
            self.iconBackground.hidden = true;
        }
    }
    if (self.shouldHaveDarkBackground) {
        self.backgroundColor = selected ? [UIColor clearColor] : [Utils leftMenuDarkBakground];
        self.separatorLeadingConstraint.constant = 50;
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

@end

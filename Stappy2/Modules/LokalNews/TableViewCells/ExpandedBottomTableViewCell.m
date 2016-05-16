//
//  ExpandedBottomTableViewCell.m
//  Stappy2
//
//  Created by Andrei Neag on 12/18/15.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "ExpandedBottomTableViewCell.h"
#import "STAppSettingsManager.h"
#import "Utils.h"

@implementation ExpandedBottomTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.collapseButton.layer.borderColor = [UIColor whiteColor].CGColor;
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];

    UIFont *buttonFont = [settings customFontForKey:@"news.cell_collection_expanded_footer.font"];
    if (buttonFont) [self.collapseButton.titleLabel setFont:buttonFont];

    self.collapseButton.layer.borderColor = [UIColor whiteColor].CGColor;
}


@end

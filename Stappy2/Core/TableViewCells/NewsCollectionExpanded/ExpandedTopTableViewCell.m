//
//  ExpandedTopTableViewCell.m
//  Stappy2
//
//  Created by Andrei Neag on 12/18/15.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "ExpandedTopTableViewCell.h"
#import "STAppSettingsManager.h"

@implementation ExpandedTopTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    UIFont *overviewLabelFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"news.cell_expanded_top.font"];
    if (overviewLabelFont) [self.overviewLabel setFont:overviewLabelFont];;
}

@end

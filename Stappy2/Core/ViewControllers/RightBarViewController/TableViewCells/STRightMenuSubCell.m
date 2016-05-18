//
//  STRightMenuSubCell.m
//  Stappy2
//
//  Created by Cynthia Codrea on 14/03/2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STRightMenuSubCell.h"
#import "STAppSettingsManager.h"
@implementation STRightMenuSubCell

- (void)awakeFromNib {
    // Initialization code
    
      UIFont *meineStadtwerkeFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"rightmenu.subcell.font"];
    
    if (meineStadtwerkeFont) {
        self.subCellText.font =meineStadtwerkeFont;
 
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

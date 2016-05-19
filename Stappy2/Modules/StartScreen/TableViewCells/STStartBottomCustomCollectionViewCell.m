//
//  STStartBottomCustomCollectionViewCell.m
//  Stappy2
//
//  Created by Cynthia Codrea on 19/04/2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STStartBottomCustomCollectionViewCell.h"
#import "STAppSettingsManager.h"
@implementation STStartBottomCustomCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
  
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];

    UIFont *categoryLabelFont = [settings customFontForKey:@"startscreen.collectionview.cell.font"];
    
        if (categoryLabelFont) {
        self.actionName.font = categoryLabelFont;
    }

}

@end

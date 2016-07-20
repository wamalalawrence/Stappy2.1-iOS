//
//  SearchTopTableViewCell.m
//  Schwedt
//
//  Created by Andrei Neag on 12.02.2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "SearchTopTableViewCell.h"
#import "STAppSettingsManager.h"
@implementation SearchTopTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.searchBar.layer.cornerRadius  = 6;
    self.searchBar.clipsToBounds       = YES;
    [self.searchBar.layer setBorderWidth:1.0];
    [self.searchBar.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    STAppSettingsManager*manager = [STAppSettingsManager sharedSettingsManager];
    UIFont*customFont = [manager customFontForKey:@"detailscreen.description.font"];
    
    UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
    UIButton *cancelButton = [self.searchBar valueForKey:@"_cancelButton"];
    if (customFont) {
        cancelButton.titleLabel.font = customFont;
        searchField.font = customFont;
    }
    
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    searchField.textColor = [UIColor whiteColor];
    searchField.tintColor = [UIColor whiteColor];
    [searchField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.searchBar setImage:[UIImage imageNamed:@"icon_menu_left_top_suche1"]
       forSearchBarIcon:UISearchBarIconSearch
                  state:UIControlStateNormal];
     }

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

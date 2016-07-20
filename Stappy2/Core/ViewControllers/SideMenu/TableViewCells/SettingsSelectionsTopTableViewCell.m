//
//  SettingsSelectionsTopTableViewCell.m
//  Schwedt
//
//  Created by Andrei Neag on 10.02.2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "SettingsSelectionsTopTableViewCell.h"
#import "STAppSettingsManager.h"

@implementation SettingsSelectionsTopTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    [self initLayout];
    [self.contentView.superview setClipsToBounds:YES];
}

- (void)initLayout
{
    UIFont *selectionsTitleLabelFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"sidemenu.settings_top_cell.font"];
    if (selectionsTitleLabelFont) [self.selectionsTitleLabel setFont:selectionsTitleLabelFont];
}

- (IBAction)backButtonPressed:(id)sender
{
    [self.delegate backButtonPressedOnTableViewCell:self];
}

#pragma mark - Back Button

- (void)showBackButton:(BOOL)shouldShow
{
    self.backButton.hidden = !shouldShow;
    
    if (shouldShow)
    {
        _backButtonLeadingContraint.constant = 5;
        _menuItemLabelLeadingContraint.constant = 30;
    }
    else
    {
        _backButtonLeadingContraint.constant = 30;
        _menuItemLabelLeadingContraint.constant = 0;
    }
    
    [self.contentView layoutIfNeeded];
}

@end

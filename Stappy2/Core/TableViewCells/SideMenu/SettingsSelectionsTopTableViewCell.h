//
//  SettingsSelectionsTopTableViewCell.h
//  Schwedt
//
//  Created by Andrei Neag on 10.02.2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingsSelectionsTopTableViewCell;

@protocol SettingsSelectionsTopTableViewCellDelegate
- (void)backButtonPressedOnTableViewCell:(SettingsSelectionsTopTableViewCell *)cell;
@end

@interface SettingsSelectionsTopTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *selectionsTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backButtonLeadingContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuItemLabelLeadingContraint;
@property (weak, nonatomic) id<SettingsSelectionsTopTableViewCellDelegate> delegate;

- (IBAction)backButtonPressed:(id)sender;
- (void)showBackButton:(BOOL)shouldShow;
@end

//
//  SidebarViewController+Settings.m
//  Schwedt
//
//  Created by Andrei Neag on 15.01.2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "SidebarViewController+Settings.h"
#import "Defines.h"
#import "STRequestsHandler.h"
#import "STLeftSideSubSettingsModel.h"
#import "STLeftMenuSettingsModel.h"
#import "SideMenuTableViewCell.h"
#import "SettingsSelectionsTableViewCell.h"
#import "SettingsSelectionsTopTableViewCell.h"
#import "SettingsSelectionsTableViewCell.h"
#import "SettingsSelectionsTopTableViewCell.h"
#import "Utils.h"
#import "Defines.h"
#import "Stappy2-Swift.h"
#import "NSObject+AssociatedObject.h"
#import "STAppSettingsManager.h"
#import "STRegionPickerViewController.h"
#import "UIColor+STColor.h"
@implementation SidebarViewController (Settings)

// Provide specific functionality that will be used ONLY for Settings section of the left menu.

- (IBAction)settingsButtonPressed:(UIButton *)sender {
    if (self.menuState == settingsState) {
        return;
    }
    
    [self hideSecondMenuItems];
    [self resetTopButtons];
    sender.selected = true;
    self.menuState = settingsState;
    if (self.settingsSideMenuItems.count == 0) {
        [self getSettingsMenuFromServer];
    } else {
        [self.firstsideMenuTable reloadData];
        [self selectSettingsCellAtRow:1];
    }
    self.secondMenuTopView.hidden = true;
    self.secondTableTopConstraint.constant = 0;
    self.thirdTableTopConstraint.constant = 0;
}

- (void)selectSettingsCellAtRow:(NSInteger)row
{
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.firstsideMenuTable selectRowAtIndexPath:firstIndexPath
                                         animated:YES
                                   scrollPosition:UITableViewScrollPositionNone];
    [self settingsItemSelectedAtIndexPath:firstIndexPath forTableView:self.firstsideMenuTable];
}

- (NSUInteger)getSettingsNumberOfRowsInSection:(NSUInteger)section {
    return [self.settingsSideMenuItems count];
}

#pragma Mark - Private Methods 

- (void)getSettingsMenuFromServer {
    NSString* settingsUrl = [STAppSettingsManager sharedSettingsManager].baseSettingsUrl;
    [[STRequestsHandler sharedInstance] settingsOptionsFromUrl:settingsUrl andCompletion:^(NSArray *settingsArray, NSError *error) {
        if (!error) {
            NSMutableArray *mutableSettings = [NSMutableArray array];
            BOOL hasRegionPicker = [STAppSettingsManager sharedSettingsManager].shouldDisplayRegionPicker;
            // Load the same icons to the settings options as for menu options.
            for (STLeftMenuSettingsModel *leftMenuItem in self.leftMenuItems) {
                for (STLeftMenuSettingsModel *settingsModel in settingsArray) {
                    if ([leftMenuItem.title caseInsensitiveCompare:settingsModel.type] == NSOrderedSame ||
                        [leftMenuItem.type caseInsensitiveCompare:settingsModel.type]  == NSOrderedSame ) {
    
                            settingsModel.iconName = leftMenuItem.iconName;
                            // Saving the original title in type.
                            settingsModel.title = leftMenuItem.title;
                        [mutableSettings addObject:settingsModel];
                        break;
                    }
                }
            }
          
            //Add items that are not found on the left menu
            for (STLeftMenuSettingsModel *settingsModel in settingsArray) {
                if ([settingsModel.type isEqualToString:@"regionen"] && !hasRegionPicker) {
                    settingsModel.iconName = @"regionen";
                    settingsModel.title = @"REGIONEN";
                    [mutableSettings insertObject:settingsModel atIndex:mutableSettings.count];

                }
            }
            
            // Add the close button for the first cell.
            STLeftMenuSettingsModel *closeSettings = [[STLeftMenuSettingsModel alloc] init];
            closeSettings.title = @"Close";
            closeSettings.iconName = @"close";
            [mutableSettings insertObject:closeSettings atIndex:0];
            
            // Add region button if found
            if (hasRegionPicker) {
                STLeftMenuSettingsModel *regionSettings = [[STLeftMenuSettingsModel alloc] init];
                regionSettings.title = @"Regionen";
                regionSettings.iconName = @"regionen";
                NSUInteger lastIndex = mutableSettings.count;
                [mutableSettings insertObject:regionSettings atIndex:lastIndex];
            }
            
            // Add coupons if needed
            if ([[STAppSettingsManager sharedSettingsManager] showCoupons]) {
                STLeftMenuSettingsModel *couponsSettings = [[STLeftMenuSettingsModel alloc] init];
                couponsSettings.title = [[STAppSettingsManager sharedSettingsManager] couponsSettingsTitle];
                couponsSettings.iconName = @"cupons";
                NSUInteger lastIndex = mutableSettings.count;
                [mutableSettings insertObject:couponsSettings atIndex:lastIndex];
            }
            self.settingsSideMenuItems = mutableSettings;
            [self.firstsideMenuTable reloadData];
        } else {
            [self.firstsideMenuTable reloadData];
        }
        
        if ([self.firstsideMenuTable numberOfRowsInSection:0] > 0) [self selectSettingsCellAtRow:1];
    }];
}

- (void)settingsItemSelectedAtIndexPath:(NSIndexPath*)indexPath forTableView:(UITableView *)tableView {
    switch (tableView.tag)
    {
        case 1002:
            // Second table cell
            if (indexPath.row != 0)
            {

                SettingsSelectionsTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                STLeftSideSubSettingsModel *elementSelected = cell.menuSubSettingsModel;

                if (elementSelected.subItems.count == 0) [cell switcherTapped];
                else
                {
                    self.thirdSideMenuItems = [NSMutableArray arrayWithArray:elementSelected.subItems];
                    [self.thirdSideMenuItems insertObject:elementSelected atIndex:0];
                    [self showThirdSettingsTableView];
                }
            }
            break;
        case 1003:
            // Third table cell
            if (indexPath.row != 0)
            {
                SettingsSelectionsTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                [cell switcherTapped];
            }
            break;
        default:
           // First table
            if (indexPath.row == 0) {
                [self resetLeftMenuInitialState];
                [[Filters sharedInstance] saveFilters];
            } else {
                /*
                 * In order to save/delete the filters, we need to know to which type/category they belong.
                 * @see Filters
                 */
                SideMenuTableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
                self.associatedObject = [selectedCell.menuItemLabel.text lowercaseString];
                BOOL hasRegionPicker = [STAppSettingsManager sharedSettingsManager].shouldDisplayRegionPicker;
                if ([selectedCell.menuItemLabel.text isEqualToString:@"Regionen"] && hasRegionPicker) {
                    //present region picker controller
                    STRegionPickerViewController *vc = [[STRegionPickerViewController alloc] initWithNibName:@"STRegionPickerViewController" bundle:nil];
                    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
                    vc.currentState = PickerStateSelect;
                    nvc.navigationBar.barTintColor =[UIColor partnerColor];
                    nvc.navigationBar.tintColor = [UIColor partnerColor];
                    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
                    UIFont *navigationbarTitleFont = [settings customFontForKey:@"navigationbar.title.font"];
                    
                    //For iOS8+
                    [nvc.navigationBar setTitleTextAttributes:@{ NSFontAttributeName: navigationbarTitleFont,NSForegroundColorAttributeName: [UIColor whiteColor]}];

                    nvc.navigationBar.translucent = YES;
                    nvc.navigationBar.barStyle = UIBarStyleDefault;
                    nvc.modalPresentationStyle = UIModalPresentationFullScreen;
                    nvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                    [self presentViewController:nvc animated:YES completion:nil];
                }
                if ([[STAppSettingsManager sharedSettingsManager] showCoupons]) {
                    self.couponsTitleLabel.text = [[STAppSettingsManager sharedSettingsManager] couponsSettingsTitle];
                    if ([selectedCell.menuItemLabel.text isEqualToString:self.couponsTitleLabel.text]) {
                        self.secondSideMenuTable.hidden = true;
                        self.couponsView.hidden = false;
                    } else {
                        self.secondSideMenuTable.hidden = false;
                        self.couponsView.hidden = true;
                    }
                }

                [self selectFirstMenuItemAtIndexPath:indexPath];
            }
            break;
    }

}

- (UITableViewCell *)settingsTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    NSArray *sideMenuItems;
    BOOL showBackButton = NO;

    switch (tableView.tag)
    {
        case 1002:
            // Second table cell
            sideMenuItems = self.secondSideMenuItems;
            showBackButton = NO;
        case 1003:
            // Third table cell
            if (sideMenuItems == nil)
            {
                sideMenuItems = self.thirdSideMenuItems;
                showBackButton = YES;
            }

            if (indexPath.row == 0)
            {
                SettingsSelectionsTopTableViewCell *topTableCell = [tableView dequeueReusableCellWithIdentifier:kSettingsSelectionsTopTableViewCellIdentifier];
                STLeftMenuSettingsModel *leftTopModel = [sideMenuItems firstObject];
                topTableCell.selectionsTitleLabel.text = [leftTopModel.title uppercaseString];
                topTableCell.delegate = self;
                topTableCell.selectionStyle = UITableViewCellSelectionStyleNone;

                [topTableCell showBackButton:showBackButton];
                
                cell = topTableCell;
            }
            else
            {
                SettingsSelectionsTableViewCell *selectionCell = [tableView dequeueReusableCellWithIdentifier:kSettingsSelectionsTableViewCellIdentifier];
                STLeftSideSubSettingsModel *selectableModel = [sideMenuItems objectAtIndex:indexPath.row];
                
                selectableModel.filterType = self.associatedObject;
                
                selectionCell.menuSubSettingsModel = selectableModel;
                selectionCell.titleLabel.text = selectableModel.title;
                selectionCell.delegate = self;
                
                cell = selectionCell;
            }
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)selectFirstMenuItemAtIndexPath:(NSIndexPath *)indexPath {
    STLeftMenuSettingsModel *elementSelected = [self.settingsSideMenuItems objectAtIndex:indexPath.row];
    self.secondSideMenuItems = [NSMutableArray arrayWithArray:elementSelected.subItems];
    [self.secondSideMenuItems insertObject:elementSelected atIndex:0];
    [self showSecondMenuItems];
}

#pragma mark - TableView Animations

- (void)showThirdSettingsTableView
{
    //get data for third menu options
    if (self.thirdMenuOpened) return;
    
    self.thirdMenuOpened = true;
    NSIndexPath *ipath = [self.secondSideMenuTable indexPathForSelectedRow];
    [self.secondSideMenuTable reloadData];
    [self.secondSideMenuTable selectRowAtIndexPath:ipath animated:NO scrollPosition:UITableViewScrollPositionNone];
    self.thirdMenuLeadingConstraint.constant = self.bottomContentView.frame.size.width;
    self.thirdSideMenuTable.hidden = false;
    [self.thirdSideMenuTable reloadData];

    // Start animating the constraints;
    self.thirdMenuLeadingConstraint.constant = kSideMenuOverlapValue;
    self.secondMenuTrailingConstraint.constant = self.bottomContentView.frame.size.width - kSideMenuOverlapValue;
    [UIView animateWithDuration:kSideMenuAnimationDuration
                     animations:^{
                         [self.bottomContentView layoutIfNeeded]; // Called on parent view
                     }];
}

#pragma mark - SettingsSelectionsTableViewCellDelegate

- (void)settingsSelectionsTableViewCell:(SettingsSelectionsTableViewCell *)tableViewCell
                   switcherStateChanged:(SettingsSelectionsState)selectionsState
{
    if (selectionsState == SettingsSelectionsStateSome) return;

    NSArray *filterIds = tableViewCell.menuSubSettingsModel.allModelIds;

    NSError *error;
    switch (selectionsState)
    {
        case SettingsSelectionsStateNone:
        {
            [[Filters sharedInstance] deleteFilterWithFilterIds:filterIds
                                            forStringFilterType:self.associatedObject
                                                          error:&error];
            if (error) { /* how can I handle this error? */ }
        }; break;
        case SettingsSelectionsStateAll:
        {
            [[Filters sharedInstance] saveFilterWithFilterIds:filterIds
                                          forStringFilterType:self.associatedObject
                                                        error:&error];
            if (error) { /* how can I handle this error? */ }
        } break;
        case SettingsSelectionsStateSome: break;
            
        default:
            break;
    }
}

#pragma mark - SettingsSelectionsTopTableViewCellDelegate

- (void)backButtonPressedOnTableViewCell:(UITableViewCell *)tableViewCell
{
    [self hideThirdMenuItems];
}
@end

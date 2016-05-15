//
//  SidebarViewController+Favorite.m
//  Schwedt
//
//  Created by Andrei Neag on 15.01.2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "SidebarViewController+Favorite.h"
#import "SWRevealViewController.h"
#import "STViewControllerNavigationBarStyle.h"
#import "STLeftMenuSettingsModel.h"
#import "StLocalDataArchiever.h"
#import "SettingsSelectionsTopTableViewCell.h"
#import "SearchAndFavoritesTableViewCell.h"
#import "STMainModel.h"
#import "STLeftSideSubSettingsModel.h"
#import "SettingsSelectionsTableViewCell.h"
#import "STNewsAndEventsDetailViewController.h"
#import "STEventsModel.h"
#import "STAngeboteModel.h"
#import "STAppSettingsManager.h"
#import "STViewControllerItem.h"

@implementation SidebarViewController (Favorite)

// Provide specific functionality that will be used ONLY for favorites section of the left menu.

- (IBAction)favoritesButtonPressed:(UIButton *)sender {
    if (self.menuState == favoritesState) {
        return;
    }
    [self hideSecondMenuItems];
    [self resetTopButtons];
    sender.selected = true;
    self.menuState = favoritesState;

    self.favoriteAngebote = [[[StLocalDataArchiever sharedArchieverManager] savedAngebote] count] != 0? [[StLocalDataArchiever sharedArchieverManager] savedAngebote] : [NSArray array];
    
    self.favoriteEvents = [[[StLocalDataArchiever sharedArchieverManager] savedEvents] count] != 0? [[StLocalDataArchiever sharedArchieverManager] savedEvents] : [NSArray array];
    
    self.favoriteStadtInfos = [[[StLocalDataArchiever sharedArchieverManager] savedStadtInfos] count] != 0? [[StLocalDataArchiever sharedArchieverManager] savedStadtInfos] : [NSArray array];
    
    // Set the events menu array
    NSMutableArray *mutableFavMenu = [NSMutableArray array];

    // Add the close button for the first cell.
    STLeftMenuSettingsModel *closeFavorites = [[STLeftMenuSettingsModel alloc] init];
    closeFavorites.title = @"Close";
    closeFavorites.iconName = @"close";
    [mutableFavMenu addObject:closeFavorites];
    
    STLeftMenuSettingsModel *favorites = [[STLeftMenuSettingsModel alloc] init];
    favorites.title = @"Favoriten";
    favorites.iconName = @"icon_content_favorit";
    [mutableFavMenu addObject:favorites];
    
    STLeftMenuSettingsModel *favoriteAngebote = [[STLeftMenuSettingsModel alloc] init];
    favoriteAngebote.title = @"Angebote";
    favoriteAngebote.iconName = @"angebote";
    [mutableFavMenu addObject:favoriteAngebote];
    
    STLeftMenuSettingsModel *favoriteEvents = [[STLeftMenuSettingsModel alloc] init];
    favoriteEvents.title = @"Events";
    favoriteEvents.iconName = @"events";
    [mutableFavMenu addObject:favoriteEvents];
    
    STLeftMenuSettingsModel *favoriteStadtInfos = [[STLeftMenuSettingsModel alloc] init];
    favoriteStadtInfos.title = @"StadtInfos";
    favoriteStadtInfos.iconName = @"stadt";
    [mutableFavMenu addObject:favoriteStadtInfos];
    
    self.favoritesSideMenuItems = mutableFavMenu;
    [self.firstsideMenuTable reloadData];
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self selectFirstFavoriteMenuItemAtIndexPath:firstIndexPath];
    [self.firstsideMenuTable selectRowAtIndexPath:firstIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    [self favoritesItemSelectedAtIndexPath:firstIndexPath forTableView:self.firstsideMenuTable];
    
    self.secondMenuTopView.hidden = true;
    self.secondTableTopConstraint.constant = 0;
    self.thirdTableTopConstraint.constant = 0;
}

- (NSUInteger)getFavoritesNumberOfRowsInSection:(NSUInteger)section {
    return [self.settingsSideMenuItems count];
}

- (void)favoritesItemSelectedAtIndexPath:(NSIndexPath*)indexPath forTableView:(UITableView *)tableView {
    //show detail screen for selected item
    switch (tableView.tag) {
        case 1002:{
            // Second table cell
            // Ignore tap on a cell that does not have a main model object
            STMainModel *mainModel = [self.secondSideMenuItems objectAtIndex:indexPath.row];
            if (![mainModel isKindOfClass:[STMainModel class]]) {
                return;
            }
            STNewsAndEventsDetailViewController * detailView = [[STNewsAndEventsDetailViewController alloc] initWithNibName:@"STNewsAndEventsDetailViewController"
                                                                                                                     bundle:nil
                                                                                                               andDataModel:mainModel];
            NSDictionary *viewControllerItems = [[STAppSettingsManager sharedSettingsManager] viewControllerItems];
            
            STViewControllerItem *viewControllerItem = [viewControllerItems objectForKey:@"Event"];
            
            NSString *controllerId = @"";
            if (viewControllerItem.storyboard_id && ![viewControllerItem.storyboard_id isEqualToString:@""]) {
                controllerId = viewControllerItem.storyboard_id;
            }else if (viewControllerItem.nibname && ![viewControllerItem.nibname isEqualToString:@""]) {
                controllerId = viewControllerItem.nibname;
            }
            UIColor *barTintColor = [UIColor clearColor];
            UIColor *tintColor = [UIColor whiteColor];
            BOOL translucent = YES;
            UIBarStyle barStyle = UIBarStyleBlackTranslucent;
            if (viewControllerItem.navigationBarStyle) {
                STViewControllerNavigationBarStyle *navBarStyle = viewControllerItem.navigationBarStyle;
                
                barTintColor = navBarStyle.barTintColor;
                tintColor = navBarStyle.tintColor;
                translucent = navBarStyle.translucent;
                barStyle = navBarStyle.barStyle;
            }
            [self.sideMenuDelegate loadViewController:detailView animated:YES withNavigationBarBarTintColor:barTintColor andTintColor:tintColor translucent:translucent barStyle:barStyle];
            //[self.sideMenuDelegate loadViewController:newViewController animated:true];
            [self.revealViewController revealToggleAnimated:YES];
            [self resetLeftMenuInitialState];
            }
            break;
        case 1003:
            // Third table cell
            break;
        default:
            // First table
            if (indexPath.row == 0) {
                [self resetLeftMenuInitialState];
            } else {
                switch (indexPath.row) {
                    case 1:{
                        //All
                        self.secondSideMenuItems = [NSMutableArray arrayWithArray:self.favoriteAngebote];
                        [self.secondSideMenuItems addObjectsFromArray:self.favoriteEvents];
                        [self.secondSideMenuItems addObjectsFromArray:self.favoriteStadtInfos];
                        break;
                    }
                    case 2:
                        // Angebote Items
                        self.secondSideMenuItems = [NSMutableArray arrayWithArray:self.favoriteAngebote];
                        break;
                    case 3:
                        // Events Items
                        self.secondSideMenuItems = [NSMutableArray arrayWithArray:self.favoriteEvents];
                        break;
                    case 4:
                        // StadtInfos Items
                        self.secondSideMenuItems = [NSMutableArray arrayWithArray:self.favoriteStadtInfos];
                        break;
                    default:
                        break;
                }
                [self selectFirstFavoriteMenuItemAtIndexPath:indexPath];
            }
            break;
    }
}

- (UITableViewCell *)favoritesTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    
    UIFont *meineStadtwerkeFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"sidemenu.cell.font"];
    
    switch (tableView.tag) {
        case 1002:
            // Second table cell
            if (indexPath.row == 0) {
                SettingsSelectionsTopTableViewCell *topTableCell = [tableView dequeueReusableCellWithIdentifier:kSettingsSelectionsTopTableViewCellIdentifier];
                STLeftMenuSettingsModel *leftTopModel = [self.secondSideMenuItems firstObject];
                topTableCell.selectionsTitleLabel.text = leftTopModel.title;
                topTableCell.selectionsTitleLabel.font = meineStadtwerkeFont;

                cell = topTableCell;
            } else {
                SearchAndFavoritesTableViewCell *selectionCell = [tableView dequeueReusableCellWithIdentifier:kSearchAndFavoritesTableViewCell];
                
                STMainModel *mainModel = [self.secondSideMenuItems objectAtIndex:indexPath.row];
                if ([mainModel isKindOfClass:[STMainModel class]]) {
                    selectionCell.mainModelObject = mainModel;
                    selectionCell.titleLabel.text = mainModel.title;
                    selectionCell.titleLabel.font = meineStadtwerkeFont;
                    selectionCell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                cell = selectionCell;
            }
            break;
        case 1003:
            // Third table cell
            break;
        default:
            
            break;
    }
    
    return cell;
}

- (void)selectFirstFavoriteMenuItemAtIndexPath:(NSIndexPath *)indexPath {
    STLeftMenuSettingsModel *elementSelected = [self.favoritesSideMenuItems objectAtIndex:indexPath.row];
    [self.secondSideMenuItems insertObject:elementSelected atIndex:0];
    [self showSecondMenuItems];
}

@end

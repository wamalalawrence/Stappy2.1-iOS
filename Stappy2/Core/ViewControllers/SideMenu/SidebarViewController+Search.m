//
//  SidebarViewController+Search.m
//  Schwedt
//
//  Created by Andrei Neag on 15.01.2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "SidebarViewController+Search.h"
#import "STLeftMenuSettingsModel.h"
#import "SearchAndFavoritesTableViewCell.h"
#import "SearchTopTableViewCell.h"
#import "STMainModel.h"
#import "STDetailViewController.h"
#import "STViewControllerItem.h"
#import "STAppSettingsManager.h"
#import "STViewControllerNavigationBarStyle.h"
#import "StLocalDataArchiever.h"
#import "SWRevealViewController.h"
#import "STWebViewDetailViewController.h"

@implementation SidebarViewController (Search)

// Provide specific functionality that will be used ONLY for Search section of the left menu.

- (IBAction)searchButtonPressed:(UIButton *)sender {
    if (self.menuState == searchState) {
        return;
    }
    [self hideSecondMenuItems];
    [self resetTopButtons];
    sender.selected = true;
    self.menuState = searchState;
    
    // Set the events menu array
    NSMutableArray *mutableFavMenu = [NSMutableArray array];
    
    // Add the close button for the first cell.
    STLeftMenuSettingsModel *closeSearch = [[STLeftMenuSettingsModel alloc] init];
    closeSearch.title = @"Close";
    closeSearch.iconName = @"close";
    [mutableFavMenu addObject:closeSearch];
    
    STLeftMenuSettingsModel *search = [[STLeftMenuSettingsModel alloc] init];
    search.title = @"Search";
    search.iconName = @"suche_inactive";
    [mutableFavMenu addObject:search];
    
    self.searchSideMenuItems = mutableFavMenu;
    self.secondSideMenuItems = [NSMutableArray arrayWithObject:search];
    
    [self.firstsideMenuTable reloadData];
    [self.secondSideMenuTable reloadData];
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self selectFirstSearchMenuItemAtIndexPath:firstIndexPath];
    [self.firstsideMenuTable selectRowAtIndexPath:firstIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    [self selectFirstSearchMenuItemAtIndexPath:firstIndexPath];
    
    self.secondMenuTopView.hidden = true;
    self.secondTableTopConstraint.constant = 0;
    self.thirdTableTopConstraint.constant = 0;
}

- (void)searchItemSelectedAtIndexPath:(NSIndexPath*)indexPath forTableView:(UITableView *)tableView {
    //show detail screen for selected item
    

    
    switch (tableView.tag) {
        case 1002:{
            // Second table cell
            // Ignore tap on a cell that does not have a main model object
            STMainModel *mainModel = [self.secondSideMenuItems objectAtIndex:indexPath.row];
            if (![mainModel isKindOfClass:[STMainModel class]]) {
                return;
            }
            //check if we show a web view or the overview screen
            NSString* detailUrl = [mainModel valueForKey:@"url"];
            if ([[mainModel valueForKey:@"type"] isEqualToString:@"website"]) {
                //show web view
                STWebViewDetailViewController *webPage = [[STWebViewDetailViewController alloc] initWithNibName:@"STWebViewDetailViewController" bundle:nil andDetailUrl:detailUrl];
                [self.sideMenuDelegate loadViewController:webPage animated:true];
                [self.revealViewController revealToggleAnimated:YES];
                
            }
            else {
                //show overview screen
                STDetailViewController * detailView = [[STDetailViewController alloc] initWithNibName:@"STDetailViewController"
                                                                                                                         bundle:nil
                                                                                                                   andDataModel:mainModel];
                [self.sideMenuDelegate loadViewController:detailView animated:YES];
                [self.revealViewController revealToggleAnimated:YES];
            }

//            STNewsAndEventsDetailViewController * detailView = [[STNewsAndEventsDetailViewController alloc] initWithNibName:@"STNewsAndEventsDetailViewController"
//                                                                                                                     bundle:nil
//                                                                                                               andDataModel:mainModel];
//            NSDictionary *viewControllerItems = [[STAppSettingsManager sharedSettingsManager] viewControllerItems];
//            
//            STViewControllerItem *viewControllerItem = [viewControllerItems objectForKey:@"Event"];
//            
//            NSString *controllerId = @"";
//            if (viewControllerItem.storyboard_id && ![viewControllerItem.storyboard_id isEqualToString:@""]) {
//                controllerId = viewControllerItem.storyboard_id;
//            }else if (viewControllerItem.nibname && ![viewControllerItem.nibname isEqualToString:@""]) {
//                controllerId = viewControllerItem.nibname;
//            }
//            UIColor *barTintColor = [UIColor clearColor];
//            UIColor *tintColor = [UIColor whiteColor];
//            BOOL translucent = YES;
//            UIBarStyle barStyle = UIBarStyleBlackTranslucent;
//            if (viewControllerItem.navigationBarStyle) {
//                STViewControllerNavigationBarStyle *navBarStyle = viewControllerItem.navigationBarStyle;
//                
//                barTintColor = navBarStyle.barTintColor;
//                tintColor = navBarStyle.tintColor;
//                translucent = navBarStyle.translucent;
//                barStyle = navBarStyle.barStyle;
//            }
//            [self.sideMenuDelegate loadViewController:detailView animated:YES withNavigationBarBarTintColor:barTintColor andTintColor:tintColor translucent:translucent barStyle:barStyle];
//            //[self.sideMenuDelegate loadViewController:newViewController animated:true];
//            [self.revealViewController revealToggleAnimated:YES];
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
                [self selectFirstSearchMenuItemAtIndexPath:indexPath];
            }
            break;
    }
}

- (void)selectFirstSearchMenuItemAtIndexPath:(NSIndexPath *)indexPath {
    STLeftMenuSettingsModel *elementSelected = [self.searchSideMenuItems objectAtIndex:indexPath.row];
    self.secondSideMenuItems = [NSMutableArray arrayWithObject:elementSelected];
    [self showSecondMenuItems];
}

- (UITableViewCell *)searchTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    UIFont *meineStadtwerkeFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"sidemenu.cell.font"];

    switch (tableView.tag) {
        case 1002:
            // Second table cell
            if (indexPath.row == 0) {
                SearchTopTableViewCell *topTableCell = [tableView dequeueReusableCellWithIdentifier:kSearchTopTableViewCell];
                topTableCell.searchBar.delegate = self;
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

- (void)resetSearchArray {
    STLeftMenuSettingsModel *searchModel = self.secondSideMenuItems.firstObject;
    NSMutableArray *newItemsArray = [NSMutableArray arrayWithObject:searchModel];
    self.secondSideMenuItems = newItemsArray;
    [self.secondSideMenuTable reloadData];
}

- (void)showSearchResults:(NSArray *)searchResults {
    if (self.menuState == searchState) {
        STLeftMenuSettingsModel *searchModel = self.secondSideMenuItems.firstObject;
        NSMutableArray *newItemsArray = [NSMutableArray arrayWithObject:searchModel];
        [newItemsArray addObjectsFromArray:searchResults];
        self.secondSideMenuItems = newItemsArray;
        [self.secondSideMenuTable reloadData];
    }
}

#pragma mark - Search bar delegate methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchText = searchBar.text;
    if (searchText.length == 0) {
        [self resetSearchArray];
    } else {
        [[StLocalDataArchiever sharedArchieverManager] searchForString:searchText completionHandler:^(NSArray *searchResults) {
            [self showSearchResults:searchResults];
        }];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
//    if (searchText.length == 0) {
//        [self resetSearchArray];
//    } else {
//        [[StLocalDataArchiever sharedArchieverManager] searchForString:searchText completionHandler:^(NSArray *searchResults) {
//            [self showSearchResults:searchResults];
//            [searchBar becomeFirstResponder];
//        }];
//    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self resetSearchArray];
    [searchBar resignFirstResponder];
}

@end

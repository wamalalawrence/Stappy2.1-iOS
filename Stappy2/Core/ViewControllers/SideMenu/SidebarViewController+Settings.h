//
//  SidebarViewController+Settings.h
//  Schwedt
//
//  Created by Andrei Neag on 15.01.2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "SidebarViewController.h"
#import "SettingsSelectionsTableViewCell.h"
#import "SettingsSelectionsTopTableViewCell.h"

@interface SidebarViewController (Settings) <SettingsSelectionsTableViewCellDelegate, SettingsSelectionsTopTableViewCellDelegate>

- (void)getSettingsMenuFromServer;
- (void)settingsItemSelectedAtIndexPath:(NSIndexPath*)indexPath forTableView:(UITableView *)tableView;
- (NSUInteger)getSettingsNumberOfRowsInSection:(NSUInteger)section;
- (UITableViewCell *)settingsTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath ;
@end

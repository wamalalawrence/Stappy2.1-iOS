//
//  SidebarViewController+Search.h
//  Schwedt
//
//  Created by Andrei Neag on 15.01.2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "SidebarViewController.h"

@interface SidebarViewController (Search) <UISearchBarDelegate>

- (void)searchItemSelectedAtIndexPath:(NSIndexPath*)indexPath forTableView:(UITableView *)tableView;
- (UITableViewCell *)searchTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

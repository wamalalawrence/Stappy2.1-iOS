//
//  SidebarViewController+Favorite.h
//  Schwedt
//
//  Created by Andrei Neag on 15.01.2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "SidebarViewController.h"

@interface SidebarViewController (Favorite)

- (void)favoritesItemSelectedAtIndexPath:(NSIndexPath*)indexPath forTableView:(UITableView *)tableView;
- (UITableViewCell *)favoritesTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger)getFavoritesNumberOfRowsInSection:(NSUInteger)section;

@end

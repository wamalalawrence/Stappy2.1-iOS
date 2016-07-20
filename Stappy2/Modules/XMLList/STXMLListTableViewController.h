//
//  XMLListTableViewController.h
//  Stappy2
//
//  Created by Pavel Nemecek on 26/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STXMLListTableViewController : UITableViewController
-(void)setupWithXMLFeedUrl:(NSString*)xmlFeedUrl;
@end

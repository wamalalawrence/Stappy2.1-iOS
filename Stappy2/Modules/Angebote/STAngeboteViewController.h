//
//  STAngeboteViewController.h
//  Stappy2
//
//  Created by Cynthia Codrea on 09/12/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STLokalNewsViewController.h"

static NSString *kAngeboteTableViewHeaderIdentifier = @"STAngeboteHeaderView";

@interface STAngeboteViewController : STLokalNewsViewController
@property (strong, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;

@end

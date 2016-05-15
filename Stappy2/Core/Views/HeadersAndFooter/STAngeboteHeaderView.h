//
//  STAngeboteHeaderView.h
//  Schwedt
//
//  Created by Denis Grebennicov on 09/02/16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STAngeboteHeaderView : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UIView *backgroundContent;

@end

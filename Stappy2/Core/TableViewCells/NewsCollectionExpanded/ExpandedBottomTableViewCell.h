//
//  ExpandedBottomTableViewCell.h
//  Stappy2
//
//  Created by Andrei Neag on 12/18/15.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExpandedBottomTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *collapseButton;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet UIView *bottomContentView;

@end

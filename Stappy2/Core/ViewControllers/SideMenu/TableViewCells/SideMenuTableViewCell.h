//
//  SideMenuTableViewCell.h
//  Stappy2
//
//  Created by Andrei Neag on 11/17/15.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.h"

@class STCategoryModel;

@interface SideMenuTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *selectionIndicator;

@property (weak, nonatomic) IBOutlet UIImageView *menuItemImageView;
@property (weak, nonatomic) IBOutlet UILabel *menuItemLabel;
@property (nonatomic,strong) STCategoryModel* modelData;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftOffset;
@property (weak, nonatomic) IBOutlet UIView *separator;
@property (assign, nonatomic) BOOL shouldHaveDarkBackground;
@property (weak, nonatomic) IBOutlet UIView *iconBackground;
@property (nonatomic, assign) BOOL showIconBackground;
@property (nonatomic, assign) BOOL firstSideTableCell;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorLeadingConstraint;

@end

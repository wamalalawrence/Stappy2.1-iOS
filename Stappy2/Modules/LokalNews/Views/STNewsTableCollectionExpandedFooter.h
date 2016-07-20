//
//  STNewsTableCollectionExpandedFooter.h
//  Stappy2
//
//  Created by Cynthia Codrea on 03/12/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STNewsBaseTableViewCell.h"

@interface STNewsTableCollectionExpandedFooter : UICollectionReusableView <STNewsBaseTableViewCellDelegate>

@property(nonatomic,weak)IBOutlet UIButton *collapseButton;

@end

//
//  STNewsBaseExpandedTableViewCell.h
//  Stappy2
//
//  Created by Cynthia Codrea on 01/12/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STNewsBaseTableViewCell.h"

@interface STNewsBaseExpandedTableViewCell : STNewsBaseTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *dataImgeView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

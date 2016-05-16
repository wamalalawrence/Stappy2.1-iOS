//
//  STStadtInfoTableViewCell.h
//  Stappy2
//
//  Created by Cynthia Codrea on 25/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STStadtInfoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *cityInfoImage;
@property (weak, nonatomic) IBOutlet UILabel *openingTime;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet UIImageView *closingOpeningIcon;

@end

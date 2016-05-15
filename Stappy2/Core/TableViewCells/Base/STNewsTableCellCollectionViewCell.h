//
//  STNewsTableCellCollectionViewCell.h
//  Stappy2
//
//  Created by Cynthia Codrea on 13/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STNewsTableCellCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *dataImgeView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

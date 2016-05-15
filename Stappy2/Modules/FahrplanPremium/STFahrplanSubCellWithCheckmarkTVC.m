//
//  STFahrplanSubCellWithCheckmarkTVC.m
//  Stappy2
//
//  Created by Andrej Albrecht on 14.03.16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STFahrplanSubCellWithCheckmarkTVC.h"

@interface STFahrplanSubCellWithCheckmarkTVC()
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation STFahrplanSubCellWithCheckmarkTVC

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

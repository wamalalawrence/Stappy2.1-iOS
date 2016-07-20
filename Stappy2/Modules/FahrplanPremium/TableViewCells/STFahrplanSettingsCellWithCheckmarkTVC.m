//
//  STFahrplanSettingsCellWithCheckmarkTVC.m
//  Stappy2
//
//  Created by Andrej Albrecht on 10.03.16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STFahrplanSettingsCellWithCheckmarkTVC.h"

@interface STFahrplanSettingsCellWithCheckmarkTVC()
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation STFahrplanSettingsCellWithCheckmarkTVC

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

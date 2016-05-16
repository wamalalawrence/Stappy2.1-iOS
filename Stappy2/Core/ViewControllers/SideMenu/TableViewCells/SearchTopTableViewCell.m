//
//  SearchTopTableViewCell.m
//  Schwedt
//
//  Created by Andrei Neag on 12.02.2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "SearchTopTableViewCell.h"

@implementation SearchTopTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.searchBar.layer.cornerRadius  = 6;
    self.searchBar.clipsToBounds       = YES;
    [self.searchBar.layer setBorderWidth:1.0];
    [self.searchBar.layer setBorderColor:[UIColor whiteColor].CGColor];
        
     }

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

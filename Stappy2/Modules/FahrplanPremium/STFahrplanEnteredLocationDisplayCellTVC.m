//
//  STFahrplanEnteredLocationDisplay.m
//  Stappy2
//
//  Created by Andrej Albrecht on 10.03.16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STFahrplanEnteredLocationDisplayCellTVC.h"

@implementation STFahrplanEnteredLocationDisplayCellTVC

#pragma mark - Lifecycle

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - Actions

- (IBAction)nextActionButton:(id)sender {
    [self.delegate enteredLocationDisplay:self nextAction:sender];
}

- (IBAction)locationAction:(id)sender {
    [self.delegate enteredLocationDisplay:self locationAction:sender];
}

- (IBAction)originAction:(id)sender {
    [self.delegate enteredLocationDisplay:self originAction:sender];
}

- (IBAction)destinationAction:(id)sender {
    [self.delegate enteredLocationDisplay:self destinationAction:sender];
}

@end

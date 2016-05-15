//
//  STOutlineButton.m
//  Stappy2
//
//  Created by Pavel Nemecek on 10/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STOutlineButton.h"

@implementation STOutlineButton

-(void)awakeFromNib{
    self.layer.cornerRadius = 2;
    self.clipsToBounds = YES;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 1.0/[UIScreen mainScreen].scale;
}


@end

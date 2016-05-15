//
//  STRoundedButton.m
//  Stappy2
//
//  Created by Pavel Nemecek on 06/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STRoundedButton.h"

@implementation STRoundedButton

-(void)awakeFromNib{
    self.layer.cornerRadius = CGRectGetWidth(self.frame)/2;
    self.clipsToBounds = YES;
}

@end

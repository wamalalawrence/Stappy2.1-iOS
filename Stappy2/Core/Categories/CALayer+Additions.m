//
//  UILabel+WhiteUIDatePickerLabels.m
//  Stappy2
//
//  Created by Andrej Albrecht on 28.01.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//
#import "CALayer+Additions.h"
#import <QuartzCore/QuartzCore.h>

// Custom borderColor for UIButton
// + user defined runtime attributes
// http://stackoverflow.com/questions/28854469/change-uibutton-bordercolor-in-storyboard


@implementation CALayer (Additions)

- (void)setBorderColorFromUIColor:(UIColor *)color
{
    self.borderColor = color.CGColor;
}

@end
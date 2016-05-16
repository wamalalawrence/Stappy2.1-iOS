//
//  StappyTextField.m
//  Stappy2
//
//  Created by Andrei Neag on 01.04.2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "StappyTextField.h"

@implementation StappyTextField

- (void)drawPlaceholderInRect:(CGRect)rect {
    UIColor *colour = [UIColor lightGrayColor];
    if ([self.placeholder respondsToSelector:@selector(drawInRect:withAttributes:)])
    { // iOS7 and later
        NSDictionary *attributes = @{NSForegroundColorAttributeName: colour, NSFontAttributeName: self.font};
        CGRect boundingRect = [self.placeholder boundingRectWithSize:rect.size options:0 attributes:attributes context:nil];
        [self.placeholder drawAtPoint:CGPointMake(0, (rect.size.height/2)-boundingRect.size.height/2) withAttributes:attributes]; }
    else { // iOS 6
        [colour setFill];
        [self.placeholder drawInRect:rect withFont:self.font lineBreakMode:NSLineBreakByTruncatingTail alignment:self.textAlignment];
    }
}

@end

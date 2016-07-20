//
//  UIImage+tintImageWithColor.m
//  Stappy2
//
//  Created by Denis Grebennicov on 26/01/16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "UIImage+tintImageWithColor.h"

@implementation UIImage (tintImageWithColor)

- (UIImage *)tintImageWithColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end

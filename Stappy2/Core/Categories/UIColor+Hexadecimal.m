//
//  UIColor+Hexadecimal.m
//  Schwedt
//
//  Created by Andrej Albrecht on 10.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "UIColor+Hexadecimal.h"

@implementation UIColor (Hexadecimal)

+ (UIColor *)colorWithHexString:(NSString *)hexString andAlpha:(float)alpha
{
    unsigned long long rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexLongLong:&rgbValue];
    
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString
{
    return [self colorWithHexString:hexString andAlpha:1.0];
}

@end

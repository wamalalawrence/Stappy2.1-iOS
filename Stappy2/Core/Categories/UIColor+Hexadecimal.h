//
//  UIColor+Hexadecimal.h
//  Schwedt
//
//  Created by Andrej Albrecht on 10.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor (Hexadecimal)

+ (UIColor *)colorWithHexString:(NSString *)hexString andAlpha:(float)alpha;
+ (UIColor *)colorWithHexString:(NSString *)hexString;

@end

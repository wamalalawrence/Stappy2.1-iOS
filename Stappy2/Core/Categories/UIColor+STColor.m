//
//  UIColor+STColor.m
//  Schwedt
//
//  Created by Cynthia Codrea on 01/02/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "UIColor+STColor.h"
#import "STAppSettingsManager.h"

@implementation UIColor (STColor)

+(UIColor*) partnerColor {
    
    NSString* tintColor = [[STAppSettingsManager sharedSettingsManager].customizationsDict objectForKey:@"partner_color"];
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:tintColor];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+(UIColor*) startScreenIconColor{

        
        NSString* tintColor = [[STAppSettingsManager sharedSettingsManager].customizationsDict objectForKey:@"startScreenIconColor"];
        unsigned rgbValue = 0;
        NSScanner *scanner = [NSScanner scannerWithString:tintColor];
        [scanner setScanLocation:1]; // bypass '#' character
        [scanner scanHexInt:&rgbValue];
        return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];

}

+(UIColor*) textsColor {
    
    NSString* tintColor = [[STAppSettingsManager sharedSettingsManager].customizationsDict objectForKey:@"texts_color"];
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:tintColor];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+(UIColor*) secondaryColor {
    
    NSString* tintColor = [[STAppSettingsManager sharedSettingsManager].customizationsDict objectForKey:@"secondary_color"];
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:tintColor];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+(UIColor *)transparencyColor {
    UIColor* tranparentColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
    return tranparentColor;
}

+(UIColor *)loadingColor {
    UIColor* loadingColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
    return loadingColor;
}

@end

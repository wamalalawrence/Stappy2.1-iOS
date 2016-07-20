//
//  Utils.m
//  Schwedt
//
//  Created by Andrei Neag on 02.02.2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "Utils.h"
#import "STMainModel.h"
#import "STAppSettingsManager.h"
#import "STLeftSideSubSettingsModel.h"
#import <objc/runtime.h>
#import "STViewControllerItem.h"
#import "Reachability.h"

@implementation Utils

+(NSDictionary*)weekDays {
    NSDictionary *weekDays = [NSDictionary dictionaryWithObjectsAndKeys:@"Montag", @"Monday", @"Dienstag", @"Tuesday", @"Mittwoch", @"Wednesday", @"Donnerstag", @"Thursday", @"Freitag", @"Friday", @"Samstag", @"Saturday", @"Sonntag", @"Sunday", nil];
    return  weekDays;
}

+(UIColor*)leftMenuDarkBakground {
    return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
}

+(NSString*)settingsSavedPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:@"settings.plist"];
}

+(NSString *)filePathForPlist:(NSString *)suffix {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:suffix];
}

+(STMainModel*)searchForMainModel:(STMainModel*)mainModel inModelsArray:(NSArray *)modelsArray {
    STMainModel *modelFound = nil;
    for (STMainModel *model in modelsArray ) {
        if ([model.title isEqualToString:mainModel.title] && ([model.body isEqualToString:mainModel.body] || model.body.length == 0)) {
            modelFound = model;
            break;
        }
    }
    return modelFound;
}

+(BOOL)connected {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

+ (NSMutableAttributedString *)text:(NSString *)text withSpacing:(CGFloat)spacing {
    NSInteger strLength = [text length];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    [style setLineSpacing:spacing];
     style.hyphenationFactor = 1.0f;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSParagraphStyleAttributeName
                             value:style
                             range:NSMakeRange(0, strLength)];
    
    return attributedString;
}

+ (NSMutableAttributedString *)text:(NSString *)text withSpacing:(CGFloat)spacing lineBreakMode:(NSLineBreakMode)linebreakMode {
    NSInteger strLength = [text length];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:linebreakMode];
    [style setLineSpacing:spacing];
    style.hyphenationFactor = 1.0f;

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSParagraphStyleAttributeName
                             value:style
                             range:NSMakeRange(0, strLength)];
    
    return attributedString;
}

+ (NSString *)replaceSpecialCharactersFrom:(NSString*)text {
    return [[[[[[[[[[[[[[text stringByReplacingOccurrencesOfString:@"ö" withString:@"oe"]
                      stringByReplacingOccurrencesOfString:@"Ö" withString:@"Oe"]
                   stringByReplacingOccurrencesOfString:@"ü" withString:@"ue"]
                   stringByReplacingOccurrencesOfString:@"Ü" withString:@"Ue"]
                  stringByReplacingOccurrencesOfString:@"ä" withString:@"ae"]
                stringByReplacingOccurrencesOfString:@"Ä" withString:@"Ae"]
                stringByReplacingOccurrencesOfString:@"ß" withString:@"ss"]
                stringByReplacingOccurrencesOfString:@"&" withString:@""]
               stringByReplacingOccurrencesOfString:@" & " withString:@""]
               stringByReplacingOccurrencesOfString:@" " withString:@""]
              stringByReplacingOccurrencesOfString:@"é" withString:@"e"]
             stringByReplacingOccurrencesOfString:@"," withString:@""]
            stringByReplacingOccurrencesOfString:@"/" withString:@""]
            stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
}

+ (BOOL)string:(NSString *)string equalsToAnyOfTheStringsInArrayOfString:(NSArray<NSString *> *)arrayOfStrings
{
    for (NSString *compareString in arrayOfStrings)
    {
        if ([string isEqualToString:compareString]) return YES;
    }

    return NO;
}


+ (void)swizzleMethodsForOriginalSelector:(SEL)originalSelector withSwizzledMethod:(SEL)swizzledSelector forClass:(Class)class
{
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod)
    {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    }
    else method_exchangeImplementations(originalMethod, swizzledMethod);
}

+ (UIViewController *)loadViewControllerWithTitle:(NSString *)title {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NSDictionary *viewControllerItems = [[STAppSettingsManager sharedSettingsManager] viewControllerItems];
    STViewControllerItem *viewControllerItem = [viewControllerItems objectForKey:title];
    NSString *controllerId = viewControllerItem ? @"" : title;
    if (viewControllerItem.storyboard_id && ![viewControllerItem.storyboard_id isEqualToString:@""]) {
        controllerId = viewControllerItem.storyboard_id;
    }else if (viewControllerItem.nibname && ![viewControllerItem.nibname isEqualToString:@""]) {
        controllerId = viewControllerItem.nibname;
    }
    
    UIViewController * newViewController = nil;
    if (controllerId.length > 0) {
        NSString *errorMessage = nil;
        
        //ViewController from storyboard
        @try {
            newViewController = [sb instantiateViewControllerWithIdentifier:controllerId];
        }
        @catch (NSException *exception) {
            errorMessage = [NSString stringWithFormat:@"Can't load ViewController from storyboard with Identifier(%@). Error:%@", controllerId, [exception description]];
            
            NSLog(@"%@", errorMessage);
            NSLog(@"Trying fallback method. ([[... alloc] initWithNibName:...])");
        }
        //ViewController from xib
        @try {
            if (!newViewController) {
                newViewController = [[NSClassFromString(controllerId) alloc] initWithNibName:controllerId bundle:nil];
            }
        }
        @catch (NSException *exception) {
            errorMessage = [NSString stringWithFormat:@"Can't load ViewController from xib with Class/xib-Name(%@). Error:%@", controllerId, [exception description]];
            NSLog(@"%@", errorMessage);
        }
    }
    if (viewControllerItem) {
        if (![title isEqualToString:@"Strassenlaterne defekt?"]) {
            newViewController.title = title;
        }
    }
    return newViewController;
}

+ (id)sanitize:(id)value withDefault:(id)defaultValue {
    if ((NSNull *)value == [NSNull null] || value == nil) {
        return defaultValue;
    } else {
        return value;
    }
}

// Number of days between two dates
+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

+(BOOL)isCouponCodeValid:(NSString*)couponCode {
    BOOL valid = false;
    if (couponCode.length == 9) {
        if ([couponCode hasPrefix:@"29"] || [couponCode hasPrefix:@"26"] || [couponCode hasPrefix:@"24"]) {
            valid = true;
        }
    } else if (couponCode.length == 8) {
        if ([couponCode hasPrefix:@"530"] || [couponCode hasPrefix:@"540"] || [couponCode hasPrefix:@"535"] || [couponCode hasPrefix:@"537"]) {
            valid = true;
        }
    }
    return valid;
}

@end

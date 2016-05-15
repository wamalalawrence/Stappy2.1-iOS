//
//  Utils.h
//  Schwedt
//
//  Created by Andrei Neag on 02.02.2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class STMainModel;

@interface Utils : NSObject

+(NSDictionary*)weekDays;
+(NSString*)settingsSavedPath;
+(UIColor*)leftMenuDarkBakground;
+(NSString *)filePathForPlist:(NSString *)suffix;
+(STMainModel*)searchForMainModel:(STMainModel*)mainModel inModelsArray:(NSArray *)modelsArray;

+(BOOL)connected;

+ (NSMutableAttributedString *)text:(NSString *)text withSpacing:(CGFloat)spacing;
+ (NSMutableAttributedString *)text:(NSString *)text withSpacing:(CGFloat)spacing lineBreakMode:(NSLineBreakMode)linebreakMode;

+ (NSString *)replaceSpecialCharactersFrom:(NSString*)text;

+ (void)swizzleMethodsForOriginalSelector:(SEL)originalSelector withSwizzledMethod:(SEL)swizzledSelector forClass:(Class)class;

// Loads a new view controller with al the required data from local style files.
+ (UIViewController *)loadViewControllerWithTitle:(NSString *)title;

+ (id)sanitize:(id)value withDefault:(id)defaultValue;

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;

+(BOOL)isCouponCodeValid:(NSString*)couponCode;

@end

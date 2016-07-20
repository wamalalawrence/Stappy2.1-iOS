//
//  UIImage.h
//  Stappy2
//
//  Created by Denis Grebennicov on 07/01/16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (tintImage)
- (UIImage *)imageTintedWithColor:(UIColor *)color;
+ (UIImage *)st_imageWithColor:(UIColor *)color;
@end
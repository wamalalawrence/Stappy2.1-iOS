//
//  STViewControllerNavigationBarStyle.h
//  Schwedt
//
//  Created by Andrej Albrecht on 10.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface STViewControllerNavigationBarStyle : NSObject

@property(nonatomic,strong) UIColor *barTintColor;
@property(nonatomic,strong) UIColor *tintColor;
@property(nonatomic,assign) BOOL translucent;
@property(nonatomic,assign) UIBarStyle barStyle;

@end

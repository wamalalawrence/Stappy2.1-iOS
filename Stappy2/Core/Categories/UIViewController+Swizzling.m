//
//  UIViewController+Swizzling.m
//  Schwedt
//
//  Created by Denis Grebennicov on 12/02/16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "Utils.h"
#import "UIViewController+Swizzling.h"
#import "Stappy2-Swift.h"
#import "STDetailViewController.h"
#import "STWebViewDetailViewController.h"
#import "STAppSettingsManager.h"
#import <Google/Analytics.h>

@implementation UIViewController (Swizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [Utils swizzleMethodsForOriginalSelector:@selector(viewDidLoad) withSwizzledMethod:@selector(ST_viewDidLoad) forClass:[self class]];
        [Utils swizzleMethodsForOriginalSelector:@selector(viewWillAppear:) withSwizzledMethod:@selector(ST_viewWillAppear:) forClass:[self class]];
        [Utils swizzleMethodsForOriginalSelector:@selector(viewDidAppear:) withSwizzledMethod:@selector(ST_viewDidAppear:) forClass:[self class]];

    });
}

#pragma mark - Method Swizzling

- (UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleLightContent; }

/**
 *  Workaround so that the back image will be shown right
 */
- (void)ST_viewDidLoad {
    self.navigationItem.hidesBackButton = YES; // Important
    if (self.navigationItem.leftBarButtonItems.count == 0) {
        NSString *imageName;
        
        if ([self class] == [STDetailViewController class] || [self class] == [STWebViewDetailViewController class]) {
            imageName = @"back_detail";
        } else {
            imageName = @"back";
        }
        
        UIImage *back = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:back style:UIBarButtonItemStylePlain target:self action:@selector(myCustomBack)];
        self.navigationItem.leftBarButtonItem = backButton;
    }
    
    if (![STAppSettingsManager sharedSettingsManager].shouldNotUseUppercase) {
    self.title = [self.title uppercaseString];
    }
    

    
    [self ST_viewDidLoad];
}

- (void)ST_viewWillAppear:(BOOL)animate {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"%@",[self class]]];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    [[GAI sharedInstance] dispatch];
    
}

- (void)ST_viewDidAppear:(BOOL)animate {
    [[OverlayManager sharedInstance] showOverlayScreenIfNeededForViewController:self afterDelay:0.3];
    [self ST_viewDidAppear:animate];
}


-(void)myCustomBack {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
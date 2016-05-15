//
//  STMainViewController.h
//  Stappy2
//
//  Created by Cynthia Codrea on 19/10/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SidebarViewController.h"
#import "RightBarViewController.h"
#import "SWRevealViewController.h"
#import "BTGlassScrollView.h"

@interface STMainViewController : UIViewController <UIScrollViewAccessibilityDelegate, SideMenuViewControllerDelegate, SWRevealViewControllerDelegate, RightMenuViewControllerDelegate, BTGlassScrollViewDelegate>
@property (strong, nonatomic) UITapGestureRecognizer *revealSideView;
@property (strong, nonatomic) UITapGestureRecognizer *revealRight;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;

// SideMenuViewControllerDelegate properties
@property (weak, nonatomic) IBOutlet UIView *detailsContentView;
@property(nonatomic,assign)StartScreenState startScreenState;

@end

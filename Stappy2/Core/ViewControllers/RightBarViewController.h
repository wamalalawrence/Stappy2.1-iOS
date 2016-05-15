//
//  RightBarViewController.h
//  Stappy2
//
//  Created by Cynthia Codrea on 12/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SidebarViewController.h"

@protocol RightMenuViewControllerDelegate <NSObject>

@required
- (UIView*) detailsContentView;
- (void)loadRightViewController:(UIViewController*)viewController animated:(BOOL) animated withNavigationBarBarTintColor:(UIColor*)barTintColor andTintColor:(UIColor*)tintColor translucent:(BOOL)translucent barStyle:(UIBarStyle)barStyle;

@end

@interface RightBarViewController : SidebarViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *stadtwerkLogoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *meineStadtwerkeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopOffset;
// The delegate that is used to send actions from the side menu
@property (weak, nonatomic) IBOutlet id<RightMenuViewControllerDelegate> rightSideMenuDelegate;

@end

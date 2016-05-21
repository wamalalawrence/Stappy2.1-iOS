//
//  SidebarViewController.h
//  Stappy2
//
//  Created by Cynthia Codrea on 19/10/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.h"
#import "RandomImageView.h"
#import "STRegionPickerSettingsView.h"
@class StappyTextField;

@protocol SideMenuViewControllerDelegate <NSObject>

@required
- (UIView*) detailsContentView;
- (void)loadViewController:(UIViewController*)viewController animated:(BOOL) animated withNavigationBarBarTintColor:(UIColor*)barTintColor andTintColor:(UIColor*)tintColor translucent:(BOOL)translucent barStyle:(UIBarStyle)barStyle;
- (void)loadViewController:(UIViewController*)viewController animated:(BOOL) animated;
- (void)showStadtInfoLeftMenu;
- (void)refreshFramesForStartCollectionCells;

@end

@interface SidebarViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *couponsView;
@property (weak, nonatomic) IBOutlet STRegionPickerSettingsView *regionPickerSettingsView;

@property (weak, nonatomic) IBOutlet UIView *topContentView;
@property (weak, nonatomic) IBOutlet UIView *bottomContentView;
@property (weak, nonatomic) IBOutlet UITableView *firstsideMenuTable;
@property (weak, nonatomic) IBOutlet UITableView *secondSideMenuTable;
@property (weak, nonatomic) IBOutlet UITableView *thirdSideMenuTable;
// The delegate that is used to send actions from the side menu
@property (weak, nonatomic) IBOutlet id<SideMenuViewControllerDelegate> sideMenuDelegate;
// Top setings buttons
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *favoritesButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (assign, nonatomic) LeftMenuState menuState;

@property (nonatomic, assign) BOOL secondMenuOpened;
@property (nonatomic, assign) BOOL thirdMenuOpened;

@property (nonatomic, weak) UITableViewCell *parentCell;

// Constraints for animating the open and close of the tables
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstMenuTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondMenuTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondMenuLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thirdMenuLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *secondMenuTopView;
@property (weak, nonatomic) IBOutlet UILabel *secondMenuTopLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondTableTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thirdTableTopConstraint;
@property (weak, nonatomic) IBOutlet RandomImageView *backgroundBlurred;


// Items for different states of the screen.
@property (nonatomic, strong) NSArray *leftMenuItems;

@property (nonatomic, strong) NSArray *settingsSideMenuItems;
@property (nonatomic, strong) NSArray *searchSideMenuItems;
@property (nonatomic, strong) NSArray *favoritesSideMenuItems;

@property (nonatomic, strong) NSArray *favoriteEvents;
@property (nonatomic, strong) NSArray *favoriteAngebote;
@property (nonatomic, strong) NSArray *favoriteStadtInfos;

@property (nonatomic, strong) NSMutableArray *secondSideMenuItems;
@property (nonatomic, strong) NSMutableArray *thirdSideMenuItems;

@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong)NSDictionary* backSubitemDict;
@property (weak, nonatomic) IBOutlet StappyTextField *couponCodeTextField;
@property (weak, nonatomic) IBOutlet UILabel *couponsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponsBodyLabel;

- (IBAction)tapOutsideTextFieldRecognized:(id)sender;

- (NSArray*)menuDataArrayForTableView:(UITableView*)tableView;

#pragma mark - Public methods
-(void)showSecondMenuItems;
-(void)hideSecondMenuItems;
-(void)showThirdMenuItems;
-(void)hideThirdMenuItems;
-(void)resetTopButtons;
-(void)showActivityIndicator;
-(void)hideActivityIndicator;
-(void)mainMenuItemSelectedAtIndexPath:(NSIndexPath*)indexPath forTableView:(UITableView*)tableView;
-(void)resetLeftMenuInitialState;
-(void)autoselectStadtinfo;
-(int)leftSideTablesOffset;

@end

//
//  STMainViewController.m
//  Stappy2
//
//  Created by Cynthia Codrea on 19/10/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STMainViewController.h"
#import "SWRevealViewController.h"
#import "BTGlassScrollView.h"
#import "NSDate+DKHelper.h"
#import "StartViewController.h"
#import "STStartScreenCollectionViewCell.h"
#import "AppDelegate.h"
#import "STAppSettingsManager.h"
#import "STViewControllerItem.h"
#import "STViewControllerNavigationBarStyle.h"
// Thor (The mighty god of Thunder?)
#import "STRegionPickerViewController.h"
//
#import "CouponsCodeViewController.h"

static const int kHeightOfTheCollectionCell = 84.f;

@interface STMainViewController ()
@property(nonatomic, strong)StartViewController *startView;

@property(nonatomic, assign, getter=isSideMenuRevealed) BOOL sideMenuRevealed;
@property(nonatomic, assign, getter=shouldAutoselectStadtinfo) BOOL autoselectStadtinfo;
@property(nonatomic,strong) UIView*overlayView;
@end

@implementation STMainViewController
{
    BTGlassScrollView *_glassScrollView;
    int _page;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.autoselectStadtinfo = NO;
    self.revealSideView = [[UITapGestureRecognizer alloc] init];
    self.revealRight = [[UITapGestureRecognizer alloc] init];
    
    [self.revealSideView addTarget:self action:@selector(revealLeftSideMenu:)];
    [self.revealRight addTarget:self action:@selector(revealRightSideMenu:)];

    [self.sidebarButton setWidth:-15];
    
    //showing white status
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    //preventing weird inset
    [self setAutomaticallyAdjustsScrollViewInsets: NO];
    
    //navigation bar work
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowOffset:CGSizeMake(1, 1)];
    [shadow setShadowColor:[UIColor blackColor]];
    [shadow setShadowBlurRadius:1];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSShadowAttributeName: shadow};
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.title = @"";
    
    [self addGlassView];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        revealViewController.delegate = self;
        [self.sidebarButton setTarget: self];
        [self.sidebarButton setAction: @selector(revealLeftSideMenu:)];
        
        [self.rightBarButton setTarget: self];
        [self.rightBarButton setAction: @selector(revealRightSideMenu:)];

        revealViewController.rearViewRevealWidth  = CGRectGetWidth(self.view.bounds) - 50.f;
        revealViewController.rightViewRevealWidth = CGRectGetWidth(self.view.bounds) - 50.f;
    }
    _page = 0;
    self.startScreenState = noSideMenuOpened;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.startView loadStartData];
    
    // Always load the settings for home from plist
    NSDictionary *viewControllerItems = [[STAppSettingsManager sharedSettingsManager] viewControllerItems];
    STViewControllerItem *viewControllerItem = [viewControllerItems objectForKey:@"Startseite"];
    UIColor *barTintColor = [UIColor clearColor];
    UIColor *tintColor = [UIColor whiteColor];
    BOOL translucent = YES;
    UIBarStyle barStyle = UIBarStyleBlackTranslucent;
    if (viewControllerItem.navigationBarStyle) {
        STViewControllerNavigationBarStyle *navBarStyle = viewControllerItem.navigationBarStyle;
        
        barTintColor = navBarStyle.barTintColor;
        tintColor = navBarStyle.tintColor;
        translucent = navBarStyle.translucent;
        barStyle = navBarStyle.barStyle;
    }
    self.navigationController.navigationBar.barTintColor = barTintColor;
    self.navigationController.navigationBar.tintColor = tintColor;
    self.navigationController.navigationBar.translucent = translucent;
    self.navigationController.navigationBar.barStyle = barStyle;
    [self setStartScreen:self.startScreenState];
    [self tryToShowCouponCodeScreen];

    if ([STAppSettingsManager sharedSettingsManager].shouldDisplayRegionPicker) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (![defaults boolForKey:@"regionPickerShowed"]) {
            STRegionPickerViewController *vc = [[STRegionPickerViewController alloc] initWithNibName:@"STRegionPickerViewController" bundle:nil];
            UINavigationController *nvc = [[UINavigationController alloc] init];
            nvc.navigationBar.barTintColor = [UIColor colorWithRed:26.0/255.0 green:96.0/255.0 blue:166.0/255.0 alpha:1.0];
            [nvc setViewControllers:@[vc]];
            nvc.modalPresentationStyle = UIModalPresentationFullScreen;
            nvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentViewController:nvc animated:YES completion:nil];
        }
    }
}

- (void)viewWillLayoutSubviews
{
    // if the view has navigation bar, this is a great place to realign the top part to allow navigation controller
    // or even the status bar
    [super viewWillLayoutSubviews];
    [_glassScrollView setTopLayoutGuideLength:[self.topLayoutGuide length]];
}

-(void)tryToShowCouponCodeScreen {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[STAppSettingsManager sharedSettingsManager] showCoupons] && (![defaults objectForKey:kCouponScreenShown])) {
        BOOL shouldShowCouponsSettingsScreen = YES;
        if ([STAppSettingsManager sharedSettingsManager].shouldDisplayRegionPicker && (![defaults boolForKey:@"regionPickerShowed"])) {
            shouldShowCouponsSettingsScreen = NO;
        }
        if (shouldShowCouponsSettingsScreen) {
            if ([[[STAppSettingsManager sharedSettingsManager] activeCoupon] length] == 0) {
                // Should show coupon screen now.
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Coupons" bundle:nil];
                CouponsCodeViewController * couponCodeVC = [sb instantiateViewControllerWithIdentifier:@"CouponsCodeViewController"];
                [self presentViewController:couponCodeVC animated:true completion:nil];
            }
        }
    }
}

- (UIView *)customView
{
    // All the views will be added from xib.
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect navBarRect = self.navigationController.navigationBar.bounds;

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), screenRect.size.height - navBarRect.size.height - DEFAULT_BLUR_RADIUS - 10)];
    view.backgroundColor = [UIColor clearColor];
    
    if (!self.startView) {
        // We should move this logic inside a xib file. This is not working correctly when rotate.
        self.startView = [[StartViewController alloc] initWithNibName:@"StartViewController" bundle:nil];
        self.startView.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), view.frame.size.height);
        self.startView.sideMenuDelegate = self;
    } else {
        self.startView.view.frame = self.view.bounds ;//CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), startViewHeight);
        self.startView.startMenuColectionViewHeight.constant = self.startView.view.bounds.size.height - 64; //
        view.frame = self.startView.view.bounds;
    }

    [view addSubview:self.startView.view];
    return view;
}

- (BTGlassScrollView *)currentGlass
{
    return _glassScrollView;
}

- (void)revealLeftSideMenu:(id)sender
{
    [self.revealViewController revealToggle:sender];
    [self revealControllerTapGestureShouldBegin:self.revealViewController];
}

- (void)revealRightSideMenu:(id)sender
{
    [self.revealViewController rightRevealToggle:sender];
    [self revealControllerTapGestureShouldBegin:self.revealViewController];
}

#pragma mark - SWReveal View controller delegate methods

- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position {
    id leftMenu = revealController.rearViewController;
    id rightMenu = revealController.rightViewController;
    
    
    if (leftMenu && [leftMenu isKindOfClass:[SidebarViewController class]]) {
        ((SidebarViewController*)leftMenu).sideMenuDelegate = self;
        // If the menu was shown from stadtinfo cell, we should autoselect the cell from the sidemenu
        if (self.shouldAutoselectStadtinfo) {
            [((SidebarViewController*)leftMenu) autoselectStadtinfo];
            self.autoselectStadtinfo = NO;
        }
    }
    if (rightMenu && [rightMenu isKindOfClass:[RightBarViewController class]]) {
        ((RightBarViewController*)rightMenu).rightSideMenuDelegate = self;
    }
    
    if (!self.overlayView) {
        self.overlayView = [UIView new];
         self.overlayView.frame = self.view.bounds;
         self.overlayView.backgroundColor = [UIColor blackColor];
        self.overlayView.alpha = 0.24;
    }
    
    //moved overlay here to prevent flick
    if (position == FrontViewPositionRight) {
        [self.overlayView removeGestureRecognizer:self.revealRight];
        [self.overlayView addGestureRecognizer:self.revealSideView];
    } else if (position == FrontViewPositionLeftSide) {
        [self.overlayView removeGestureRecognizer:self.revealSideView];
        [self.overlayView addGestureRecognizer:self.revealRight];
    } else {
        [self.overlayView removeGestureRecognizer:self.revealRight];
        [self.overlayView removeGestureRecognizer:self.revealSideView];
    }
    
    if(position == FrontViewPositionLeft) {
        [self.overlayView removeFromSuperview];
    } else {
        [revealController.frontViewController.view addSubview: self.overlayView];

        
    }
    
}

- (BOOL)revealControllerPanGestureShouldBegin:(SWRevealViewController *)revealController
{
    self.sideMenuRevealed = !self.sideMenuRevealed;
    self.startScreenState = self.sideMenuRevealed ? leftSideMenuOpened :noSideMenuOpened;
    return YES;
}

- (BOOL)revealControllerTapGestureShouldBegin:(SWRevealViewController *)revealController
{
    return [self revealControllerPanGestureShouldBegin:revealController];
}

#pragma mark - SideMenuViewControllerDelegate methods

- (void)loadViewController:(UIViewController*)viewController animated:(BOOL) animated withNavigationBarBarTintColor:(UIColor*)barTintColor andTintColor:(UIColor*)tintColor translucent:(BOOL)translucent barStyle:(UIBarStyle)barStyle
{
    self.navigationController.navigationBar.barTintColor = barTintColor;
    self.navigationController.navigationBar.tintColor = tintColor;
    self.navigationController.navigationBar.translucent = translucent;
    self.navigationController.navigationBar.barStyle = barStyle;
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *navigationbarTitleFont = [settings customFontForKey:@"navigationbar.title.font"];
    
    //For iOS8+
    [self.navigationController.navigationBar setTitleTextAttributes:@{ NSFontAttributeName: navigationbarTitleFont,NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [self loadViewController:viewController animated:animated];
}

- (void)loadViewController:(UIViewController*)viewController animated:(BOOL) animated {
    [self updateMainMenuPosition];
    if (!viewController) {
        self.startScreenState = noSideMenuOpened;
    }
    [self.navigationController popToRootViewControllerAnimated:false];
    NSString *title = viewController.title;
    viewController.title = [title uppercaseString];
    [self.navigationController pushViewController:viewController animated:false];
    self.detailsContentView.hidden = false;
}

- (void)showStadtInfoLeftMenu {
    self.autoselectStadtinfo = YES;
    [self revealLeftSideMenu:self.sidebarButton];
}

- (void)setStartScreen:(StartScreenState)state {
    switch (state) {
        case leftSideMenuOpened:
            [self revealLeftSideMenu:self.sidebarButton];
            break;
        case rightSideMenuOpened:
            [self revealRightSideMenu:self.rightBarButton];
            break;
        default:
            break;
    }
}

- (void)refreshFramesForStartCollectionCells {
    
}

#pragma mark - RightMenuViewControllerDelegate methods

- (void)loadRightViewController:(UIViewController*)viewController animated:(BOOL) animated withNavigationBarBarTintColor:(UIColor*)barTintColor andTintColor:(UIColor*)tintColor translucent:(BOOL)translucent barStyle:(UIBarStyle)barStyle
{
    self.navigationController.navigationBar.barTintColor = barTintColor;
    self.navigationController.navigationBar.tintColor = tintColor;
    self.navigationController.navigationBar.translucent = translucent;
    self.navigationController.navigationBar.barStyle = barStyle;

    [self updateMainMenuPosition];
    [self.navigationController popToRootViewControllerAnimated:false];
    [self.navigationController pushViewController:viewController animated:false];
    self.detailsContentView.hidden = false;
}

#pragma mark - Private methods

- (void)updateMainMenuPosition {
    if (self.revealViewController.frontViewPosition == FrontViewPositionLeft) {
        self.startScreenState = noSideMenuOpened;
    } else if (self.revealViewController.frontViewPosition > FrontViewPositionLeft) {
        self.startScreenState = leftSideMenuOpened;
    } else if (self.revealViewController.frontViewPosition < FrontViewPositionLeft) {
        self.startScreenState = rightSideMenuOpened;
    }
}

- (void)addGlassView {
    //distance from the bottom should be 2 cells height with header space
    CGRect glassFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _glassScrollView = [[BTGlassScrollView alloc] initWithFrame:glassFrame BackgroundImage:[UIImage imageNamed:@"image_content_bg_logo"] blurredImage:[UIImage imageNamed:@"background_blurred"] viewDistanceFromBottom:2*kHeightOfTheCollectionCell + 90 foregroundView:[self customView]];
    _glassScrollView.delegate = self;
    [self.view addSubview:_glassScrollView];
}

#pragma mark - ScrollView delegate methods
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:_glassScrollView.foregroundScrollView]) {
        int maximumScrollPosition = scrollView.contentSize.height - scrollView.frame.size.height;
        //Enable scrolling on table when reach top position
        if (scrollView.contentOffset.y >= maximumScrollPosition) {
            scrollView.contentOffset = CGPointMake(0, maximumScrollPosition);
            //unable scroll on table
            self.startView.startCollectionView.scrollEnabled = YES;
            [UIView animateWithDuration:0.3 animations:^{
                // If header should change color, place the code here.
            } completion:^(BOOL finished) {
            }];
        } else {
            self.startView.startCollectionView.scrollEnabled = NO;
            [UIView animateWithDuration:0.3 animations:^{
                // If header should change color, place the code here.
            } completion:^(BOOL finished) {
            }];
        }
    }
}

@end

//
//  SidebarViewController.m
//  Stappy2
//
//  Created by Cynthia Codrea on 19/10/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "SidebarViewController.h"
#import "SWRevealViewController.h"
#import "SideMenuTableViewCell.h"

#import "AppDelegate.h"
#import "Defines.h"
#import "Utils.h"
#import "UIColor+STColor.h"
#import "STViewControllerItem.h"
#import "STViewControllerNavigationBarStyle.h"
#import "STWebViewDetailViewController.h"

//left items view controllers
#import "STMainViewController.h"
#import "STLokalNewsViewController.h"
#import "STTickerViewController.h"
#import "STEventsViewController.h"
#import "STVereinsnewsViewController.h"
#import "STAngeboteViewController.h"
#import "STfahrplanSearchVC.h"
#import "STWeatherViewController.h"
#import "STApothekenViewController.h"
#import "STParkhausViewController.h"
#import "STStadtInfoOverviewViewController.h"
#import "STBaederOverviewViewController.h"
#import "STRegionPickerSettingsView.h"
#import "STLeftMenuSettingsModel.h"
#import "STLeftObjRequestedModel.h"
#import "SearchTopTableViewCell.h"
#import "STLeftSideSubSettingsModel.h"
//generic category model
#import "STCategoryModel.h"

//networking
#import "STRequestsHandler.h"
#import "STQRCodeScannerViewController.h"
#import "STAppSettingsManager.h"

// Settings, search and favorites
#import "SidebarViewController+Favorite.h"
#import "SidebarViewController+Search.h"
#import "SidebarViewController+Settings.h"

#import "Defines.h"
#import "RandomImageView.h"

#import "STAppSettingsManager.h"
#import "StappyTextField.h"

static NSString* const sideMenuCellIdentifier = @"SideMenuTableViewCell";

@interface SidebarViewController ()

//@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) NSIndexPath* firstMenuSelectedIndexPath;
@property (nonatomic, strong) NSIndexPath* secondMenuSelectedIndexPath;
@property (nonatomic, strong) NSIndexPath* thirdMenuSelectedIndexPath;

@end

@implementation SidebarViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Setup elements after init here.
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backSubitemDict = @{@"title":@"Zurück"};
    NSArray* leftArray = [STAppSettingsManager sharedSettingsManager].leftMenuItems;
    NSError* mtlError = nil;
    NSArray* leftReqArray = [STAppSettingsManager sharedSettingsManager].leftMenuItemsDictionary[@"content"];
    NSArray* requestLeftMenuItems = [MTLJSONAdapter modelsOfClass:[STLeftObjRequestedModel class]
                                                    fromJSONArray:leftReqArray
                                                            error:&mtlError];
    self.leftMenuItems = leftArray;
    self.menuItems = leftArray;
    for (STLeftMenuSettingsModel* itemModel in self.menuItems) {
        for (STLeftObjRequestedModel* model in requestLeftMenuItems) {
            if ([model.itemName isEqualToString:itemModel.type]) {
                itemModel.subItems = model.children;
            }
        }
    }
        
    _secondMenuOpened = false;
    _thirdMenuOpened = false;
    _secondMenuLeadingConstraint.constant = _bottomContentView.frame.size.width + [self leftSideTablesOffset];
    _firstMenuTrailingConstraint.constant = 0;
    _thirdMenuLeadingConstraint.constant = _bottomContentView.frame.size.width + [self leftSideTablesOffset];
    _secondMenuTrailingConstraint.constant = 0;
    
    self.menuState = leftMenuState;
    //Register the cells for the tableViews.
    //The menu tables have the same cell, only data is different.
    UINib * nib = [UINib nibWithNibName:@"SideMenuTableViewCell" bundle:nil];
    UINib * settingsNib = [UINib nibWithNibName:@"SettingsSelectionsTableViewCell" bundle:nil];
    UINib * settingsTopNib = [UINib nibWithNibName:@"SettingsSelectionsTopTableViewCell" bundle:nil];
    UINib * searcAndFavoritesNib = [UINib nibWithNibName:@"SearchAndFavoritesTableViewCell" bundle:nil];
    UINib * searcTopNib = [UINib nibWithNibName:@"SearchTopTableViewCell" bundle:nil];
    
    [self.firstsideMenuTable registerNib:nib forCellReuseIdentifier:sideMenuCellIdentifier];
    [self.secondSideMenuTable registerNib:nib forCellReuseIdentifier:sideMenuCellIdentifier];
    [self.thirdSideMenuTable registerNib:nib forCellReuseIdentifier:sideMenuCellIdentifier];
    
    [self.secondSideMenuTable registerNib:settingsNib forCellReuseIdentifier:kSettingsSelectionsTableViewCellIdentifier];
    [self.secondSideMenuTable registerNib:settingsTopNib forCellReuseIdentifier:kSettingsSelectionsTopTableViewCellIdentifier];
    
    [self.thirdSideMenuTable registerNib:settingsNib forCellReuseIdentifier:kSettingsSelectionsTableViewCellIdentifier];
    [self.thirdSideMenuTable registerNib:settingsTopNib forCellReuseIdentifier:kSettingsSelectionsTopTableViewCellIdentifier];
    
    [self.secondSideMenuTable registerNib:searcAndFavoritesNib forCellReuseIdentifier:kSearchAndFavoritesTableViewCell];
    [self.thirdSideMenuTable registerNib:searcAndFavoritesNib forCellReuseIdentifier:kSearchAndFavoritesTableViewCell];
    
    [self.secondSideMenuTable registerNib:searcTopNib forCellReuseIdentifier:kSearchTopTableViewCell];
    [self.thirdSideMenuTable registerNib:searcTopNib forCellReuseIdentifier:kSearchTopTableViewCell];

    // STRegionPickerSettingsViewDelegate
    self.regionPickerSettingsView.delegate = self;

    // Fonts
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *settingsFont  = [settings customFontForKey:@"sidemenu.settings.font"];
    UIFont *searchFont    = [settings customFontForKey:@"sidemenu.search.font"];
    UIFont *favoritesFont = [settings customFontForKey:@"sidemenu.favorites.font"];
    
    if (settingsFont)  [self.settingsButton.titleLabel  setFont:settingsFont];
    if (searchFont)    [self.searchButton.titleLabel    setFont:settingsFont];
    if (favoritesFont) [self.favoritesButton.titleLabel setFont:settingsFont];
    
    // Rounding the corners of settings buttons
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:_settingsButton.bounds
                                     byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerTopLeft)
                                           cornerRadii:CGSizeMake(3.0, 3.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = _settingsButton.bounds;
    maskLayer.path = maskPath.CGPath;
    _settingsButton.layer.mask = maskLayer;
    
    maskPath = [UIBezierPath bezierPathWithRoundedRect:_favoritesButton.bounds
                                     byRoundingCorners:(UIRectCornerBottomRight | UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(3.0, 3.0)];

    CAShapeLayer *maskLayer2 = [[CAShapeLayer alloc] init];
    maskLayer2.frame = _favoritesButton.bounds;
    maskLayer2.path = maskPath.CGPath;
    _favoritesButton.layer.mask = maskLayer2;
    
    [self hideActivityIndicator];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.backgroundBlurred.needsBlur = YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * dataArray = [self menuDataArrayForTableView:tableView];
    return [dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    NSArray * dataArray = [self menuDataArrayForTableView:tableView];
    if (dataArray.count > indexPath.row) {
        //item to use for populating the cell
        switch (tableView.tag)
        {
            case 1001:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:sideMenuCellIdentifier forIndexPath:indexPath];
                STLeftMenuSettingsModel *menuItem = [dataArray objectAtIndex:indexPath.row];
                ((SideMenuTableViewCell *)cell).menuItemLabel.text = menuItem.title;
                ((SideMenuTableViewCell *)cell).menuItemImageView.image = [UIImage imageNamed:[Utils replaceSpecialCharactersFrom:menuItem.iconName]];
                if (menuItem.subItems.count == 0) {
                    ((SideMenuTableViewCell *)cell).iconBackground = nil;
                }
                if (!((SideMenuTableViewCell *)cell).menuItemImageView.image) {
                    ((SideMenuTableViewCell *)cell).menuItemImageView.image = [UIImage imageNamed:[[Utils replaceSpecialCharactersFrom:menuItem.iconName] capitalizedString]];
                }
                if (self.menuState == leftMenuState)
                    ((SideMenuTableViewCell *)cell).shouldHaveDarkBackground = self.secondMenuOpened || self.thirdMenuOpened;
                else
                    ((SideMenuTableViewCell *)cell).shouldHaveDarkBackground = YES;
            }
                break;
            case 1002:
            {
                switch (self.menuState)
                {
                    case settingsState:  cell = [self settingsTableView:tableView cellForRowAtIndexPath:indexPath];  break;
                    case searchState:    cell = [self searchTableView:tableView cellForRowAtIndexPath:indexPath];    break;
                    case favoritesState: cell = [self favoritesTableView:tableView cellForRowAtIndexPath:indexPath]; break;
                    case leftMenuState:
                    default:
                    {
                        cell = [tableView dequeueReusableCellWithIdentifier:sideMenuCellIdentifier forIndexPath:indexPath];
                        ((SideMenuTableViewCell *)cell).shouldHaveDarkBackground = NO;
                        ((SideMenuTableViewCell *)cell).firstSideTableCell = !self.thirdMenuOpened;
                        STLeftObjRequestedModel* menuItem = [dataArray objectAtIndex:indexPath.row];
                        NSString* itemName = [menuItem valueForKey:@"title"];
                        NSString* imageName = [NSString stringWithFormat:@"%@",itemName];
                        imageName = [Utils replaceSpecialCharactersFrom:imageName];
                        UIImage *imageNameCell = [[UIImage alloc] init];
                        if ([UIImage imageNamed:imageName]) {
                            imageNameCell = [UIImage imageNamed:imageName];
                        }
                        else {
                            imageNameCell = [UIImage imageNamed:[imageName lowercaseString]];
                        }
                        ((SideMenuTableViewCell *)cell).menuItemImageView.image = imageNameCell;
                        ((SideMenuTableViewCell *)cell).selectionIndicator = nil;
                        if (indexPath.row == 0) {
                            itemName = [itemName uppercaseString];
                        }
                        ((SideMenuTableViewCell *)cell).menuItemLabel.text = itemName;
                    }
                }
            }
                break;
            case 1003:
            {
                switch (self.menuState)
                {
                    case settingsState:  cell = [self settingsTableView:tableView cellForRowAtIndexPath:indexPath];  break;
                    case searchState:    cell = [self searchTableView:tableView cellForRowAtIndexPath:indexPath];    break;
                    case favoritesState: cell = [self favoritesTableView:tableView cellForRowAtIndexPath:indexPath]; break;
                    case leftMenuState:
                    default:
                    {
                        cell = [tableView dequeueReusableCellWithIdentifier:sideMenuCellIdentifier forIndexPath:indexPath];
                        STLeftObjRequestedModel* menuItem = [dataArray objectAtIndex:indexPath.row];
                        NSString* itemName = [menuItem valueForKey:@"title"];
                        NSString* imageName = [NSString stringWithFormat:@"%@",itemName];
                        imageName = [Utils replaceSpecialCharactersFrom:imageName];
                        ((SideMenuTableViewCell *)cell).menuItemImageView.image = [UIImage imageNamed:imageName];
                        ((SideMenuTableViewCell *)cell).firstSideTableCell = NO;
                        ((SideMenuTableViewCell *)cell).shouldHaveDarkBackground = NO;
                        ((SideMenuTableViewCell *)cell).showIconBackground = NO;
                        ((SideMenuTableViewCell *)cell).selectionIndicator = nil;
                        if (indexPath.row == 0) {
                            itemName = [itemName uppercaseString];
                        }
                        ((SideMenuTableViewCell *)cell).menuItemLabel.text = itemName;
                    }
                }
            }
            default:
                break;
        }
    }

    // Cell Font
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *meineStadtwerkeFont = [settings customFontForKey:@"sidemenu.cell.font"];
    if (meineStadtwerkeFont && ([cell isKindOfClass:[SideMenuTableViewCell class]])) [((SideMenuTableViewCell *)cell).menuItemLabel setFont:meineStadtwerkeFont];

    return cell;
}

#pragma mark - TableView delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.parentCell = [tableView cellForRowAtIndexPath:indexPath];

    switch (self.menuState) {
        case settingsState:
            [self settingsItemSelectedAtIndexPath:indexPath forTableView:tableView];
            break;
        case searchState:
            [self searchItemSelectedAtIndexPath:indexPath forTableView:tableView];
            break;
        case favoritesState:
            [self favoritesItemSelectedAtIndexPath:indexPath forTableView:tableView];
            break;
        case leftMenuState:
            [self mainMenuItemSelectedAtIndexPath:indexPath forTableView:tableView];
            break;
        default: {
            [self mainMenuItemSelectedAtIndexPath:indexPath forTableView:tableView];
        }
    }
}

- (void)resetTopButtons {
    self.settingsButton.selected = false;
    self.searchButton.selected = false;
    self.favoritesButton.selected = false;
}

#pragma mark - Public methods
- (void)showActivityIndicator {
    self.activityIndicator.hidden = false;
    [self.view bringSubviewToFront:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

- (void)hideActivityIndicator {
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = true;
}

-(void)resetLeftMenuInitialState {
    [self resetTopButtons];
    self.menuState = leftMenuState;
    self.secondMenuTopView.hidden = true;
    self.secondTableTopConstraint.constant = 50;
    self.thirdTableTopConstraint.constant = 50;
    [self.firstsideMenuTable reloadData];
    if (self.thirdMenuOpened) {
        [self hideThirdMenuItems];
    }
    if (self.secondMenuOpened) {
        [self hideSecondMenuItems];
    }
}

-(int)leftSideTablesOffset {
    return 0;
}

-(void)autoselectStadtinfo {
    NSArray * dataArray = self.leftMenuItems;
    int stadtinfoIndex = 0;
    for (int i = 0; i < dataArray.count; i++) {
        STLeftMenuSettingsModel *menuItem = [dataArray objectAtIndex:i];
        if ([menuItem.title isEqualToString:@"Stadtinfos"] || [menuItem.title isEqualToString:@"Meine Stadt"] || [menuItem.title isEqualToString:@"Ortsinformationen"]) {
            stadtinfoIndex = i;
            break;
        }
    }
    if (stadtinfoIndex > 0) {
        // Select the row
        NSIndexPath *stadtInfoIndexPath = [NSIndexPath indexPathForRow:stadtinfoIndex inSection:0];
        [self.firstsideMenuTable selectRowAtIndexPath:stadtInfoIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self showSecondMenuItems];
        [self mainMenuItemSelectedAtIndexPath:stadtInfoIndexPath forTableView:self.firstsideMenuTable];
    }
}

#pragma mark - Private methods

- (void) showSecondMenuItems {
    [self hideThirdMenuItems];
    [self.secondSideMenuTable reloadData];
    if (_secondMenuOpened) {
        return;
    }
    _secondMenuOpened = YES;
    if (self.menuState == leftMenuState) {
        self.secondMenuTopView.hidden = false;
    }
    _secondMenuLeadingConstraint.constant = _bottomContentView.frame.size.width;
    _secondSideMenuTable.hidden = NO;

    NSIndexPath *ipath = [self.firstsideMenuTable indexPathForSelectedRow];
    [self.firstsideMenuTable reloadData];
    [self.firstsideMenuTable selectRowAtIndexPath:ipath animated:NO scrollPosition:UITableViewScrollPositionNone];
    // Set the top label:
    STLeftMenuSettingsModel *menuItem = [self.menuItems objectAtIndex:ipath.row];
    self.secondMenuTopLabel.text = [menuItem.title uppercaseString];
    
    // Start animating the constraints;
    _secondMenuLeadingConstraint.constant = kSideMenuOverlapValue + [self leftSideTablesOffset];
    _firstMenuTrailingConstraint.constant = _bottomContentView.frame.size.width - _secondMenuLeadingConstraint.constant;
    [UIView animateWithDuration:kSideMenuAnimationDuration
                     animations:^{
                         [_bottomContentView layoutIfNeeded]; // Called on parent view
                     }];
}

- (void) hideSecondMenuItems {
    [self.secondSideMenuItems removeAllObjects];
    [self hideThirdMenuItems];
    if (!_secondMenuOpened) {
        return;
    }
    _secondMenuOpened = NO;
    self.secondMenuTopView.hidden = true;
    self.menuState = leftMenuState;
    [self.firstsideMenuTable reloadData];

    // Start animating the constraints;
    _secondMenuLeadingConstraint.constant = _bottomContentView.frame.size.width;
    _firstMenuTrailingConstraint.constant = 0;
    [UIView animateWithDuration:kSideMenuAnimationDuration
                     animations:^{
                         [_bottomContentView layoutIfNeeded]; // Called on parent view
                     }];
}

- (void) showThirdMenuItems {
    //get data for third menu options
    if (_thirdMenuOpened) {
        return;
    }
    _thirdMenuOpened = YES;
    NSIndexPath *ipath = [self.secondSideMenuTable indexPathForSelectedRow];
    [self.secondSideMenuTable reloadData];
    [self.secondSideMenuTable selectRowAtIndexPath:ipath animated:NO scrollPosition:UITableViewScrollPositionNone];
    _thirdMenuLeadingConstraint.constant = _bottomContentView.frame.size.width;
    _thirdSideMenuTable.hidden = NO;

    [_thirdSideMenuTable reloadData];

    // Set the top label:
    STLeftMenuSettingsModel *menuItem = [self.secondSideMenuItems objectAtIndex:ipath.row];
    self.secondMenuTopLabel.text = [[menuItem valueForKey:@"title"] uppercaseString];
    
    // Start animating the constraints;
    _thirdMenuLeadingConstraint.constant = 2 * kSideMenuOverlapValue + [self leftSideTablesOffset];
    _secondMenuTrailingConstraint.constant = _bottomContentView.frame.size.width - _thirdMenuLeadingConstraint.constant;
    [UIView animateWithDuration:kSideMenuAnimationDuration
                     animations:^{
                         [_bottomContentView layoutIfNeeded]; // Called on parent view
                     }];
}

- (void) hideThirdMenuItems {
    if (!_thirdMenuOpened) {
        return;
    }
    // Set the top label:
    NSIndexPath *ipath = [self.firstsideMenuTable indexPathForSelectedRow];
    STLeftMenuSettingsModel *menuItem = [self.menuItems objectAtIndex:ipath.row];
    self.secondMenuTopLabel.text = [menuItem.title uppercaseString];
    
    _thirdMenuOpened = false;
    // Start animating the constraints;
    _thirdMenuLeadingConstraint.constant = _bottomContentView.frame.size.width;
    _secondMenuTrailingConstraint.constant = 0;
    [UIView animateWithDuration:kSideMenuAnimationDuration
                     animations:^{
                         [_bottomContentView layoutIfNeeded]; // Called on parent view
                     } completion:^(BOOL finished) { _thirdSideMenuTable.hidden = YES; }];
    
    [self.secondSideMenuTable reloadData];
}

- (IBAction)tapOutsideTextFieldRecognized:(id)sender {
    if ([[STAppSettingsManager sharedSettingsManager] showCoupons]) {
        if (self.couponCodeTextField.isFirstResponder) {
            [self validateAndSaveCouponCode];
        }
        [self.couponCodeTextField resignFirstResponder];
    }
}

- (void)validateAndSaveCouponCode {
    NSString * couponCode = self.couponCodeTextField.text;
    if ([Utils isCouponCodeValid:couponCode]) {
        [[NSUserDefaults standardUserDefaults] setObject:couponCode forKey:kActiveCouponCode];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self dismissViewControllerAnimated:true completion:nil];
    } else {
        // Show alert
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Kundennummer Error" message:@"Die eingegebene Kundennummer ist leider ungültig." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] ;
        [alert show];
    }
}

- (NSArray*)menuDataArrayForTableView:(UITableView*)tableView {
    NSArray *dataArray;
    switch (tableView.tag) {
        case 1002:
            dataArray = self.secondSideMenuItems;
            break;
        case 1003:
            dataArray = self.thirdSideMenuItems;
            break;
        default:
            switch (self.menuState) {
                case settingsState:
                    dataArray = self.settingsSideMenuItems;
                    break;
                case searchState:
                    dataArray = self.searchSideMenuItems;
                    break;
                case favoritesState:
                    dataArray = self.favoritesSideMenuItems;
                    break;
                case leftMenuState:
                default:
                    dataArray = self.menuItems;
            }
            break;
    }
    return dataArray;
}

- (void)mainMenuItemSelectedAtIndexPath:(NSIndexPath*)indexPath forTableView:(UITableView*)tableView {
    switch (tableView.tag) {
        case 1001: {
            // A cell from the first menu is selected here.
            if (self.thirdMenuOpened) {
                [self hideThirdMenuItems];
            }
            if (self.secondMenuOpened) {
                [self hideSecondMenuItems];
            }
            NSArray * dataArray = [self menuDataArrayForTableView:tableView];
            STLeftMenuSettingsModel *menuItem = [dataArray objectAtIndex:indexPath.row];
            // Check if we show the second menu or another controller.
            if (menuItem.subItems.count > 0) {
                // Show next Submenu
                self.secondSideMenuItems = [NSMutableArray arrayWithArray:menuItem.subItems] ;
                [self.secondSideMenuItems insertObject:self.backSubitemDict atIndex:0];
                [self.secondSideMenuTable reloadData];
                [self showSecondMenuItems];
            } else {
                NSDictionary *viewControllerItems = [[STAppSettingsManager sharedSettingsManager] viewControllerItems];
                STViewControllerItem *viewControllerItem = [viewControllerItems objectForKey:menuItem.title];
                UIViewController * newViewController = [Utils loadViewControllerWithTitle:menuItem.title];       
                [self loadViewController:newViewController withViewControllerItem:viewControllerItem];
            }
        }
            break;
        case 1002:
        {
            // A cell from the second menu is selected here.
            if (indexPath.row == 0) {
                [self hideSecondMenuItems];
                break;
            }
            NSArray * dataArray = [self menuDataArrayForTableView:tableView];
            id menuItem = [dataArray objectAtIndex:indexPath.row];
            // Check if we show the second menu or another controller.

            BOOL hasSubItems = NO;
            
            if ([menuItem isKindOfClass:[STLeftSideSubSettingsModel class]]) {
                
                if ([[menuItem valueForKey:@"itemType"]  isEqualToString:@"website"]) {
                    //show web view
                    NSDictionary *viewControllerItems = [[STAppSettingsManager sharedSettingsManager] viewControllerItems];
                    NSString* key = [viewControllerItems allKeys][0];
                    STViewControllerItem *viewControllerItem = [viewControllerItems objectForKey:key];
                    
                    NSString*detailUrl =[menuItem valueForKey:@"url"];
                    
                    STWebViewDetailViewController *webPage = [[STWebViewDetailViewController alloc] initWithNibName:@"STWebViewDetailViewController" bundle:nil andDetailUrl:detailUrl];
                    [self loadViewController:webPage withViewControllerItem:viewControllerItem];
                    
                }
                else {
                    //show overview screen
                    NSDictionary *viewControllerItems = [[STAppSettingsManager sharedSettingsManager] viewControllerItems];
                    STViewControllerItem *viewControllerItem = [viewControllerItems objectForKey:[menuItem valueForKey:@"title"]];
                    UIViewController * newViewController = [Utils loadViewControllerWithTitle:[menuItem valueForKey:@"title"]];
                    [self loadViewController:newViewController withViewControllerItem:viewControllerItem];
                
                }

                
            }
            else{
                if ((NSArray*)[menuItem valueForKey:@"children"] !=nil) {
                    
                    if (((NSArray*)[menuItem valueForKey:@"children"]).count > 0) {
                        hasSubItems = YES;
                    }
                    
                }
                
                
                
                if (hasSubItems) {
                    self.thirdSideMenuItems = [NSMutableArray arrayWithArray:[menuItem valueForKey:@"children"]];
                    [self.thirdSideMenuItems insertObject:self.backSubitemDict atIndex:0];
                    [self.thirdSideMenuTable reloadData];
                    self.secondMenuTopLabel.text = [[menuItem valueForKey:@"title"] uppercaseString];
                    [self showThirdMenuItems];
                } else {
                    //check if we show a web view or the overview screen
                    NSString* detailUrl = [menuItem valueForKey:@"url"];
                    if ([[menuItem valueForKey:@"type"] isEqualToString:@"website"]) {
                        //show web view
                        NSDictionary *viewControllerItems = [[STAppSettingsManager sharedSettingsManager] viewControllerItems];
                        NSString* key = [viewControllerItems allKeys][0];
                        STViewControllerItem *viewControllerItem = [viewControllerItems objectForKey:key];
                        STWebViewDetailViewController *webPage = [[STWebViewDetailViewController alloc] initWithNibName:@"STWebViewDetailViewController" bundle:nil andDetailUrl:detailUrl];
                        [self loadViewController:webPage withViewControllerItem:viewControllerItem];
                        
                    }
                    else {
                        //show overview screen
                        NSDictionary *viewControllerItems = [[STAppSettingsManager sharedSettingsManager] viewControllerItems];
                        NSString* key = [viewControllerItems allKeys][0];
                        STViewControllerItem *viewControllerItem = [viewControllerItems objectForKey:key];
                        STStadtInfoOverviewViewController* overview = [[STStadtInfoOverviewViewController alloc] initWithUrl:[menuItem valueForKey:@"url"] title:[menuItem valueForKey:@"title"]];
                        [self loadViewController:overview withViewControllerItem:viewControllerItem];
                    }
                }
            }
        }
            break;
        case 1003:
            // A cell from the third menu is selected here, show preview
            if (indexPath.row == 0) {
                [self hideThirdMenuItems];
                break;
            }
        {
            NSArray * dataArray = [self menuDataArrayForTableView:tableView];
            STLeftMenuSettingsModel *menuItem = [dataArray objectAtIndex:indexPath.row];
            NSDictionary *viewControllerItems = [[STAppSettingsManager sharedSettingsManager] viewControllerItems];

            NSString* key = [viewControllerItems allKeys][0];
            
            //check if we show a web view or the overview screen
            NSString* detailUrl = [menuItem valueForKey:@"url"];
            if ([[menuItem valueForKey:@"type"] isEqualToString:@"website"]) {
                //show web view
                STViewControllerItem *viewControllerItem = [viewControllerItems objectForKey:key];
                STWebViewDetailViewController *webPage = [[STWebViewDetailViewController alloc] initWithNibName:@"STWebViewDetailViewController" bundle:nil andDetailUrl:detailUrl];
                [self loadViewController:webPage withViewControllerItem:viewControllerItem];
            }
            else {
                //show overview screen
                NSDictionary *viewControllerItems = [[STAppSettingsManager sharedSettingsManager] viewControllerItems];
                STViewControllerItem *viewControllerItem = [viewControllerItems objectForKey:key];
                STStadtInfoOverviewViewController* overview = [[STStadtInfoOverviewViewController alloc] initWithUrl:[menuItem valueForKey:@"url"] title:[menuItem valueForKey:@"title"]];
                [self loadViewController:overview withViewControllerItem:viewControllerItem];
            }

        }
            
            break;
        default:
            //Cancel method here.
            [self hideThirdMenuItems];
            [self hideSecondMenuItems];
            
            break;
    }
}

-(void)loadViewController:(UIViewController *)newViewController withViewControllerItem:(STViewControllerItem *)viewControllerItem {
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
//    if ([newViewController isKindOfClass:[STWebViewDetailViewController class]]) {
//        newViewController = [[STWebViewDetailViewController alloc] initWithURL:viewControllerItem.url];
//    }
    [self.sideMenuDelegate loadViewController:newViewController animated:YES withNavigationBarBarTintColor:barTintColor andTintColor:tintColor translucent:translucent barStyle:barStyle];
    [self.revealViewController revealToggleAnimated:YES];
}

@end

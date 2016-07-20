//
//  RightBarViewController.m
//  Stappy2
//
//  Created by Cynthia Codrea on 12/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "RightBarViewController.h"
#import "SideMenuTableViewCell.h"
#import "UIImage+tintImage.h"
#import "STAppSettingsManager.h"
#import "STRightMenuItemsModel.h"
#import "STDetailViewController.h"
#import "STRequestsHandler.h"
#import "STDetailGenericModel.h"
#import "SWRevealViewController.h"
#import "UIColor+STColor.h"
#import "Utils.h"
#import "Defines.h"
#import "STLeftMenuSettingsModel.h"
#import "STRightMenuItemsModel.h"
#import "STWebViewDetailViewController.h"
#import "STRightMenuHeaderView.h"
#import "STRightMenuSubCell.h"
#import "STViewControllerItem.h"
#import "STViewControllerNavigationBarStyle.h"
#import "STStadtInfoOverviewViewController.h"
#import "STTankStationsViewController.h"
#import "STReporterLocationViewController.h"
static NSString * const rightBarMenuCellIdentifier = @"SideMenuTableViewCell";
static NSString *kRightMenuTableViewHeaderIdentifier = @"STRightMenuHeaderView";
static NSString *kRightMenuTableSubCellIdentifier = @"STRightMenuSubCell";
static CGFloat maxMaineStadtFontSize = 22.0f;

@interface RightBarViewController () {
    //@property (nonatomic, strong) NSArray *menuItems;
    NSMutableArray *arrayForBool;
}
@end

@implementation RightBarViewController

#pragma mark - ViewWillAppear/NSNotificationCenter Methods

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserverForName:kRightMenuNotificationKey
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification)
     {
         self.menuItems = [STAppSettingsManager sharedSettingsManager].rightMenuItems == nil ? @[] : [STAppSettingsManager sharedSettingsManager].rightMenuItems;
         [self.firstsideMenuTable reloadData];
     }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRightMenuNotificationKey object:nil];
}

#pragma mark -
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!arrayForBool) {
        arrayForBool = [NSMutableArray array];
        for ( int i=0; i< [self menuDataArrayForTableView:self.firstsideMenuTable].count; i++) {
            [arrayForBool addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    UINib *sectionHeaderNib = [UINib nibWithNibName:@"STRightMenuHeaderView" bundle:nil];
    [self.firstsideMenuTable registerNib:sectionHeaderNib forHeaderFooterViewReuseIdentifier:kRightMenuTableViewHeaderIdentifier];
    
    UINib *subItemNib = [UINib nibWithNibName:@"STRightMenuSubCell" bundle:nil];
    [self.firstsideMenuTable registerNib:subItemNib forCellReuseIdentifier:kRightMenuTableSubCellIdentifier];
    
    self.menuItems = [STAppSettingsManager sharedSettingsManager].rightMenuItems == nil ? @[] : [STAppSettingsManager sharedSettingsManager].rightMenuItems;
    
    self.firstsideMenuTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *meineStadtwerkeFont = [settings customFontForKey:@"rightmenu.meineStadtwerke.font"];
    if (meineStadtwerkeFont) [self.meineStadtwerkeLabel setFont:[UIFont fontWithName:meineStadtwerkeFont.familyName size: maxMaineStadtFontSize > meineStadtwerkeFont.pointSize ? meineStadtwerkeFont.pointSize : maxMaineStadtFontSize]];
    self.meineStadtwerkeLabel.textColor = [UIColor secondaryColor];
    self.meineStadtwerkeLabel.text = [STAppSettingsManager sharedSettingsManager].rightMenuTitle;
    [self.firstsideMenuTable reloadData];
    
    // separator
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, self.meineStadtwerkeLabel.frame.origin.y + self.meineStadtwerkeLabel.frame.size.height + 1, self.view.frame.size.width, 1)];
    //TODO get color from config file
    separatorView.backgroundColor = [UIColor secondaryColor];
    [self.view addSubview:separatorView];
    
    if (settings.rightMenuHeaderImage) {
        self.headerImageView.image = [UIImage imageNamed:settings.rightMenuHeaderImage];
        self.stadtwerkLogoImageView.image = nil;
    }
    else{
        UITapGestureRecognizer*tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeRightMenu)];
        [self.stadtwerkLogoImageView addGestureRecognizer:tapRecognizer];
        
    }
}

-(void)closeRightMenu{
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [revealViewController rightRevealToggleAnimated:YES];
    }
    
}

//Here implement drop down list for submenus

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSArray * dataArray = [self menuDataArrayForTableView:tableView];
    return [dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //subsection count
    if ([[arrayForBool objectAtIndex:section] boolValue]) {
        NSArray * dataArray = [self menuDataArrayForTableView:tableView];
        STLeftMenuSettingsModel *menuItem = [dataArray objectAtIndex:section];
        return [[menuItem valueForKey:@"children"] count];
    }
    return 0;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 54;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"STRightMenuHeaderView" owner:self options:nil];
    STRightMenuHeaderView *sectionHeaderView = [nibViews objectAtIndex:0];
    
    
    sectionHeaderView.tag = section;
    BOOL manyCells = [[arrayForBool objectAtIndex:section] boolValue];
    UITapGestureRecognizer  *headerTapped   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionHeaderTapped:)];
    [sectionHeaderView addGestureRecognizer:headerTapped];
    //up or down arrow depending on the bool
    NSArray * dataArray = [self menuDataArrayForTableView:tableView];
    STRightMenuItemsModel *rowModel = ((STRightMenuItemsModel*)dataArray[section]);
    if ([rowModel.type isEqualToString:@"sinfo_kat"]) {
        UIImage *upDownArrow = manyCells ? [UIImage imageNamed:@"Up_arrow"] : [UIImage imageNamed:@"Down_arrow"];
        upDownArrow = [upDownArrow imageTintedWithColor:[UIColor blackColor]];
        if (rowModel.children.count > 0) {
            sectionHeaderView.dropArrow.image = upDownArrow;
        }
    }
    
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *menuItemLabelFont = [settings customFontForKey:@"rightmenu.cell.font"];
    if (menuItemLabelFont) [sectionHeaderView.headerLabel setFont:menuItemLabelFont];
    
    UIImage *cellImage =  [UIImage imageNamed:[Utils replaceSpecialCharactersFrom:rowModel.title]];
    cellImage = [cellImage imageTintedWithColor:[UIColor secondaryColor]];
    sectionHeaderView.rightMenuImage.image = cellImage;
    //add drop icon if row has subitems
    
    
    sectionHeaderView.headerLabel.text = rowModel.title;
    sectionHeaderView.headerLabel.textColor = [UIColor blackColor];
    sectionHeaderView.separatorLabel.textColor = [UIColor secondaryColor];
    sectionHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
    sectionHeaderView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(sectionHeaderView.frame));
    
    return sectionHeaderView;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STRightMenuSubCell *cell = (STRightMenuSubCell*)[tableView dequeueReusableCellWithIdentifier:kRightMenuTableSubCellIdentifier];
    cell.subCellText.text = ((STRightMenuItemsModel *)((STRightMenuItemsModel *)self.menuItems[indexPath.section]).children[indexPath.row]).title;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - gesture tapped
- (void)sectionHeaderTapped:(UITapGestureRecognizer *)gestureRecognizer{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:gestureRecognizer.view.tag];
    if (indexPath.row == 0) {
        
        //check if we have children or if we show the detail page
        NSArray * dataArray = [self menuDataArrayForTableView:self.firstsideMenuTable];
        STRightMenuItemsModel *rowModel = ((STRightMenuItemsModel*)dataArray[gestureRecognizer.view.tag]);
        if (rowModel.children.count == 0) {
            
            if ([rowModel.type isEqualToString:@"sinfo_feed"]) {
                //show overview
                NSString* url =  [[STRequestsHandler sharedInstance] buildUrl:rowModel.detailsUrl withParameters:nil forPage:0];
                NSDictionary *viewControllerItems = [[STAppSettingsManager sharedSettingsManager] viewControllerItems];
                NSString* key = [viewControllerItems allKeys][1];
                STViewControllerItem *viewControllerItem = [viewControllerItems objectForKey:key];
                STStadtInfoOverviewViewController* overview = [[STStadtInfoOverviewViewController alloc] initWithUrl:url title:rowModel.title];
                overview.ignoreFavoritesButton = YES;
                [self loadViewController:overview withViewControllerItem:viewControllerItem];
            }
            if ([rowModel.type isEqualToString:@"charging_station"]) {
                //request stations
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                STTankStationsViewController *stationsController = (STTankStationsViewController*)[storyboard instantiateViewControllerWithIdentifier:@"Tank"];
                stationsController.stationsId = [NSString stringWithFormat:@"%li",(long)rowModel.stadtInfosId];
                
                
                NSDictionary *viewControllerItems = [[STAppSettingsManager sharedSettingsManager] viewControllerItems];
                STViewControllerItem *viewControllerItem = [viewControllerItems objectForKey:rowModel.title];
                if (viewControllerItem) {
                    
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
                    
                    stationsController.title = rowModel.title;
                    [self.rightSideMenuDelegate loadRightViewController:stationsController animated:YES withNavigationBarBarTintColor:barTintColor andTintColor:tintColor translucent:translucent barStyle:barStyle];
                 [self.revealViewController rightRevealToggleAnimated:YES];

                    return;
                }
            }
            if ([rowModel.type isEqualToString:@"failure_report"]) {
                //request stations
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                STReporterLocationViewController *stationsController = (STReporterLocationViewController*)[storyboard instantiateViewControllerWithIdentifier:@"Reporter"];
               
                
                
                NSDictionary *viewControllerItems = [[STAppSettingsManager sharedSettingsManager] viewControllerItems];
                STViewControllerItem *viewControllerItem = [viewControllerItems objectForKey:@"Strassenlaterne defekt?"];
                if (viewControllerItem) {
                    
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
                    
                    stationsController.title = rowModel.title;
                    
                    [self.rightSideMenuDelegate loadRightViewController:stationsController animated:YES withNavigationBarBarTintColor:barTintColor andTintColor:tintColor translucent:translucent barStyle:barStyle];
                    [self.revealViewController rightRevealToggleAnimated:YES];
                }
            }
            else{
                
                NSDictionary *viewControllerItems = [[STAppSettingsManager sharedSettingsManager] viewControllerItems];
                STViewControllerItem *viewControllerItem = [viewControllerItems objectForKey:rowModel.title];
                if (viewControllerItem) {
                    UIViewController * newViewController = [Utils loadViewControllerWithTitle:rowModel.title];
                    [self loadViewController:newViewController withViewControllerItem:viewControllerItem];
                }
                else {
                    if ([rowModel.type isEqualToString:@"website"]) {
                        [self showWebViewFor:rowModel.detailsUrl];
                    } else {
                        [self requestDetailedDataForItem:rowModel.detailsUrl];
                    }
                }
                
            }
            
        }
        else if ([rowModel.type isEqualToString:@"sinfo_feed"]) {
            //show overview
            NSString* url =  [[STRequestsHandler sharedInstance] buildUrl:rowModel.detailsUrl withParameters:nil forPage:0];
            NSDictionary *viewControllerItems = [[STAppSettingsManager sharedSettingsManager] viewControllerItems];
            NSString* key = [viewControllerItems allKeys][1];
            STViewControllerItem *viewControllerItem = [viewControllerItems objectForKey:key];
            STStadtInfoOverviewViewController* overview = [[STStadtInfoOverviewViewController alloc] initWithUrl:url title:rowModel.title];
            overview.ignoreFavoritesButton = YES;
            [self loadViewController:overview withViewControllerItem:viewControllerItem];
        }
        else {
            BOOL collapsed  = [[arrayForBool objectAtIndex:indexPath.section] boolValue];
            collapsed       = !collapsed;
            [arrayForBool replaceObjectAtIndex:indexPath.section withObject:[NSNumber numberWithBool:collapsed]];
            
            //insert rows into specific section animated
            NSRange range   = NSMakeRange(indexPath.section, 1);
            NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
            [self.firstsideMenuTable reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
            //if we expand we should scroll to position
            if (collapsed) {
                [self.firstsideMenuTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
        }
    }
    
}

#pragma mark - UITableView delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //fallback case for submenu items
    NSArray * dataArray = [self menuDataArrayForTableView:self.firstsideMenuTable];
    STRightMenuItemsModel *rowModel = ((STRightMenuItemsModel*)dataArray[indexPath.section]).children[indexPath.row];
    if ([rowModel.type isEqualToString:@"website"]) {
        [self showWebViewFor:rowModel.detailsUrl];
    }
    
    else if ([rowModel.type isEqualToString:@"sinfo_feed"]) {
        //show overview
        NSString* url =  [[STRequestsHandler sharedInstance] buildUrl:rowModel.detailsUrl withParameters:nil forPage:0];
        NSDictionary *viewControllerItems = [[STAppSettingsManager sharedSettingsManager] viewControllerItems];
        NSString* key = [viewControllerItems allKeys][1];
        STViewControllerItem *viewControllerItem = [viewControllerItems objectForKey:key];
        STStadtInfoOverviewViewController* overview = [[STStadtInfoOverviewViewController alloc] initWithUrl:url title:rowModel.title];
        overview.ignoreFavoritesButton = YES;
        [self loadViewController:overview withViewControllerItem:viewControllerItem];
    }
    
    else {
        [self requestDetailedDataForItem:rowModel.detailsUrl];
    }
    
    
    
}

-(void)showWebViewFor:(NSString*)detailUrl {
    
    //show web view
    STWebViewDetailViewController *webPage = [[STWebViewDetailViewController alloc] initWithNibName:@"STWebViewDetailViewController" bundle:nil andDetailUrl:detailUrl];
    [self.rightSideMenuDelegate loadRightViewController:webPage animated:YES withNavigationBarBarTintColor:nil andTintColor:nil translucent:NO barStyle:UIBarStyleDefault];
    [self.revealViewController rightRevealToggleAnimated:YES];
}



-(void)requestDetailedDataForItem:(NSString*)detailsUrl {
    
    //request the detailed data for item
    __block STDetailGenericModel* detailData = [[STDetailGenericModel alloc] init];
    [[STRequestsHandler sharedInstance] itemDetailsForURL:detailsUrl completion:^(STDetailGenericModel *itemDetails,NSDictionary* itemResponseDict, NSError *error) {
        detailData = itemDetails;
        detailData.menuOrientationLeft = NO;
        //present detail screen
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentDetailScreenWithData:detailData];
        });
    }];
}

-(void)presentDetailScreenWithData:(STMainModel*)detailData{
    NSDictionary *viewControllerItems = [[STAppSettingsManager sharedSettingsManager] viewControllerItems];
    
    NSString* key = [viewControllerItems allKeys][1];
    STViewControllerItem *viewControllerItem = [viewControllerItems objectForKey:key];
    
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
    
    UIViewController* vc = [[STDetailViewController alloc] initWithNibName:@"STDetailViewController" bundle:nil andDataModel:detailData];
    
    [self.rightSideMenuDelegate loadRightViewController:vc animated:YES withNavigationBarBarTintColor:barTintColor andTintColor:tintColor translucent:translucent barStyle:barStyle];
    
    
    [self.revealViewController rightRevealToggleAnimated:YES];
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
    
    [self.rightSideMenuDelegate loadRightViewController:newViewController animated:YES withNavigationBarBarTintColor:barTintColor andTintColor:tintColor translucent:translucent barStyle:barStyle];
    [self.revealViewController rightRevealToggleAnimated:YES];
}

#pragma Overridden methods
-(int)leftSideTablesOffset {
    return 0;
}

@end

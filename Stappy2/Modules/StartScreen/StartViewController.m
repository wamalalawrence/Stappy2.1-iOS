//
//  StartViewController.m
//  Stappy2
//
//  Created by Cynthia Codrea on 09/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "StartViewController.h"
#import "STStartScreenCollectionViewCell.h"
#import "STStartScreenScrollCollectionViewCell.h"
#import "STStartScreenBottomCollectionViewCell.h"
#import "STWebViewDetailViewController.h"
#import "STAppSettingsManager.h"
#import "STTankStationsViewController.h"
#import "STDetailViewController.h"

//#import "NSBundle+DKHelper.h"
#import "STViewControllerItem.h"

//network imports
#import "STRequestsHandler.h"

#import "AppDelegate.h"

//categories
#import "UIColor+STColor.h"
#import <SDWebImage/UIImageView+WebCache.h>


//models
#import "STMainModel.h"
#import "STWeatherCurrentObservation.h"
#import "STViewControllerNavigationBarStyle.h"
#import "Utils.h"
#import "NSString+Utils.h"
#import "SidebarViewController.h"
#import "STWeatherService.h"
#import "STDetailGenericModel.h"
#import "STStartModel.h"

static NSString * const startCollectionHeaderViewIdentifier = @"STStartScreenHeaderView";
static NSString * const kFahrPlanViewControlerId = @"STFahrplanSearchVC";


@interface StartViewController ()

@property(nonatomic, strong)NSArray* allKeysOfStartData;
@property(nonatomic, strong)NSDictionary* allKeysForScrollActions;
@property(nonatomic, strong)NSDictionary* allKeysForBottomActions;
@property(nonatomic, weak)IBOutlet UIImageView* weatherIconImageView;

//suewag hack :(
@property(nonatomic, assign)BOOL shouldShowLabelsAndCollectionOnStartScreen;


@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib * nib = [UINib nibWithNibName:@"STStartScreenCollectionViewCell" bundle:nil];
    [self.startCollectionView registerNib:nib forCellWithReuseIdentifier:@"startCell"];
    
    UINib * nibScroll = [UINib nibWithNibName:@"STStartScreenScrollCollectionViewCell" bundle:nil];
    [self.startCollectionView registerNib:nibScroll forCellWithReuseIdentifier:@"startScrollCell"];
    
    UINib * nibBottom = [UINib nibWithNibName:@"STStartScreenBottomCollectionViewCell" bundle:nil];
    [self.startCollectionView registerNib:nibBottom forCellWithReuseIdentifier:@"startBottomCell"];
    
    self.allKeysForScrollActions = [STAppSettingsManager sharedSettingsManager].startScreenScrollActions;

    self.allKeysForBottomActions = [STAppSettingsManager sharedSettingsManager].startScreenBottomActions;
    
    UINib *sectionHeaderNib = [UINib nibWithNibName:@"STStartScreenHeaderView" bundle:nil];
    [self.startCollectionView registerNib:sectionHeaderNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:startCollectionHeaderViewIdentifier];
    
   
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];

    UIFont *startLocationFont = [settings customFontForKey:@"startscreen.startLocation.font"];
    
    if (startLocationFont) {
        self.startLocationLabel.font = startLocationFont;
        self.startTemperatureLabel.font = startLocationFont;
    }
    
    
    
    self.shouldShowLabelsAndCollectionOnStartScreen = settings.shouldShowLabelsAndCollectionOnStartScreen;
    
    self.startCollectionView.allowsSelection = NO;
    self.startCollectionView.scrollEnabled = YES;
    //request data for start page
    if (!self.startCollectionDataArray) {
        [self loadStartData];
    }
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateDateAndTitle];
    
    //just to be sure it gets called all the time
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(updateDateAndTitle)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)updateDateAndTitle{
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EE dd.MM."];
    
    NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
    
    //get city name from the bundle identifier
    NSString* cityName = [[STAppSettingsManager sharedSettingsManager] homeScreenTitle];
    if (cityName.length == 0) {
        cityName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    }
    
    if (settings.showCityName) {
        self.startLocationLabel.text = [NSString stringWithFormat:@"%@, %@",[cityName splitString:cityName],stringFromDate];
        
    }
    else{
        [formatter setDateFormat:@"EEEE"];
        NSString*dayName = [formatter stringFromDate:[NSDate date]];
        dayName = [dayName substringToIndex:2];
        
        [formatter setDateFormat:@"dd.MM."];
        stringFromDate = [NSString stringWithFormat:@"%@. %@",dayName, [formatter stringFromDate:[NSDate date]]];
        self.startLocationLabel.text = [NSString stringWithFormat:@"%@",stringFromDate];
        
    }
}

-(void)loadStartData {
    __weak typeof(self) weakSelf = self;
    
    [[STRequestsHandler sharedInstance] startScreenDataWithUrl:@"/start-v2" completion:^(NSArray* dataArray, NSArray* keysArray, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        NSMutableArray *nonEmptyData = [NSMutableArray array];
        NSMutableArray *nonEmptyKeys = [NSMutableArray array];

        //remove empty entries
        for (int i = 0; i < [dataArray count]; i++) {
            NSArray * data = [dataArray objectAtIndex:i];
            if (data.count > 0) {
                [nonEmptyData addObject:data];
                [nonEmptyKeys addObject:[keysArray objectAtIndex:i]];
            }
        }

        self.allKeysOfStartData = nonEmptyKeys;
        
        
        strongSelf.startCollectionDataArray = nonEmptyData;
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.sideMenuDelegate refreshFramesForStartCollectionCells];
            [self.startCollectionView reloadData];
        });
    }failure:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hinweis" message:@"Keine Internetverbindung." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    } ];
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"weather_icons" ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:path];
    NSDictionary* weatherDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
   NSDictionary*weatherDictionary = [weatherDict objectForKey:@"match_icons_condition"];

   
    
    [[STWeatherService sharedInstance] weatherForStartScreenWithCompletion:^(STWeatherCurrentObservation *currentObservation, NSError *error) {
        if (!error) {
            _startTemperatureLabel.text = [NSString stringWithFormat:@"%i°C", currentObservation.temperature];
            
            NSString *imageUrl = currentObservation.imageUrl;
            NSString* imageName = weatherDictionary[[NSString stringWithFormat:@"%@",currentObservation.icon]];
            UIImage * conditionsImage = [UIImage imageNamed:imageName];
            if (!conditionsImage) {
                [self.weatherIconImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
            } else {
                self.weatherIconImageView.image = conditionsImage;
            }

            
        }
    }];
}

#pragma mark - UICollectionView data source

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.shouldShowLabelsAndCollectionOnStartScreen) {
        return [self.startCollectionDataArray count] + 2;
    }
    return [self.startCollectionDataArray count] + 1;

}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView * headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:startCollectionHeaderViewIdentifier forIndexPath:indexPath];
    return headerView;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.shouldShowLabelsAndCollectionOnStartScreen) {
        
        if (indexPath.row == [self.startCollectionDataArray count]) {
            static NSString *cellScrollIdentifier = @"startScrollCell";
            STStartScreenScrollCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellScrollIdentifier forIndexPath:indexPath];
            cell.startCellCollectionDelegate = self;
            return cell;
        }
        else if (indexPath.row == [self.startCollectionDataArray count] + 1) {
            static NSString *cellBottomIdentifier = @"startBottomCell";
            STStartScreenBottomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellBottomIdentifier forIndexPath:indexPath];
            cell.startCellCollectionDelegate = self;
            
            return cell;
        }
        
    }
    else{
        
        if (indexPath.row == [self.startCollectionDataArray count]) {
            static NSString *cellBottomIdentifier = @"startBottomCell";
            STStartScreenBottomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellBottomIdentifier forIndexPath:indexPath];
            cell.startCellCollectionDelegate = self;
            
            return cell;
        }
  
    }

    
    
   
        static NSString *cellIdentifier = @"startCell";
        STStartScreenCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        NSString* categoryName = self.allKeysOfStartData[indexPath.row];
    
        if ([categoryName isEqualToString:@"angebote"]) {
            cell.isOffer = YES;
        }
        
        NSDictionary * otherNamings= [STAppSettingsManager sharedSettingsManager].startScreenOtherNamings;
     
       cell.categoryLabel.attributedText = [Utils text:[categoryName uppercaseString] withSpacing:2];
        
        
        for (NSString* key in [otherNamings allKeys]){
            if ([key isEqualToString:categoryName]) {
                cell.categoryLabel.attributedText =  [Utils text:[otherNamings[key] uppercaseString] withSpacing:2];
                break;
            }
        }
        cell.categoryLabel.textColor = [UIColor textsColor];
        UIImage* categoryImage = [UIImage imageNamed:categoryName];
        if (!categoryImage) {
            categoryImage = [UIImage imageNamed:[categoryName capitalizedString]];
        }
        categoryImage = [categoryImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        // get custom icons if there are needed
        NSDictionary * otherIcons= [STAppSettingsManager sharedSettingsManager].startScreenOtherIcons;

        if (otherIcons.count) {
            NSString *newCategoryName = [otherIcons valueForKey:categoryName];
          
            
            if (newCategoryName) {
                  categoryImage = [[UIImage imageNamed:newCategoryName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }

        }
        cell.categoryImageView.image = categoryImage;
        cell.categoryImageView.tintColor = [UIColor startScreenIconColor];
        cell.dataForItemsTable = self.startCollectionDataArray[indexPath.row];
        cell.overviewButton.tag = indexPath.row;
        cell.cellIndexPath = indexPath;
        cell.startCellCollectionDelegate = self;
        cell.categoryLabel.textAlignment = NSTextAlignmentCenter;
    
    if (!self.shouldShowLabelsAndCollectionOnStartScreen) {
        cell.categoryLabel.hidden = YES;
        cell.iconTopConstraint.constant = 31;
    }
    
        [cell.categoryItemsCollection reloadData];
        return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int dataSourceCount = (int)self.startCollectionDataArray.count;
    
    if (indexPath.row == dataSourceCount) {
        return CGSizeMake(collectionView.frame.size.width - 20, 80.f);
    }
    
    return CGSizeMake(collectionView.frame.size.width - 20, 94.f);
}

// MARK:
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - collection protocol methods

-(void)showDetailScreenForItem:(STStartModel *)item {
    
    //TODO for later: create factory for this method
    
    STMainModel* detailData = ((STMainModel*)item);
    if ([detailData.url hasSuffix:@".json"]) { // Fix for DTS Feed. In JSON for DTS type is website, even though the url/link is ending with .json
        // and should be shown in the DetailViewController
        [[STRequestsHandler sharedInstance] itemDetailsForURL:detailData.url completion:^(STDetailGenericModel *itemDetails,NSDictionary* itemResponseDict, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                STDetailViewController * detailView = [[STDetailViewController alloc] initWithNibName:@"STDetailViewController"                                                                                                                         bundle:nil
                                   andDataModel:itemDetails];
                [self.sideMenuDelegate loadViewController:detailView animated:true];
            });
        }];
    } else if ([detailData.type isEqualToString:@"website"]) {
        STWebViewDetailViewController *webPage = [[STWebViewDetailViewController alloc] initWithNibName:@"STWebViewDetailViewController" bundle:nil andDetailUrl:detailData.url];
        [self.sideMenuDelegate loadViewController:webPage animated:true];
    } else {
        
        
                [[STRequestsHandler sharedInstance] itemDetailsForURL:detailData.url completion:^(STDetailGenericModel *itemDetails,NSDictionary* itemResponseDict, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NSError *mtlError = nil;
                        
                        ((STDetailGenericModel*)itemDetails).isOffer = ((STStartModel*)item).isOffer;
                        STDetailViewController * detailView = [[STDetailViewController alloc] initWithNibName:@"STDetailViewController" bundle:nil andDataModel:detailData];
                        [self.sideMenuDelegate loadViewController:detailView animated:true];
                    });
                }];
        
      
    }

}

-(void)showOverviewForIndex:(NSInteger)index andCellType:(int)type{
    NSString *controllerId;
    
    //STYLING
    NSDictionary *viewControllerItems = [[STAppSettingsManager sharedSettingsManager] viewControllerItems];
    NSArray*allKeys = [viewControllerItems allKeys];
    STViewControllerItem *viewControllerItem = [viewControllerItems objectForKey:allKeys[1]];
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

    NSDictionary *uiStyling = @{
            @"barTintColor": barTintColor,
            @"tintColor": tintColor,
            @"translucent": @(translucent),
            @"barStyle": @(barStyle)
    };

    switch (type) {
        case 1:
            //start request cells
        {
            if (index < self.allKeysOfStartData.count) {
                controllerId = self.allKeysOfStartData[index];
                if ([controllerId isEqualToString:@"stadt"]) {
                    [self.sideMenuDelegate showStadtInfoLeftMenu];
                } else {
                        NSDictionary * otherNamings= [STAppSettingsManager sharedSettingsManager].startScreenOtherNamings;
                        for (NSString* key in [otherNamings allKeys]){
                            if ([key isEqualToString:controllerId]) {
                                controllerId = otherNamings[key];
                                break;
                            }
                    }
                    UIViewController * newViewController = [Utils loadViewControllerWithTitle:controllerId];
                    if (newViewController) {
                   [self.sideMenuDelegate loadViewController:newViewController animated:YES withNavigationBarBarTintColor:barTintColor andTintColor:tintColor translucent:translucent barStyle:barStyle];
                    }
                }
            }
        }
            break;
        case 2: controllerId = self.allKeysForScrollActions[self.allKeysForScrollActions.allKeys[index]];
            //load webview
            if ([controllerId isEqualToString: @"STWebViewDetailViewController"]) {
                STWebViewDetailViewController* webView = [[STWebViewDetailViewController alloc] initWithURL:[STAppSettingsManager sharedSettingsManager].startHomeUrl];
                [self.sideMenuDelegate loadViewController:webView
                                                 animated:YES
                            withNavigationBarBarTintColor:uiStyling[@"barTintColor"]
                                             andTintColor:uiStyling[@"tintColor"]
                                              translucent:((NSNumber *)uiStyling[@"translucent"]).boolValue
                                                 barStyle:((NSNumber *)uiStyling[@"barStyle"]).integerValue];
            }else{
            [self loadViewControllerWithId:controllerId withUIPreferences:uiStyling];
            }
            break;
        case 3:
            //SUEWAG WORKAROUND
            if ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"] isEqualToString:@"Frankfurt"]) {
                [self loadViewControllerWithId:@[@"STWeatherPageViewController",@"StadtInfo",@"RightBarViewController"][index] withUIPreferences:uiStyling]; //bottom quick action buttons
            }
            else{
                [self loadViewControllerWithId:[self.allKeysForBottomActions allKeys][index] withUIPreferences:uiStyling]; //bottom quick action buttons
            }
            break;
        default: break;
    }
}

- (void)loadViewControllerWithId:(NSString *)controllerId withUIPreferences:(NSDictionary *)uiStyling
{
    if ([controllerId isEqualToString:@"StadtInfo"] || [controllerId isEqualToString:@"Meine Stadt"] || [controllerId isEqualToString:@"Ortsinformationen"] || [controllerId isEqualToString:@"Was ist who?"]) {
        [self.sideMenuDelegate showStadtInfoLeftMenu];
    }
    else if ([controllerId isEqualToString:@"RightBarViewController"]) {
        [self.sideMenuDelegate showRightMenu];
    }
    else {
        UIViewController * newViewController = [Utils loadViewControllerWithTitle:controllerId];
        NSDictionary *viewControllerItems = [[STAppSettingsManager sharedSettingsManager] viewControllerItems];

        //WORKAROUND
        NSString*viewControllerIdTranslation;

        if ([controllerId isEqualToString:kFahrPlanViewControlerId]) {
            viewControllerIdTranslation = @"Fahrplan";
            NSString* title = [[STAppSettingsManager sharedSettingsManager].startScreenBottomActions valueForKey:kFahrPlanViewControlerId];
            newViewController.title = title;
        }
        else if ([controllerId isEqualToString:@"Fahrplan"]) {

            if (newViewController == nil) {
                newViewController = [Utils loadViewControllerWithTitle:@"ÖPNV"];
            }

            viewControllerIdTranslation = @"ÖPNV";
            NSString* title = [[STAppSettingsManager sharedSettingsManager].startScreenBottomActions valueForKey:@"Fahrplan"];
            newViewController.title = title;
        }
        else if ([controllerId isEqualToString:@"STWeatherViewController"]) {
            viewControllerIdTranslation = @"Wetter";
        }
        
        else {
            viewControllerIdTranslation = controllerId;
        }
      

        STViewControllerItem *viewControllerItem = [viewControllerItems objectForKey:viewControllerIdTranslation];

        //LIMBURG WORKAROUND
        if ([newViewController isKindOfClass:[STTankStationsViewController class]] && [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"] isEqualToString:@"Limburg"]) {
        
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            STTankStationsViewController *stationsController = (STTankStationsViewController*)[storyboard instantiateViewControllerWithIdentifier:@"Tank"];
            stationsController.stationsId = @"80451";
            
            newViewController = stationsController;
            newViewController.title = viewControllerItem.key;
            
        }

        if ([newViewController isKindOfClass:[STWebViewDetailViewController class]]) {
            newViewController = [[STWebViewDetailViewController alloc] initWithURL:viewControllerItem.url];
            [self.sideMenuDelegate loadViewController:newViewController
                                             animated:YES
                        withNavigationBarBarTintColor:uiStyling[@"barTintColor"]
                                         andTintColor:uiStyling[@"tintColor"]
                                          translucent:((NSNumber *)uiStyling[@"translucent"]).boolValue
                                             barStyle:((NSNumber *)uiStyling[@"barStyle"]).integerValue];
        } else {
            [self.sideMenuDelegate loadViewController:newViewController
                                             animated:YES
                    withNavigationBarBarTintColor:uiStyling[@"barTintColor"]
                                     andTintColor:uiStyling[@"tintColor"]
                                      translucent:((NSNumber *)uiStyling[@"translucent"]).boolValue
                                         barStyle:((NSNumber *)uiStyling[@"barStyle"]).integerValue];
        }
    }
}

@end

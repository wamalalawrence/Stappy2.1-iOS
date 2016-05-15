//
//  STStadtInfoOverviewViewController.m
//  Stappy2
//
//  Created by Cynthia Codrea on 25/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STStadtInfoOverviewViewController.h"
#import "STStadtInfoTableViewCell.h"
#import "STRequestsHandler.h"
#import "STItemDetailsModel.h"
#import "STNewsAndEventsDetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <CoreLocation/CoreLocation.h>
#import "STStadtInfoHeader.h"
#import "STAnnotationsMapViewController.h"
#import "OpeningClosingTimeModel.h"

//helpers
#import "NSDate+DKHelper.h"
#import "NSDate+Utils.h"
#import "UIImage+tintImage.h"
#import "UIColor+STColor.h"
#import "STAppSettingsManager.h"

static NSString* kStadtInfoCellIdentifier = @"stadtInfoCell";
static NSString* kStadtInfoHeaderIdentifier = @"stadtInfoHeader";

@interface STStadtInfoOverviewViewController ()
@property(nonatomic,strong)NSString* url;
@property(nonatomic,strong)NSMutableArray* mapLocations;
@property(nonatomic,assign)BOOL isSortingEnabled;
@property(nonatomic,assign)BOOL isOpeningTimesEnabled;

@end

@implementation STStadtInfoOverviewViewController

- (instancetype)initWithUrl:(NSString *)url title:(NSString *)title {
    if (self = [super initWithNibName:@"STStadtInfoOverviewViewController" bundle:nil]) {
        _url = url;
        self.title = title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *sortingFont = [settings customFontForKey:@"stadtinfos.cell.sortOptionsFont"];
    
    if (sortingFont) {
        [self.geoffneteButton.titleLabel setFont:sortingFont];
        [self.leftHeaderButton.titleLabel setFont:sortingFont];
    }
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    { [self.locationManager requestWhenInUseAuthorization]; }
    
    [self.locationManager startUpdatingLocation];
    
    UINib *nib = [UINib nibWithNibName:@"STStadtInfoTableViewCell" bundle:nil];
    [self.overviewTable registerNib:nib forCellReuseIdentifier:kStadtInfoCellIdentifier];
    
    UINib *sectionHeaderNib = [UINib nibWithNibName:@"STStadtInfoHeader" bundle:nil];
    [self.overviewTable registerNib:sectionHeaderNib forHeaderFooterViewReuseIdentifier:kStadtInfoHeaderIdentifier];
    
    [self requestData];
    
    self.overviewTable.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.leftHeaderButton.layer.borderWidth = 1.0f;
    self.geoffneteButton.layer.borderWidth = 1.0f;
    self.geoffneteButton.layer.borderColor = [UIColor clearColor].CGColor;
    self.leftHeaderButton.layer.borderColor = [UIColor clearColor].CGColor;
//    [self venAbiZButtonPressed:self.leftHeaderButton];
}

-(void)requestData {
    
    //request the data for the overview table
    __weak typeof(self) weakself = self;
    [[STRequestsHandler sharedInstance] allStadtInfoOverviewItemsWithUrl:self.url andCompletion:^(NSArray *overviewItems, NSError *error) {
        __strong typeof(weakself) strongSelf = weakself;
        strongSelf.overViewItems = overviewItems;
        strongSelf.backupOverviewItems = overviewItems;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.overviewTable reloadData];
        });
    }];
}

#pragma mark - Table View data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.overViewItems count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    STStadtInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kStadtInfoCellIdentifier];
    STItemDetailsModel *model = ((STItemDetailsModel*)(self.overViewItems[indexPath.row]));
    
    //calculate distance from location
    CLLocation *current = [[CLLocation alloc] initWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude];

    CLLocation *itemLoc = [[CLLocation alloc] initWithLatitude:[model.latitude doubleValue] longitude:[model.longitude doubleValue]];

    //get distance from current position in km
    CLLocationDistance itemDist = [itemLoc distanceFromLocation:current] / 1000.0;
    NSString *distanceString = [[NSString alloc] initWithFormat: @"%.01f km", itemDist];
    cell.distance.text = [distanceString stringByReplacingOccurrencesOfString:@"." withString:@","];
    
    //calculate remaining opening time
    if (model.openinghours2 != nil) {
        //get day of the week
        NSInteger day = [[NSDate date] dayOfTheWeek];
        OpeningClosingTimesModel* closingTimes = (OpeningClosingTimesModel*)(model.openinghours2[0]);
        NSArray<OpeningClosingTimeModel *> *remainingTimeModelArray = [closingTimes openingHoursForDay:day];
        
        BOOL isOpened = NO;
        for (OpeningClosingTimeModel *timeModel in remainingTimeModelArray) {
            if (timeModel.remainingOpeningHours > 0) {
                cell.openingTime.text = [NSString stringWithFormat:@"%ld Std %ld min", (long)timeModel.remainingOpeningHours,
                                                                                       (long)timeModel.remainingOpeningMinutes];
                isOpened = YES;
            } else if (timeModel.remainingOpeningHours == 0 && timeModel.remainingOpeningMinutes > 0) {
                cell.openingTime.text = [NSString stringWithFormat:@"%ld min", (long)timeModel.remainingOpeningMinutes];
                isOpened = YES;
            }
        }
        
        model.isOpen = isOpened;
        
        if (isOpened) {
            UIImage* openingImage = [[UIImage imageNamed:@"OpeningIcon"] imageTintedWithColor:[UIColor partnerColor]];
            cell.closingOpeningIcon.image = openingImage;
            cell.openingTime.textColor = [UIColor partnerColor];
        } else {
            cell.closingOpeningIcon.image = [UIImage imageNamed:@"ClosingIcon"];
            cell.openingTime.text = @"Geschlossen";
            cell.openingTime.textColor = [UIColor whiteColor];
        }
    } else {
        /**
         * reset the icon and openingTimeLabel. This will be needed when we use VonZBisA-Sort
         * we reload the tableView after reordering, but the data in the cell won't be reseted
         * so the cell will contain the data, from the previous model, what is no good
         */
        cell.closingOpeningIcon = nil;
        cell.openingTime.text = @"";
    }
    
    cell.title.text = model.title;
    NSURL *imageUrl;
    if (model.image != nil && model.image.length > 0) {
        if ([[model.image substringToIndex:1] isEqualToString:@"/"]) {
            //build image url
           imageUrl = [[STRequestsHandler sharedInstance] buildImageUrl:model.image];
        }
        else {
            imageUrl = [NSURL URLWithString:model.image];
        }
    }
    [cell.cityInfoImage sd_setImageWithURL:imageUrl  placeholderImage:[UIImage imageNamed:@"image_content_article_default_thumb"]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //show details of the selected item
    STMainModel* mainModel = (STMainModel*)(self.overViewItems[indexPath.row]);
    STNewsAndEventsDetailViewController * detailView = [[STNewsAndEventsDetailViewController alloc] initWithNibName:@"STNewsAndEventsDetailViewController"
                                                                                                             bundle:nil
                                                                                                       andDataModel:mainModel];
    detailView.ignoreFavoritesButton = self.ignoreFavoritesButton;
    [self.navigationController pushViewController:detailView animated:YES];
}

- (IBAction)venAbiZButtonPressed:(UIButton *)sender {
    if (!self.isSortingEnabled) {
        self.leftHeaderButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.isSortingEnabled = YES;
        //sort from Z to A
        self.overViewItems = [self.overViewItems sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSString *first = [(STItemDetailsModel*)a title];
            NSString *second = [(STItemDetailsModel*)b title];
            return [second compare:first];
        }];
        [self.overviewTable reloadData];

    }
    else {
    self.leftHeaderButton.layer.borderColor = [UIColor clearColor].CGColor;
        self.isSortingEnabled = NO;
        //sort from A to Z
        self.overViewItems = [self.overViewItems sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSString *first = [(STItemDetailsModel*)a title];
            NSString *second = [(STItemDetailsModel*)b title];
            return [first compare:second];
        }];
        [self.overviewTable reloadData];
    }
}

- (IBAction)geoffneteButtonPressed:(UIButton *)sender {
    if (!self.isOpeningTimesEnabled) {
        self.geoffneteButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.isOpeningTimesEnabled = YES;
        //show opened items
        NSMutableArray* openedItems = [NSMutableArray array];
        for (STItemDetailsModel* model in self.overViewItems) {
            if (model.isOpen
                ) {
                [openedItems addObject:model];
            }
            self.overViewItems = [NSArray arrayWithArray:openedItems];
            [self.overviewTable reloadData];
        }
            }
    else {
    self.geoffneteButton.layer.borderColor = [UIColor clearColor].CGColor;
        self.isOpeningTimesEnabled = NO;
        //show all items
        self.overViewItems = self.backupOverviewItems;
        [self.overviewTable reloadData];
    }
}

- (IBAction)mapButtonPressed:(UIButton *)sender {
    STAnnotationsMapViewController *mapVC = [[STAnnotationsMapViewController alloc] initWithData:self.backupOverviewItems];
    mapVC.ignoreFavoritesButton = self.ignoreFavoritesButton;
    [self.navigationController pushViewController:mapVC animated:YES];
}

#pragma Location Delegate methods

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    [self.overviewTable reloadData];
}

@end

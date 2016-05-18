//
//  STLokalNewsViewController.m
//  Stappy2
//
//  Created by Cynthia Codrea on 20/10/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STLokalNewsViewController.h"
#import "SWRevealViewController.h"
#import "STNewsBaseTableViewCell.h"
#import "STRequestsHandler.h"
#import "STDataManager.h"
#import "STNewsTableCellCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "STNewsModel.h"
#import "STTableMainKeyObject.h"
#import "STTableSecondaryKeyObject.h"
#import "STNewsBaseExpandedTableViewCell.h"
#import "STWebViewDetailViewController.h"
#import "STNewsAndEventsDetailViewController.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "STLokalNewsHeaderView.h"
#import "Utils.h"
#import "STExpandedTableTopObject.h"
#import "STExpandedTableBottomObject.h"
#import "STMainModel.h"
#import "STAngeboteModel.h"
#import "TargetConditionals.h"
#import "STWeatherCurrentObservation.h"
#import "STEventsViewController.h"
#import "STWeatherModel.h"
#import "STAngeboteViewController.h"
#import "Defines.h"
#import "STAppSettingsManager.h"
#import "STWerbungModel.h"
#import "STWerbungTableViewCell.h"
#import "STAnnotationsMapViewController.h"
#import "RandomImageView.h"

@interface STLokalNewsViewController ()

@property (nonatomic,strong) STTableMainKeyObject* secondaryKeyGroupedData;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
@property(nonatomic,strong)NSString* currentWeather;
@property(nonatomic, strong)NSString* currentWeatherImage;
@property(nonatomic, strong)NSArray *nextDaysForecasts;
@property(nonatomic, strong)NSDictionary *weatherDictionary;
@property(nonatomic, strong)NSString* currentImageUrl;
@property(nonatomic, strong)NSArray* werbungItems;
@property(nonatomic, strong)STWerbungModel* werbungItem;

@end

@implementation STLokalNewsViewController

- (NSString *)filterType { return @"lokalnews"; }

#pragma mark - NSNotificationCenter filters update

- (NSString *)notificationCenterFilterChangeKey
{ return [NSString stringWithFormat:@"%@_%@",kFiltersUpdateNotificationKey, self.filterType]; }

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:self.notificationCenterFilterChangeKey
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification)
    {
        [self loadNews];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadNews)
                                                 name:kWerbungMenuNotificationKey object:nil];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:self.notificationCenterFilterChangeKey object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kWerbungMenuNotificationKey object:nil];

}

#pragma mark -

-(void)loadView {
    
    [super loadView];
    
    self.contentOffsetDictionary = [NSMutableDictionary dictionary];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = false;
    self.backgroundBlured.needsBlur = YES;
    
    
    __weak typeof(self) weakself = self;
    [[STRequestsHandler sharedInstance] weatherForStartScreenWithCompletion:^(STWeatherCurrentObservation *currentObservation, NSError *error) {
        if (!error) {
            __strong typeof(weakself) strongSelf = weakself;
            strongSelf.currentWeather  = [NSString stringWithFormat:@"%i°C", currentObservation.temperature];
            strongSelf.currentWeatherImage = currentObservation.icon;
            strongSelf.currentImageUrl = currentObservation.imageUrl;
            [strongSelf.lokalNewsTable reloadData];
        }
    }];
    if ([self isKindOfClass:[STEventsViewController class]]) {
        //get complete forecast
        __weak typeof(self) weakself = self;
        [[STRequestsHandler sharedInstance] weatherForCurrentDayAndForecastWithCompletion:^(NSArray *hourlyWeatherArray, NSArray *nextDaysForecastArray, STWeatherCurrentObservation* observation,NSError *hourlyError, NSError *daysError) {
            
            if (!daysError) {
                __strong typeof(weakself) strongSelf = weakself;
                strongSelf.nextDaysForecasts = nextDaysForecastArray;
                [strongSelf.lokalNewsTable reloadData];
            }
            
         
        }];

    }
    //load the weather configuration file
    NSString* path = [[NSBundle mainBundle] pathForResource:@"weather_icons" ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:path];
    NSDictionary* weatherDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    self.weatherDictionary = [weatherDict objectForKey:@"match_icons_condition"];
    
    UINib *sectionHeaderNib = [UINib nibWithNibName:@"STLokalNewsHeaderView" bundle:nil];
    [self.lokalNewsTable registerNib:sectionHeaderNib forHeaderFooterViewReuseIdentifier:kNewsTableViewHeaderID];
    
    UINib *expandedHeaderNib = [UINib nibWithNibName:@"ExpandedTopTableViewCell" bundle:nil];
    [self.lokalNewsTable registerNib:expandedHeaderNib forCellReuseIdentifier:kBaseNewsTableExpandedHeaderID];
    
    UINib *nib = [UINib nibWithNibName:@"STNewsBaseTableViewCell" bundle:nil];
    [[self lokalNewsTable] registerNib:nib forCellReuseIdentifier:kBaseNewsTableCellIdentifier];
    
    UINib *nibExpanded = [UINib nibWithNibName:@"STNewsBaseExpandedTableViewCell" bundle:nil];
    [[self lokalNewsTable] registerNib:nibExpanded forCellReuseIdentifier:kBaseNewsTableExpandedCellIdentifier];
    
    UINib *nibExpandedBottom = [UINib nibWithNibName:@"ExpandedBottomTableViewCell" bundle:nil];
    [[self lokalNewsTable] registerNib:nibExpandedBottom forCellReuseIdentifier:kBaseNewsTableExpandedBottomCellIdentifier];
    
    UINib *nibWerbungTableCell = [UINib nibWithNibName:@"STWerbungTableViewCell" bundle:nil];
    [[self lokalNewsTable] registerNib:nibWerbungTableCell forCellReuseIdentifier:kSTWerbungTableViewCell];

    self.currentPage = 1;
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle:)];
        
        [self.rightBarButton setTarget: self.revealViewController];
        [self.rightBarButton setAction: @selector(rightRevealToggle:)];
    }
    self.lokalNewsTable.separatorStyle = UITableViewCellSelectionStyleNone;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setTintColor:[UIColor whiteColor]];
    [self.refreshControl addTarget:self action:@selector(loadNews) forControlEvents:UIControlEventValueChanged];
    [self.lokalNewsTable addSubview:self.refreshControl];
    
    // create parameters dictioanry
    self.parameters = [NSMutableDictionary dictionary];
    [self.parameters addEntriesFromDictionary:@{@"page":@(self.pageCount)}];
    
    [self loadNews];
    self.lokalNewsTable.backgroundColor= [UIColor clearColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

-(void)loadMoreNews {
    //if we reached the end of data stop indicator and return
    if (self.currentPage == self.pageCount) {
        [self.lokalNewsTable.infiniteScrollingView stopAnimating];
        return;
    }
    self.currentPage += 1;
    self.parameters[@"page"] = @(self.currentPage);
    //request data for the next page
    __weak  typeof(self) weakSelf = self;
    [[STRequestsHandler sharedInstance] allLokalnewsWithUrl:@"/lokalnews-v2"
                                                     params:self.parameters
                                                       type:@"Lokalnews"
                                              andCompletion:^(NSArray *news, NSArray *originalNews, NSUInteger pageCount, NSError *error) {
                                                  __strong typeof(weakSelf) strongSelf = weakSelf;
                                                  [strongSelf.originalFetchedNews addObjectsFromArray:originalNews];
                                                  //call method to group the data and reload the table
                                                  [strongSelf populateWithNextPageWithPageElements:self.originalFetchedNews];
                                              }];
}

-(void)populateWithNextPageWithPageElements:(NSArray*)elementsArray {
    NSArray *nextPageArrray = [STDataManager groupArrayOfModels:elementsArray];
    self.expandableTableDataArray = [NSMutableArray arrayWithArray:nextPageArrray];
    [self.lokalNewsTable reloadData];
    [self.lokalNewsTable.infiniteScrollingView stopAnimating];
}

-(void)loadWerbung {
    self.werbungItems = [STAppSettingsManager sharedSettingsManager].werbungItems == nil ? @[] : [STAppSettingsManager sharedSettingsManager].werbungItems;
    NSLog(@"%@", self.title);
    for (STWerbungModel * item in self.werbungItems) {
        if ([item.type isEqualToString:[self.title lowercaseString]]) {
            self.werbungItem = [[STWerbungModel alloc] init];
            self.werbungItem = item;
        }
    }
}

- (void)loadNews {
    [self.refreshControl beginRefreshing];
    __weak typeof(self) weakSelf = self;
    [[STRequestsHandler sharedInstance] allLokalnewsWithUrl:@"/lokalnews-v2"
                                                     params:self.parameters
                                                       type:@"Lokalnews"
                                              andCompletion:^(NSArray *news, NSArray *originalNews, NSUInteger pageCount, NSError *error) {
                                                  __strong typeof(weakSelf) strongSelf = weakSelf;
                                                  [strongSelf.refreshControl endRefreshing];
                                                  strongSelf.newsTableDataArray = news;
                                                  strongSelf.pageCount = pageCount;
                                                  if (!strongSelf.originalFetchedNews.count) {
                                                      strongSelf.originalFetchedNews = [NSMutableArray array];
                                                  }
                                                  [strongSelf.originalFetchedNews addObjectsFromArray:originalNews];
                                                  strongSelf.expandableTableDataArray = [NSMutableArray arrayWithArray:news];
                                                  [strongSelf.lokalNewsTable reloadData];
                                                  [self updateHeaders];
                                                  
                                                  [self addInfititeScrolling];

                                                  
                                              }];
    
  
    
}

-(void)addInfititeScrolling{
    __weak typeof(self) weakSelf = self;
    [self.lokalNewsTable addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadMoreNews];
        // call [tableView.infiniteScrollingView stopAnimating] when done
    }];

    
}

#pragma mark - UITableView data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.expandableTableDataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    STTableMainKeyObject *mainKeyObject = self.expandableTableDataArray[section];
    if (!mainKeyObject.expandableSectionItems) {
        mainKeyObject.expandableSectionItems = [NSMutableArray arrayWithArray:mainKeyObject.mainKeyArray];
    }
    NSUInteger count = mainKeyObject.expandableSectionItems.count;
    if (section == 0 && self.werbungItem) {
        count++;
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.werbungItem && indexPath.section == 0 && indexPath.row == 0) {
        return 86.0f;
    } else {
        int rowIndex = indexPath.row;
        if (self.werbungItem && indexPath.section == 0) {
            rowIndex--;
        }
        id currentObjectData = ((STTableMainKeyObject*)self.expandableTableDataArray[indexPath.section]).expandableSectionItems[rowIndex];
        if ([currentObjectData isKindOfClass:[STTableSecondaryKeyObject class]]) {
            return 150.f;
        } else if ([currentObjectData isKindOfClass:[STNewsModel class]]) {
            return 88.f;
        } else if ([currentObjectData isKindOfClass:[STExpandedTableTopObject class]]) {
            return 37.f;
        } else if ([currentObjectData isKindOfClass:[STExpandedTableBottomObject class]]) {
            return 88.f;
        }
    }
    return 95.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60.0f;
}

//add segmented control changing the tables data source to the header view
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    STLokalNewsHeaderView *sectionHeaderView = (STLokalNewsHeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:kNewsTableViewHeaderID];
    if (![sectionHeaderView isKindOfClass:[STLokalNewsHeaderView class]]) {
        return nil;
    }
    sectionHeaderView.weatherIcon.image = nil;
    sectionHeaderView.weatherLabel.text = @"";
    //always reset color
    sectionHeaderView.backgroundContent.backgroundColor = [UIColor clearColor];
    STTableSecondaryKeyObject *secondaryKeyObject = ((STTableMainKeyObject*)self.expandableTableDataArray[section]).mainKeyArray[0];
    STNewsModel * firstNewsModel = secondaryKeyObject.secondaryKeyArray[0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
    NSDate *date = [dateFormatter dateFromString:firstNewsModel.dateToShow];
    [dateFormatter setDateFormat:@"dd.MM."];
    
    BOOL today = [[NSCalendar currentCalendar] isDateInToday:date];
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components: NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear fromDate:date];
    NSDateComponents *todayDay = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear fromDate:[NSDate date]];


    sectionHeaderView.dateLabel.text = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"EEEE"];
    NSString *weekDay = [dateFormatter stringFromDate:date];
    
    //TODO: Please explain why there is this differece between simulator and device?
    //The day of the week is always visible in englich on the device this way.
#if TARGET_IPHONE_SIMULATOR
    sectionHeaderView.weekdayLabel.text = [[Utils weekDays] objectForKey:weekDay];
#else
    sectionHeaderView.weekdayLabel.text = weekDay;
#endif
    
    //add weather information for news entries
    if (today) {
        sectionHeaderView.weatherLabel.text = self.currentWeather;
        
        NSString* imageName = self.weatherDictionary[[NSString stringWithFormat:@"%@",self.currentWeatherImage]];
        UIImage * conditionsImage = [UIImage imageNamed:imageName];
        if (!conditionsImage) {
            [sectionHeaderView.weatherIcon sd_setImageWithURL:[NSURL URLWithString:self.currentImageUrl]];
        } else {
            sectionHeaderView.weatherIcon.image = conditionsImage;
        }
    }
    else {
        //make sure the date is not in the past
        if ([todayDay day] < [otherDay day] &&
            [todayDay month] <= [otherDay month] &&
            [todayDay year] == [otherDay year])
        {
            //check if the date is in next 10 forecasted days, otherwise don't show info
            NSInteger daysDifference = [Utils daysBetweenDate:[NSDate date] andDate:date];
            if ((int)daysDifference < 10) {
                //show future forecast weather
                STWeatherModel* nextForecast = self.nextDaysForecasts[daysDifference +1];
                sectionHeaderView.weatherLabel.text = [NSString stringWithFormat:@"%@°C",nextForecast.tempHigh];
                NSString *imageUrl = nextForecast.imageForecastUrl;
                NSString* imageName = self.weatherDictionary[[NSString stringWithFormat:@"%@",nextForecast.icon]];
                UIImage * conditionsImage = [UIImage imageNamed:imageName];
                if (!conditionsImage) {
                    [sectionHeaderView.weatherIcon sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
                } else {
                    sectionHeaderView.weatherIcon.image = conditionsImage;
                }

            }
        }
    }
    [sectionHeaderView setNeedsDisplay];
    [sectionHeaderView setNeedsLayout];
    
    [self updateHeaders];
    
    CGRect headerFrame = sectionHeaderView.frame;
    headerFrame.size.width = tableView.frame.size.width;
    sectionHeaderView.frame = headerFrame;
    
    return sectionHeaderView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //check if we should show expanded cell or collapsed one
    // Take the oject corresponding to current cell and check its type.
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kBaseNewsTableCellIdentifier];
    if (self.werbungItem && indexPath.section == 0 && indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:kSTWerbungTableViewCell];
        [cell setNeedsLayout];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString* webUrl = nil;
        if ([self.werbungItem.image hasPrefix:@"/"]) {
            webUrl = [[STAppSettingsManager sharedSettingsManager].baseUrl stringByAppendingString:self.werbungItem.image];
        }
        [((STWerbungTableViewCell*)cell).adImageView sd_setImageWithURL:[NSURL URLWithString:webUrl]];
        
        return cell;
    }
    int rowIndex = indexPath.row;
    if (self.werbungItem && indexPath.section == 0) {
        rowIndex--;
    }
    id currentObjectData = ((STTableMainKeyObject*)self.expandableTableDataArray[indexPath.section]).expandableSectionItems[rowIndex];
    
    if ([currentObjectData isKindOfClass:[STTableSecondaryKeyObject class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:kBaseNewsTableCellIdentifier];
        ((STNewsBaseTableViewCell*)cell).delegate = self;
        [(STNewsBaseTableViewCell*)cell updateCellWithDataObject:currentObjectData];
        ((STNewsBaseTableViewCell*)cell).expanded = ((STTableSecondaryKeyObject*)currentObjectData).isRowExpanded;
    } else if ([currentObjectData isKindOfClass:[STMainModel class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:kBaseNewsTableExpandedCellIdentifier];
        STNewsBaseExpandedTableViewCell *expandedCell = (STNewsBaseExpandedTableViewCell*)cell;
        // Load news Cell
        STMainModel *newsModel = (STMainModel*)currentObjectData;
        expandedCell.descriptionLabel.text = newsModel.title;
        expandedCell.delegate = self;
        expandedCell.timeLabel.text = [[newsModel.dateToShow componentsSeparatedByString:@" "] componentsJoinedByString:@"  ·  "];
        NSString * imageUrlString = newsModel.image;
        if ([newsModel.image hasPrefix:@"/"]) {
            imageUrlString = [[STAppSettingsManager sharedSettingsManager].baseUrl stringByAppendingString:newsModel.image];
        }
        NSURL *imageUrl = [NSURL URLWithString:imageUrlString];
        [expandedCell.dataImgeView sd_setImageWithURL:imageUrl  placeholderImage:[UIImage imageNamed:@"image_content_article_default_thumb"]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if ([currentObjectData isKindOfClass:[STExpandedTableTopObject class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:kBaseNewsTableExpandedHeaderID];
        // Load expanded First Cell
    } else if ([currentObjectData isKindOfClass:[STExpandedTableBottomObject class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:kBaseNewsTableExpandedBottomCellIdentifier];
        // Load expanded last Cell
    }
    [cell setNeedsLayout];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(STNewsBaseTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateHeaders];
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Take the oject corresponding to current cell and check its type.
    int rowIndex = indexPath.row;
    if (self.werbungItem && indexPath.section == 0) {
        rowIndex--;
    }
    
    if (self.werbungItem && indexPath.section == 0 && indexPath.row == 0) {
        NSString* url = self.werbungItem.url;
        if (url.length > 0) {
            STWebViewDetailViewController *webPage = [[STWebViewDetailViewController alloc] initWithNibName:@"STWebViewDetailViewController" bundle:nil andDetailUrl:url];
            [self.navigationController pushViewController:webPage animated:YES];
        }
        return;
    }
    
    id currentObjectData = ((STTableMainKeyObject*)self.expandableTableDataArray[indexPath.section]).expandableSectionItems[rowIndex];
    
    if ([currentObjectData isKindOfClass:[STTableSecondaryKeyObject class]]) {

    } else if ([currentObjectData isKindOfClass:[STMainModel class]]) {
        [self onTap:((STMainModel*)currentObjectData)];
    } else if ([currentObjectData isKindOfClass:[STExpandedTableTopObject class]]) {

    } else if ([currentObjectData isKindOfClass:[STExpandedTableBottomObject class]]) {
        // Colapse the cells
        STTableMainKeyObject *mainKeyObject = self.expandableTableDataArray[indexPath.section];
        STExpandedTableBottomObject *colapseObject = (STExpandedTableBottomObject*)currentObjectData;
        NSInteger expandedIndexPath = indexPath.row - colapseObject.expandedObjects.count;
        STTableSecondaryKeyObject *secondaryKeyObject = mainKeyObject.expandableSectionItems[expandedIndexPath];
        if (secondaryKeyObject.isRowExpanded) {
            secondaryKeyObject.isRowExpanded = NO;
            STNewsBaseTableViewCell *expandedCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:expandedIndexPath inSection:indexPath.section]];
            expandedCell.expanded = NO;
        }
        
        [mainKeyObject.expandableSectionItems removeObjectsInArray:colapseObject.expandedObjects];
        [self.lokalNewsTable deleteRowsAtIndexPaths:colapseObject.expandedCellIndexes withRowAnimation:UITableViewRowAnimationTop];
        [self performSelector:@selector(reloadTableDelayed) withObject:nil afterDelay:1.0f];
    }
}

- (void)reloadTableDelayed {
    [self.lokalNewsTable reloadData];
}

#pragma mark - table cell delegate

-(void)onDoubleTap:(STNewsBaseTableViewCell *)sender {
    // insert the cells needed
    NSIndexPath *indexPath = [self.lokalNewsTable indexPathForCell:sender];
    STTableMainKeyObject *mainKeyObject = self.expandableTableDataArray[indexPath.section];
    STTableSecondaryKeyObject *secondaryKeyObject = mainKeyObject.expandableSectionItems[indexPath.row];
    if (![secondaryKeyObject isMemberOfClass:[STTableSecondaryKeyObject class]]) {
        [self colapseRowsAfterIndexPath:indexPath forMainKeyObject:mainKeyObject];
        return;
    }
    if (secondaryKeyObject.isRowExpanded) {
        if (secondaryKeyObject.secondaryKeyArray.count > 1) {
            NSIndexPath * nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
            [self colapseRowsAfterIndexPath:nextIndexPath forMainKeyObject:mainKeyObject];
        }
        return;
    }
    secondaryKeyObject.isRowExpanded = YES;
    sender.expanded = YES;
    NSArray *expandedArray = secondaryKeyObject.expandedObjectsArray;
    NSUInteger count=indexPath.row+1;
    NSMutableArray *arCells=[NSMutableArray array];
    for(NSObject *object in expandedArray ) {
        [arCells addObject:[NSIndexPath indexPathForRow:count inSection:indexPath.section]];
        [mainKeyObject.expandableSectionItems insertObject:object atIndex:count++];
    }
    STExpandedTableBottomObject *colapseObject = expandedArray.lastObject;
    colapseObject.expandedCellIndexes = arCells;
    colapseObject.expandedObjects = expandedArray;
    
    [self.lokalNewsTable insertRowsAtIndexPaths:arCells withRowAnimation:UITableViewRowAnimationTop];
}

- (void)colapseRowsAfterIndexPath:(NSIndexPath*)indexPath forMainKeyObject:(STTableMainKeyObject*) mainKeyObject {
    // If this is no secondary object, then this means that the row is expanded.
    // To close it, find the next STExpandedTableBottomObject in the dataSource and call tableViewCell selected for that one.
    for (int i = indexPath.row; i< mainKeyObject.expandableSectionItems.count; i++ ) {
        id dataObject = mainKeyObject.expandableSectionItems[i];
        if ([dataObject isMemberOfClass:[STExpandedTableBottomObject class]]) {
            NSIndexPath * lasObjectIndexPath = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
            [self tableView:self.lokalNewsTable didSelectRowAtIndexPath:lasObjectIndexPath];
            break;
        }
    }
}

-(void)onTap:(STMainModel *)detailData {
    if ([detailData.url hasSuffix:@".json"]) { // Fix for DTS Feed. In JSON for DTS type is website, even though the url/link is ending with .json
                                               // and should be shown in the DetailViewController
        [[STRequestsHandler sharedInstance] itemDetailsForURL:detailData.url completion:^(STDetailGenericModel *itemDetails, NSDictionary* itemResponseDict, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *mtlError = nil;
                STMainModel *dataModel = [MTLJSONAdapter modelOfClass:[STMainModel class]
                                                              fromJSONDictionary:itemResponseDict
                                                                           error:&mtlError];
                if (!mtlError) {
                    STNewsAndEventsDetailViewController * detailView = [[STNewsAndEventsDetailViewController alloc] initWithNibName:@"STNewsAndEventsDetailViewController"
                                                                                                                             bundle:nil
                                                                                                                       andDataModel:itemDetails];
                    [self.navigationController pushViewController:detailView animated:YES];
                }
            });
        }];
    } else if ([detailData.type isEqualToString:@"website"]) {
            STWebViewDetailViewController *webPage = [[STWebViewDetailViewController alloc] initWithNibName:@"STWebViewDetailViewController" bundle:nil andDetailUrl:detailData.url];
            [self.navigationController pushViewController:webPage animated:YES];
    } else {
        if ([self isKindOfClass:[STAngeboteViewController class]]) {
            [[STRequestsHandler sharedInstance] itemDetailsForURL:detailData.url completion:^(STDetailGenericModel *itemDetails, NSDictionary* itemResponseDict, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSError *mtlError = nil;
                     STAngeboteModel *angeboteModel = [MTLJSONAdapter modelOfClass:[STAngeboteModel class]
                                                       fromJSONDictionary:itemResponseDict
                                                                    error:&mtlError];
                    STNewsAndEventsDetailViewController * detailView = [[STNewsAndEventsDetailViewController alloc] initWithNibName:@"STNewsAndEventsDetailViewController"
                                                                                                                             bundle:nil
                                                                                                                       andDataModel:angeboteModel];
                    detailView.ignoreCalenderButton = YES;
                    [self.navigationController pushViewController:detailView animated:YES];
                });
            }];
        }
        else {
                    STNewsAndEventsDetailViewController * detailView = [[STNewsAndEventsDetailViewController alloc] initWithNibName:@"STNewsAndEventsDetailViewController" bundle:nil andDataModel:detailData];
                    [self.navigationController pushViewController:detailView animated:YES];
        }

    }
}

#pragma mark - Scroll view delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateHeaders];
}

-(void)updateHeaders {
    //get the top most visible table section
    NSArray *visibleCells = [self.lokalNewsTable indexPathsForVisibleRows];
    if (visibleCells.count > 0) {
        NSInteger topSection = [[self.lokalNewsTable indexPathsForVisibleRows].firstObject section];
        NSInteger sectionYOffset = [self.lokalNewsTable rectForHeaderInSection:topSection].origin.y;
        STLokalNewsHeaderView *pinnedHeader = (STLokalNewsHeaderView *)[self.lokalNewsTable headerViewForSection:topSection];
        
        NSLog(@"OFFSET: %f / %f",(self.lokalNewsTable.contentOffset.y - sectionYOffset),self.lokalNewsTable.contentOffset.y);
        
        if ((self.lokalNewsTable.contentOffset.y - sectionYOffset) > 0 || self.lokalNewsTable.contentOffset.y < 5) {
            if (![pinnedHeader isKindOfClass:[STLokalNewsHeaderView class]]) {
                return;
            }
            pinnedHeader.backgroundContent.backgroundColor =    [UIColor colorWithWhite:0 alpha:0.7];
        } else {
            pinnedHeader.backgroundContent.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        }
        if (1 < visibleCells.count && self.lokalNewsTable.contentOffset.y != 0) {
            NSInteger secondSection = [[[self.lokalNewsTable indexPathsForVisibleRows] objectAtIndex:1] section];
            if (secondSection != topSection) {
                STLokalNewsHeaderView *secondHeader = (STLokalNewsHeaderView *)[self.lokalNewsTable headerViewForSection:secondSection];
                if (pinnedHeader != secondHeader) {
                    secondHeader.backgroundContent.backgroundColor = [UIColor clearColor];
                }
            }
        }
    }
}

- (void)mapButtonPressed:(UIButton *)sender {
    //show on map the items in that section
    NSMutableArray* locationToShowArray = [NSMutableArray array];
    NSArray *secondaryOjects = ((STTableMainKeyObject*)self.expandableTableDataArray[sender.tag]).expandableSectionItems;
    for (id obj in secondaryOjects) {
        if ([obj isKindOfClass:[STTableSecondaryKeyObject class]]) {
            [locationToShowArray addObjectsFromArray:((STTableSecondaryKeyObject*)obj).secondaryKeyArray];
        }
    }
    STAnnotationsMapViewController *mapVC = [[STAnnotationsMapViewController alloc] initWithData:locationToShowArray];
    [self.navigationController pushViewController:mapVC animated:YES];
}

@end

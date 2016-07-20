//
//  STFahrplanLocationNameFinderOverlayVC.m
//  Stappy2
//
//  Created by Andrej Albrecht on 20.01.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STFahrplanLocationNameFinderOverlayVC.h"
#import "STAdressSearchResultCellTVC.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "STRequestsHandler.h"
#import "STFahrplanLocation.h"
#import "STFahrplanJourneyPlannerService.h"
#import "STDebugHelper.h"
#import "STAppSettingsManager.h"
#import <CoreLocation/CoreLocation.h>

static NSString *searchResultCellIdentifier = @"STAdressSearchResultCellTVC.Identifier";

@interface STFahrplanLocationNameFinderOverlayVC () <UITableViewDataSource,
                                                        UITableViewDelegate,
                                                        UITextFieldDelegate,
                                                        UIAlertViewDelegate,
                                                CLLocationManagerDelegate>
{
    NSRange previousRange;
    float oldWidth;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSMutableArray *tableDataArray;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) STFahrplanLocation *currentLocation;
@property (strong, nonatomic) NSTimer *timerBeforeStartSearchAfterEnteredString;
@property (strong, nonatomic) NSString *enteredString;
@property (strong,nonatomic) UIRefreshControl *refreshControl;

//FAHRPLAN LOCATION TEST
@property (assign, nonatomic) CLLocationCoordinate2D currentLocationCoordinate;
@property (strong,nonatomic) CLLocationManager *locationManager;

@end

@implementation STFahrplanLocationNameFinderOverlayVC


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    
    [self initStadtwerkLayout];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STAdressSearchResultCellTVC" bundle:nil] forCellReuseIdentifier:searchResultCellIdentifier];
    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    //self.refreshControl.backgroundColor = [UIColor purpleColor];
    [self.refreshControl setTintColor:[UIColor whiteColor]];
    [self.refreshControl tintColorDidChange];
    [self.refreshControl addTarget:self
                            action:@selector(pullToRefreshAction)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    
    self.tableDataArray = [NSMutableArray array];
    
    [self.nextButton setAlpha:0.5];
    
    [self.textField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self addObserver:self forKeyPath:@"currentLocation" options:0 context:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self removeObserver:self forKeyPath:@"currentLocation"];
    
    // [self.delegate locationNameFinderAdressChoosed:self.currentLocation];
    
    [super viewDidDisappear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (self.currentLocation) {
        [self.delegate locationNameFinderAdressChoosed:self.currentLocation];
    }
    
    if (self.locationManager) {
        [self.locationManager stopUpdatingLocation];
        self.locationManager = nil;
    }
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Layout

-(void)initStadtwerkLayout
{
    //Color
    //[self.autocompleteTextField setTextColor:[UIColor partnerColor]];
    
    //Font
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *cellPrimaryFont = [settings customFontForKey:@"fahrplan.location_finder_overlay.primary.font"];
    if (cellPrimaryFont) {
        [self.textField setFont:cellPrimaryFont];
    }
}

#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"currentLocation"]){
        [self updateViews];
    }
}

#pragma mark -
#pragma mark Actions

-(void)pullToRefreshAction
{
    [self.refreshControl endRefreshing];
}

- (IBAction)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionSelectAddress:(id)sender {
    
    [self closeLocationNameFinder];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STAdressSearchResultCellTVC *cell = [self.tableView dequeueReusableCellWithIdentifier:searchResultCellIdentifier];
    
    id object = [self.tableDataArray objectAtIndex:indexPath.row];
    
    if ([object isKindOfClass:[NSString class]]){
        [cell.title setText:object];
    }else if ([object isKindOfClass:[STFahrplanLocation class]]) {
        STFahrplanLocation *locModel = (STFahrplanLocation *) object;
        [cell setLocation:locModel];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath indexPath:%@", indexPath);
    
    id object = [self.tableDataArray objectAtIndex:indexPath.row];
        
    self.currentLocation = object;
    
    [self clearResults];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[[[NSBundle mainBundle] loadNibNamed:@"STAdressSearchResultCellTVC" owner:self options:nil] objectAtIndex:0] bounds].size.height;
}


#pragma mark -
#pragma mark Test

-(void)loadDummyData{
    [self.tableDataArray removeAllObjects];
    [self.tableDataArray addObject:@"Test1"];
    [self.tableDataArray addObject:@"Test2"];
    [self.tableDataArray addObject:@"Test3"];
    [self.tableDataArray addObject:@"Test4"];
    [self.tableDataArray addObject:@"Test5"];
    [self.tableDataArray addObject:@"Test6"];
    [self.tableDataArray addObject:@"Test7"];
    [self.tableDataArray addObject:@"Test8"];
    [self.tableDataArray addObject:@"Test9"];
    [self.tableDataArray addObject:@"Test10"];
    [self.tableDataArray addObject:@"Test11"];
    [self.tableDataArray addObject:@"Test12"];
    [self.tableDataArray addObject:@"Test13"];
    [self.tableDataArray addObject:@"Test14"];
    [self.tableDataArray addObject:@"Test15"];
    [self.tableDataArray addObject:@"Test16"];
    [self.tableDataArray addObject:@"Test17"];
    [self.tableDataArray addObject:@"Test18"];
    [self.tableDataArray addObject:@"Test19"];
    [self.tableDataArray addObject:@"Test20"];
    
    [self.tableView reloadData];
}


#pragma mark - UITextField delegate

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self updateViews];
    
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *enteredString = [NSString stringWithFormat:@"%@%@",textField.text, string];
    
    self.enteredString = enteredString;
    
    if ([enteredString length] >= 2) {
        [self.timerBeforeStartSearchAfterEnteredString invalidate];
        
        self.timerBeforeStartSearchAfterEnteredString = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(searchEnteredLocationName) userInfo:nil repeats:NO];
        
        //[self searchLocationName:enteredString];
    }else{
        [self clearResults];
    }
    
    //previousSearchChangeTime = [NSDate date];
    previousRange = range;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textField resignFirstResponder];
    
    [self.timerBeforeStartSearchAfterEnteredString invalidate];
    [self searchEnteredLocationName];
    
    return YES;
}

#pragma mark - Logic

-(void) searchEnteredLocationName
{
    [self searchLocationName:self.enteredString];
}

-(void)searchLocationName:(NSString*)name
{
    [self.refreshControl beginRefreshing];
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y-self.refreshControl.frame.size.height) animated:YES];
    

    __weak  typeof(self) weakSelf = self;
    
    //FAHRPLAN COORDINATE TEST

    if (!CLLocationCoordinate2DIsValid(self.currentLocationCoordinate)){
        self.currentLocationCoordinate = [STAppSettingsManager sharedSettingsManager].cityLocation;
        
    }
    
    [[STFahrplanJourneyPlannerService sharedInstance] allLocationsForSearchTerm:name coordinate:self.currentLocationCoordinate
                                                onSuccess:^(NSArray *allNearbyLocations) {
    //[[STFahrplanJourneyPlannerService sharedInstance] allLocationsBySearchWithParams:params
    //                                                         onSuccess:^(NSArray *allNearbyLocations) {
                                                             __strong typeof(weakSelf) strongSelf = weakSelf;
                                                             
                                                              if (allNearbyLocations.count > 0) {
                                                                 NSMutableArray *arrfinal=[NSMutableArray array];
                                                                 for (STFahrplanLocation* location in allNearbyLocations) {
                                                                     [arrfinal addObject:location];
                                                                 }
                                                                 strongSelf.tableDataArray = arrfinal;
                                                                 [strongSelf.tableView reloadData];
                                                              }
                                                                 
                                                                 [self.refreshControl endRefreshing];
                                                             } onFailure:^(NSError *error) {
                                                                 if (error) {
                                                                     NSLog(@"ERROR: %@", [error localizedDescription]);
                                                                     
                                                                     if ([error code] == NSURLErrorNotConnectedToInternet) {
                                                                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hinweis" message:@"Keine Internetverbindung." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                                                         [alert show];
                                                                     }else{
                                                                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hinweis" message:@"Adressen können zur Zeit nicht abgefragt werden." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                                                         [alert show];
                                                                     }
                                                                     
                                                                 }
                                                                 [self.refreshControl endRefreshing];
                                                             }];
    
}

-(void)clearResults
{
    self.tableDataArray = nil;
    [self.tableView reloadData];
}

-(void)closeLocationNameFinder
{
    if (self.currentLocation) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        NSLog(@"Notice: Please select an address.");
    }
}

-(void)updateViews
{
    if (self.currentLocation) {
        [self.textField setText:self.currentLocation.locationName];
        [self.textField resignFirstResponder];
        
        [self.nextButton setAlpha:1.0];
    }else{
        [self.nextButton setAlpha:0.5];
    }
}

-(void)dismissKeyboard
{
    [self.textField resignFirstResponder];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.phase == UITouchPhaseBegan) {
        [self.textField resignFirstResponder];
    }
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        [self.locationManager stopUpdatingLocation];
        self.currentLocationCoordinate = currentLocation.coordinate;
    }
}

@end

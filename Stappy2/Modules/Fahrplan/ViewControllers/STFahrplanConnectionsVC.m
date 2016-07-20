//
//  STFahrplanConnectionsVC.m
//  Stappy2
//
//  Created by Andrej Albrecht on 20.01.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STFahrplanConnectionsVC.h"
#import "STFahrplanLocationNameFinderOverlayVC.h"
#import "STFahrplanRouteVC.h"
#import "STConnectionCellTVC.h"
#import "STRequestsHandler.h"
#import "STFahrplanTripModel.h"
#import "STFahrplanSubTripModel.h"
#import "STFahrplanJourneyPlannerService.h"
#import "STFahrplanDatetimeChooserView.h"
#import "STFahrplanDepartureArrivalDisplayView.h"

static NSString *connectionCellIdentifier = @"STConnectionCellTVC.Identifier";

@interface STFahrplanConnectionsVC () <UITableViewDataSource, UITableViewDelegate, STFahrplanDatetimeChooserDelegate, STFahrplanDepartureArrivalDisplayDelegate>
{
    NSString *nameFinderSelection;
    
    float oldHeight;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) STFahrplanJourneyPlannerService *journeyService;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *departureAndArrivalDateTimeChooserContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet STFahrplanDepartureArrivalDisplayView *departureArrivalDisplayView;
@property (weak, nonatomic) IBOutlet STFahrplanDatetimeChooserView *datetimeChooserView;
@property(strong,nonatomic) UIRefreshControl *refreshControl;
@end


@implementation STFahrplanConnectionsVC

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"STFahrplanConnectionsVC viewDidLoad");
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STConnectionCellTVC" bundle:nil] forCellReuseIdentifier:connectionCellIdentifier];
    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    //self.refreshControl.backgroundColor = [UIColor purpleColor];
    [self.refreshControl setTintColor:[UIColor whiteColor]];
    [self.refreshControl tintColorDidChange];
    [self.refreshControl addTarget:self
                            action:@selector(pullToRefreshAction)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl beginRefreshing];
    
    
    self.journeyService = [STFahrplanJourneyPlannerService sharedInstance];
    [self.journeyService setOriginDate:[NSDate date]];
    [self.journeyService updateConnections];
    
    self.datetimeChooserView.delegate = self;
    self.departureArrivalDisplayView.delegate = self;
    
    [self hideUnhideDepartureAndArrivalDateTimeChooserContainerAnimationDuration:0.0];
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[STFahrplanJourneyPlannerService sharedInstance] removeObserver:self];
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[STFahrplanJourneyPlannerService sharedInstance] addObserver:self];
    
    [self updateLabels];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Actions

-(void)pullToRefreshAction
{
    NSLog(@"pullToRefreshAction");
    
    [self.journeyService updateConnections];
}

- (IBAction)actionOpenAdressOverlay:(id)sender {
    NSLog(@"actionOpenAdressOverlayForStart");
    
    nameFinderSelection = @"start";
    
    STFahrplanLocationNameFinderOverlayVC *locationNameFinderVC = [[STFahrplanLocationNameFinderOverlayVC alloc] initWithNibName:@"STFahrplanLocationNameFinderOverlayVC" bundle:nil];
    [locationNameFinderVC setAddress:self.journeyService.originAddress];
    locationNameFinderVC.delegate = self;
    [self presentViewController:locationNameFinderVC animated:YES completion:nil];
}
- (IBAction)actionOpenAddressOverlayForTarget:(id)sender {
    NSLog(@"actionOpenAdressOverlayForStart");
    
    nameFinderSelection = @"target";
    
    STFahrplanLocationNameFinderOverlayVC *locationNameFinderVC = [[STFahrplanLocationNameFinderOverlayVC alloc] initWithNibName:@"STFahrplanLocationNameFinderOverlayVC" bundle:nil];
    [locationNameFinderVC setAddress:self.journeyService.destinationAddress];
    locationNameFinderVC.delegate = self;
    [self presentViewController:locationNameFinderVC animated:YES completion:nil];
}

- (IBAction)openCloseTimeContainer:(id)sender {
    if (self.journeyService.originDate){
        [self.datetimeChooserView setToDeparture];
    }else if (self.journeyService.destinationDate) {
        [self.datetimeChooserView setToArrival];
    }
    
    [self hideUnhideDepartureAndArrivalDateTimeChooserContainerAnimationDuration:0.5];
}


#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.journeyService.connectionsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STFahrplanTripModel *connection = [self.journeyService.connectionsArray objectAtIndex:indexPath.row];
    
    STConnectionCellTVC *cell = [self.tableView dequeueReusableCellWithIdentifier:connectionCellIdentifier];
    [cell setConnection:connection];
    
    /*
    //For Debugging
    if (NO) {
        [cell.departureTimeLabel setText:@"in 6 min"];
        [cell.changeNumberLabel setText:@"2x Umsteigen"];
        [cell.startTimeLabel setText:@"11:39"];
        [cell.durationTimeLabel setText:@"38 min"];
        [cell.targetTimeLabel setText:@"12:17"];
        [cell.startStationNameLabel setText:@"ab Überseequartier"];
        [cell.targetStationNameLabel setText:@"an Bachstrasse 153"];
    }
    */
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    STFahrplanTripModel *connection = [self.journeyService.connectionsArray objectAtIndex:indexPath.row];
    [self.journeyService setSelectedConnection:connection];
    
    
    STFahrplanRouteVC *routeVC = [[STFahrplanRouteVC alloc] initWithNibName:@"STFahrplanRouteVC" bundle:nil];
    routeVC.title = @"ROUTE";
    [self.navigationController pushViewController:routeVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[[[NSBundle mainBundle] loadNibNamed:@"STConnectionCellTVC" owner:self options:nil] objectAtIndex:0] bounds].size.height;
}


#pragma mark - STFahrplanLocationNameFinder delegate

- (void)locationNameFinderAdressChoosed:(STFahrplanLocation *)adress
{
    if ([nameFinderSelection isEqualToString:@"start"]) {
        [self.journeyService setOriginAddress:adress];
        [self.journeyService updateConnections];
        [self.departureArrivalDisplayView.originAddress setText:adress.locationName];
        [self updateStartAddressOnMap];
        
        [self.refreshControl beginRefreshing];
    }else if ([nameFinderSelection isEqualToString:@"target"]) {
        [self.journeyService setDestinationAddress:adress];
        [self.journeyService updateConnections];
        [self.departureArrivalDisplayView.destinationAddress setText:adress.locationName];
        [self updateTargetAddressOnMap];
        
        [self.refreshControl beginRefreshing];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Logic

-(void)updateLabels
{
    if (self.journeyService.originAddress)
        [self.departureArrivalDisplayView.originAddress setText:self.journeyService.originAddress.locationName];
    
    if (self.journeyService.destinationAddress)
        [self.departureArrivalDisplayView.destinationAddress setText:self.journeyService.destinationAddress.locationName];
    
    if (self.journeyService.originDate){
        [self.datetimeChooserView setToDeparture];
    }else if (self.journeyService.destinationDate) {
        [self.datetimeChooserView setToArrival];
    }
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"HH:mm";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"EEE dd.MM.";
    
    if (self.journeyService.originDate) {
        [self.departureArrivalDisplayView.timeLabel setText:[NSString stringWithFormat:@"%@", [timeFormatter stringFromDate: self.journeyService.originDate]]];
        
        [self.departureArrivalDisplayView.dateLabel setText:[NSString stringWithFormat:@"%@", [dateFormatter stringFromDate: self.journeyService.originDate]]];
        
        [self.departureArrivalDisplayView.departureArrivalLabel setText:@"Abfahrt"];
        
        [self.datetimeChooserView.datePicker setDate:self.journeyService.originDate];
    }else if (self.journeyService.destinationDate) {
        [self.departureArrivalDisplayView.timeLabel setText:[NSString stringWithFormat:@"%@", [timeFormatter stringFromDate: self.journeyService.destinationDate]]];
        
        [self.departureArrivalDisplayView.dateLabel setText:[NSString stringWithFormat:@"%@", [dateFormatter stringFromDate: self.journeyService.destinationDate]]];
        
        [self.departureArrivalDisplayView.departureArrivalLabel setText:@"Ankunft"];
        
        [self.datetimeChooserView.datePicker setDate:self.journeyService.destinationDate];
    }
}

- (void) updateStartAddressOnMap
{
    
}

- (void) updateTargetAddressOnMap
{
    
}

-(void) hideUnhideDepartureAndArrivalDateTimeChooserContainerAnimationDuration:(float)duration
{
    // hide/unhide big departure and arrival chooser container
    [self.view layoutIfNeeded];
    //[self.departureAndArrivalDateTimeChooserContainerView setNeedsUpdateConstraints];
    float alpha = 0.3;
    if (self.departureAndArrivalDateTimeChooserContainerHeightConstraint.constant > 0.0f) {
        //hide
        NSLog(@"hide and save size:%f", self.departureAndArrivalDateTimeChooserContainerHeightConstraint.constant);
        oldHeight = self.departureAndArrivalDateTimeChooserContainerHeightConstraint.constant;
        self.departureAndArrivalDateTimeChooserContainerHeightConstraint.constant = 0.0f;
        alpha = 0.0;
        self.tableView.userInteractionEnabled = YES;
    }else {
        //unhide
        NSLog(@"unhide to height:%f", oldHeight);
        self.departureAndArrivalDateTimeChooserContainerHeightConstraint.constant = 400.0f;
        alpha = 1.0;
        self.tableView.userInteractionEnabled = NO;
    }
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionCurveEaseIn animations:^{
        [self.datetimeChooserView setAlpha:alpha];
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:nil];
}


#pragma mark - STFahrplanJourneyPlannerServiceDelegate

-(void)originDateChangedTo:(NSDate *)date
{
    NSLog(@"STFahrplanConnectionsVC originDateChangedTo");
    
    [self updateLabels];
}

-(void)originAddressChangedTo:(STFahrplanNearbyStopLocation *)address
{
    NSLog(@"STFahrplanConnectionsVC originAddressChangedTo");
    
    if (address.locationName) {
        [self.departureArrivalDisplayView.originAddress setText:address.locationName];
        
    }
}

-(void)destinationDateChangedTo:(NSDate *)date;
{
    NSLog(@"STFahrplanConnectionsVC destinationDateChangedTo");
    
    [self updateLabels];
}

-(void)destinationAddressChangedTo:(STFahrplanNearbyStopLocation *)address;
{
    NSLog(@"STFahrplanConnectionsVC destinationAddressChangedTo");
    
    if (address.locationName) {
        [self.departureArrivalDisplayView.destinationAddress setText:address.locationName];
    }
}

-(void)connectionsChangedTo:(NSArray *)connections;
{
    NSLog(@"STFahrplanConnectionsVC connectionsChangedTo");
    
    if (!connections || [connections count] == 0) {
        NSLog(@"No connections found!");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notiz" message:@"Es wurden keine Verbindungen gefunden." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

-(void)selectedConnectionChangedTo:(STFahrplanTripModel *)selectedConnection;
{
    NSLog(@"STFahrplanConnectionsVC selectedConnectionChangedTo");
    
}

-(void)nearbyStopsUpdatedTo:(NSArray *)nearbyStops;
{
    NSLog(@"STFahrplanConnectionsVC nearbyStopsUpdatedTo");
    
}


#pragma mark - DepartureAndArrivalDatetimeDelegate

-(void)departureAndArrivalDateTime:(STFahrplanDatetimeChooserView *)container departureAndArrivalDateTimeOnClose:(BOOL)save
{
    NSLog(@"departureAndArrivalDateTime departureAndArrivalDateTimeOnClose");
    
    [self hideUnhideDepartureAndArrivalDateTimeChooserContainerAnimationDuration:0.5];
}

-(void)departureAndArrivalDateTime:(STFahrplanDatetimeChooserView *)container departureDatetimeChangedTo:(NSDate *)date
{
    NSLog(@"departureAndArrivalDateTime departureDatetimeChangedTo");
    
    [self.journeyService setOriginDate:date];
    [self.journeyService updateConnections];
    [self.refreshControl beginRefreshing];
}

-(void)departureAndArrivalDateTime:(STFahrplanDatetimeChooserView *)container arrivalDatetimeChangedTo:(NSDate *)date
{
    NSLog(@"departureAndArrivalDateTime arrivalDatetimeChangedTo");
    
    [self.journeyService setDestinationDate:date];
    [self.journeyService updateConnections];
    
    [self.refreshControl beginRefreshing];
}


#pragma mark - STFahrplanOriginDestinationWithTimeDelegate

-(void)departureArrivalDisplayViewOnTimeClick:(STFahrplanDepartureArrivalDisplayView *)container
{
    NSLog(@"departureArrivalDisplayViewOnTimeClick");
    
    [self hideUnhideDepartureAndArrivalDateTimeChooserContainerAnimationDuration:0.5];
}

-(void)departureArrivalDisplayViewOnOriginAddressClick:(STFahrplanDepartureArrivalDisplayView *)container
{
    NSLog(@"departureArrivalDisplayViewOnOriginAddressClick");
    
    nameFinderSelection = @"start";
    
    STFahrplanLocationNameFinderOverlayVC *locationNameFinderVC = [[STFahrplanLocationNameFinderOverlayVC alloc] initWithNibName:@"STFahrplanLocationNameFinderOverlayVC" bundle:nil];
    [locationNameFinderVC setAddress:self.journeyService.originAddress];
    locationNameFinderVC.delegate = self;
    [self presentViewController:locationNameFinderVC animated:YES completion:^{
        NSLog(@"STFahrplanLocationNameFinderOverlayVC presentViewController completion");
        
    }];
}

-(void)departureArrivalDisplayViewOnDestinationAddressClick:(STFahrplanDepartureArrivalDisplayView *)container
{
    NSLog(@"departureArrivalDisplayViewOnDestinationAddressClick");
    
    
    nameFinderSelection = @"target";
    
    STFahrplanLocationNameFinderOverlayVC *locationNameFinderVC = [[STFahrplanLocationNameFinderOverlayVC alloc] initWithNibName:@"STFahrplanLocationNameFinderOverlayVC" bundle:nil];
    [locationNameFinderVC setAddress:self.journeyService.destinationAddress];
    locationNameFinderVC.delegate = self;
    [self presentViewController:locationNameFinderVC animated:YES completion:^{
        NSLog(@"STFahrplanLocationNameFinderOverlayVC presentViewController completion");
        
    }];
}

@end

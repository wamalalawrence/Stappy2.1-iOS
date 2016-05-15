//
//  STFahrplanRouteVC.m
//  Stappy2
//
//  Created by Andrej Albrecht on 20.01.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STFahrplanRouteVC.h"
#import "STFahrplanRouteCellTVC.h"
#import "STFahrplanSubTripModel.h"
#import "UILabel+WhiteUIDatePickerLabels.h"
#import "CALayer+Additions.h"
#import "STFahrplanJourneyPlannerService.h"
#import "STFahrplanDatetimeChooserView.h"
#import "STFahrplanDepartureArrivalDisplayView.h"
#import "STFahrplanLocation.h"
#import "STFahrplanTripModel.h"
#import "UIColor+STColor.h"
#import "STAppSettingsManager.h"

static NSString *routeCellIdentifier = @"STFahrplanRouteCellTVC.Identifier";
static NSString *routeCellSmallIdentifier = @"STFahrplanRouteCellSmallTVC.Identifier";

@interface STFahrplanRouteVC () <UITableViewDataSource,
                                UITableViewDelegate,
                                UIPickerViewDataSource,
                                STFahrplanJourneyPlannerServiceDelegate,
                                STFahrplanDatetimeChooserDelegate,
                                STFahrplanDepartureArrivalDisplayDelegate>
{
    float oldHeight;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *departureAndArrivalDateTimeChooserContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet STFahrplanDatetimeChooserView *datetimeChooserView;//datetimeChooserView
@property (weak, nonatomic) IBOutlet UIDatePicker *datetimePicker;
@property (strong, nonatomic) STFahrplanJourneyPlannerService *journeyService;
@property (weak, nonatomic) IBOutlet UILabel *originAddress;
@property (weak, nonatomic) IBOutlet UILabel *destinationAddress;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *departureArrivalLabel;

@end

@implementation STFahrplanRouteVC

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STFahrplanRouteCellTVC" bundle:nil] forCellReuseIdentifier:routeCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"STFahrplanRouteCellSmallTVC" bundle:nil] forCellReuseIdentifier:routeCellSmallIdentifier];
    
    [self initStadtwerkLayout];
    
    self.journeyService = [STFahrplanJourneyPlannerService sharedInstance];
    
    self.datetimeChooserView.delegate = self;
    //self.departureArrivalDisplayView.delegate = self;
    
    [self updateLabels];
    
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


#pragma mark - Actions

- (IBAction)actionDepartureAndArrivalDateTimeChooser:(id)sender {
    NSLog(@"actionDepartureAndArrivalDateTimeChooser");
    
    [self hideUnhideDepartureAndArrivalDateTimeChooserContainerAnimationDuration:0.5];
}


#pragma mark - Layout

-(void)initStadtwerkLayout
{
    //Color
    [self.timeLabel setTextColor:[UIColor partnerColor]];
    
    //Font
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *cellTextInputPrimaryFont = [settings customFontForKey:@"fahrplan.departure_arrival_display.textinput.primary.font"];
    UIFont *cellTimePrimaryFont = [settings customFontForKey:@"fahrplan.departure_arrival_display.time.primary.font"];
    UIFont *cellDatePrimaryFont = [settings customFontForKey:@"fahrplan.departure_arrival_display.date.primary.font"];
    UIFont *cellDepartureArrivalPrimaryFont = [settings customFontForKey:@"fahrplan.departure_arrival_display.departurearrival.primary.font"];
    
    if (cellTextInputPrimaryFont) {
        [self.originAddress setFont:cellTextInputPrimaryFont];
        [self.destinationAddress setFont:cellTextInputPrimaryFont];
    }
    if (cellTimePrimaryFont) {
        [self.timeLabel setFont:cellTimePrimaryFont];
    }
    if (cellDatePrimaryFont) {
        [self.dateLabel setFont:cellDatePrimaryFont];
    }
    if (cellDepartureArrivalPrimaryFont) {
        [self.departureArrivalLabel setFont:cellDepartureArrivalPrimaryFont];
    }
}


#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.journeyService.selectedConnection) {
        return [self.journeyService.selectedConnection.tripStations count];
    }
    
    return 0;
    //return [self.tableDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    //CGFloat screenHeight = screenRect.size.height;
    
    STFahrplanRouteCellTVC *cell = nil;
    
    if (screenWidth <= 320) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:routeCellSmallIdentifier];
        
    }else{
        cell = [self.tableView dequeueReusableCellWithIdentifier:routeCellIdentifier];
        
    }
    
    
    STFahrplanSubTripModel *subTrip = [self.journeyService.selectedConnection.tripStations objectAtIndex:indexPath.row];
    [cell setTrip:subTrip];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath indexPath:%@", indexPath);
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    if (screenWidth <= 320) {
        return [[[[NSBundle mainBundle] loadNibNamed:@"STFahrplanRouteCellSmallTVC" owner:self options:nil] objectAtIndex:0] bounds].size.height;
    }else{
        return [[[[NSBundle mainBundle] loadNibNamed:@"STFahrplanRouteCellTVC" owner:self options:nil] objectAtIndex:0] bounds].size.height;
    }
}


#pragma mark - DateTimePicker delegate

- (IBAction)datetimePickerValueChanged:(id)sender {
    NSLog(@"datetimePickerValueChanged");
    
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *returnStr = [NSString stringWithFormat:@"Test %lu", row];
    
    return returnStr;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 50;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


#pragma mark - Logic

-(void)updateLabels
{
    if (self.journeyService.originAddress)
        [self.originAddress setText:self.journeyService.originAddress.locationName];
    
    if (self.journeyService.destinationAddress)
        [self.destinationAddress setText:self.journeyService.destinationAddress.locationName];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"HH:mm";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"EEE dd.MM.";
    
    if (self.journeyService.originDate) {
        [self.timeLabel setText:[NSString stringWithFormat:@"%@", [timeFormatter stringFromDate: self.journeyService.originDate]]];
        
        [self.dateLabel setText:[NSString stringWithFormat:@"%@", [dateFormatter stringFromDate: self.journeyService.originDate]]];
        
        [self.departureArrivalLabel setText:@"Abfahrt"];
        
        [self.datetimeChooserView.datePicker setDate:self.journeyService.originDate];
        [self.datetimeChooserView setToDeparture];
    }else if (self.journeyService.destinationDate) {
        [self.timeLabel setText:[NSString stringWithFormat:@"%@", [timeFormatter stringFromDate: self.journeyService.destinationDate]]];
        
        [self.dateLabel setText:[NSString stringWithFormat:@"%@", [dateFormatter stringFromDate: self.journeyService.destinationDate]]];
        
        [self.departureArrivalLabel setText:@"Ankunft"];
        
        [self.datetimeChooserView.datePicker setDate:self.journeyService.destinationDate];
        [self.datetimeChooserView setToArrival];
    }
}

-(void) hideUnhideDepartureAndArrivalDateTimeChooserContainerAnimationDuration:(float)duration
{
    // hide/unhide big departure and arrival chooser container
    [self.view layoutIfNeeded];
    //[self.datetimeChooserView setNeedsUpdateConstraints];
    float alpha = 0.5;
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
    NSLog(@"STFahrplanRouteVC originDateChangedTo");
    
    [self updateLabels];
}

-(void)originAddressChangedTo:(STFahrplanLocation *)address
{
    NSLog(@"STFahrplanRouteVC originAddressChangedTo");
    
    [self updateLabels];
}

-(void)destinationDateChangedTo:(NSDate *)date
{
    NSLog(@"STFahrplanRouteVC destinationDateChangedTo");
    
    [self updateLabels];
}

-(void)destinationAddressChangedTo:(STFahrplanLocation *)address
{
    NSLog(@"STFahrplanRouteVC destinationAddressChangedTo");
    
    [self updateLabels];
}

-(void)connectionsChangedTo:(NSArray *)connections
{
    NSLog(@"STFahrplanRouteVC connectionsChangedTo");
    
}

-(void)selectedConnectionChangedTo:(STFahrplanTripModel *)selectedConnection
{
    NSLog(@"STFahrplanRouteVC selectedConnectionChangedTo");
    
    [self.tableView reloadData];
}

-(void)nearbyStopsUpdatedTo:(NSArray *)nearbyStops
{
    NSLog(@"STFahrplanRouteVC nearbyStopsUpdatedTo");
    
}


#pragma mark - DepartureAndArrivalDatetimeChooserDelegate

-(void)departureAndArrivalDateTime:(STFahrplanDatetimeChooserView *)container departureAndArrivalDateTimeOnClose:(BOOL)save
{
    NSLog(@"departureAndArrivalDateTimeOnClose");
    
    [self hideUnhideDepartureAndArrivalDateTimeChooserContainerAnimationDuration:0.5];
}

-(void)departureAndArrivalDateTime:(STFahrplanDatetimeChooserView *)container departureDatetimeChangedTo:(NSDate *)date
{
    NSLog(@"departureAndArrivalDateTime departureDatetimeChangedTo");
    
     [self.journeyService setOriginDate:date];
}

-(void)departureAndArrivalDateTime:(STFahrplanDatetimeChooserView *)container arrivalDatetimeChangedTo:(NSDate *)date
{
    NSLog(@"departureAndArrivalDateTime arrivalDatetimeChangedTo");
    
     [self.journeyService setDestinationDate:date];
}


#pragma mark - STFahrplanOriginDestinationWithTimeDelegate

-(void)departureArrivalDisplayViewOnTimeClick:(STFahrplanDepartureArrivalDisplayView *)container
{
    NSLog(@"departureArrivalDisplayViewOnTimeClick");
    
    //[self hideUnhideDepartureAndArrivalDateTimeChooserContainerAnimationDuration:0.5];
}

-(void)departureArrivalDisplayViewOnOriginAddressClick:(STFahrplanDepartureArrivalDisplayView *)container
{
    NSLog(@"departureArrivalDisplayViewOnOriginAddressClick");
    
}

-(void)departureArrivalDisplayViewOnDestinationAddressClick:(STFahrplanDepartureArrivalDisplayView *)container
{
    NSLog(@"departureArrivalDisplayViewOnDestinationAddressClick");
    
}

@end

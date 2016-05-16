//
//  STFahrplanSearchVC.m
//  Stappy2
//
//  Created by Andrej Albrecht on 20.01.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STFahrplanSearchVC.h"
#import "SWRevealViewController.h"
#import "STFahrplanConnectionsVC.h"
#import "STFahrplanLocationNameFinderOverlayVC.h"
#import "STRequestsHandler.h"
#import "STFahrplanLocation.h"

#import "AppDelegate.h"

#import <MapKit/MapKit.h>
#import "MKMapView+ZoomLevel.h"
#import <CoreLocation/CoreLocation.h>

#import "STFahrplanNearbyStopAnnotation.h"
#import "STFahrplanTripModel.h"
#import "STFahrplanSubTripModel.h"

#import "STFahrplanJourneyPlannerService.h"
#import "STFahrplanDebugVC.h"

#import "STDebugHelper.h"
#import "UIColor+STColor.h"
#import "STAppSettingsManager.h"
#import "STFahrplanTimetableVC.h"

@interface STFahrplanSearchVC () <UIGestureRecognizerDelegate, SWRevealViewControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate, STDebugHelperDelegate>
@property(assign,nonatomic) CLLocationCoordinate2D previousCenterCoordinates;
@property(strong,nonatomic) NSString *nameFinderSelection;
@property(strong,nonatomic) CLLocationManager *locationManager;
@property(nonatomic,strong) NSArray* nearbyStops;
@property(strong,nonatomic) STFahrplanJourneyPlannerService *journeyService;
@property(strong,nonatomic) MKUserLocation *lastUserLocation;
@property(strong,nonatomic) MKUserLocation *firstUserLocation;
@property (weak, nonatomic) IBOutlet UILabel *zoomAlertMessageLabel;
@property (strong, nonatomic) NSTimer *reloadNearbyStopyTimer;
@property (weak, nonatomic) IBOutlet UILabel *debugStopsCountLabel;
@property (assign, nonatomic) CLLocationCoordinate2D lastLoadedUserLocation;
@property (strong,nonatomic) STFahrplanLocation *ownLocation;
@property (weak, nonatomic) IBOutlet UIImageView *centerUserLocationImageView;
@property (weak, nonatomic) IBOutlet UIImageView *ownLocationImageView;

@end

@implementation STFahrplanSearchVC


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
    
    [self initStadtwerkLayout];
    
    self.journeyService = [STFahrplanJourneyPlannerService sharedInstance];
    
    
    [self initCoreLocationManager];
    //[self startLocationUpdates];
    
    [self initMapView];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle:)];
        
        self.navigationItem.leftBarButtonItem = self.sidebarButton;
        
        
        [self.rightbarButton setTarget: self.revealViewController];
        [self.rightbarButton setAction: @selector(rightRevealToggle:)];
        self.navigationItem.rightBarButtonItem = self.rightbarButton;
    }
    
    //[self loadDummyDataNearbyPins];
    
    //CLLocationDegrees latitude = 53.541629;
    //CLLocationDegrees longitude = 9.996726;
    //[self loadNearbyStopsForLatitude:latitude andLongitude:longitude];
    
    [[STFahrplanJourneyPlannerService sharedInstance] addObserver:self];
    //[self loadStartAndTargetTestAddress];
    
    
    self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
    
    [self hideZoomAlertMessage];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[STFahrplanJourneyPlannerService sharedInstance] removeObserver:self];
    [self stopLocationUpdates];
    
    [[STDebugHelper sharedInstance] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[STFahrplanJourneyPlannerService sharedInstance] addObserver:self];
    //[self startLocationUpdates];
    
    [[STDebugHelper sharedInstance] addObserver:self];
    
    [self updateLabels];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Layout

-(void)initStadtwerkLayout
{
    //Font
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *originDepartureTextfieldFont = [settings customFontForKey:@"fahrplan.search.origin_departure_textfield.font"];
    
    if (originDepartureTextfieldFont) {
        [self.startAddressLabel setFont:originDepartureTextfieldFont];
        [self.targetAddressLabel setFont:originDepartureTextfieldFont];
    }
}

#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSLog(@"observeValueForKeyPath");
    
}


#pragma mark - Actions

- (IBAction)actionCenterUserLocation:(id)sender {
    NSLog(@"actionCenterUserLocation");
    
    if (![self gpsActivated]) {
        return;
    }
    
    if (self.lastUserLocation) {
        //[self.mapView setCenterCoordinate:self.lastUserLocation.location.coordinate animated:YES];
        [self.mapView setCenterCoordinate:self.lastUserLocation.location.coordinate zoomLevel:14 animated:YES];
        self.centerUserLocationImageView.alpha = 0.7;
    }
}

- (IBAction)nextAction:(id)sender {
    NSLog(@"STFahrplanSearchVC nextAction");
    
    if (!self.journeyService.originAddress || [self.journeyService.originAddress.locationName  isEqualToString:@""]) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Info"
                                                         message:@"Bitte Start-Addresse eintragen."
                                                        delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles: nil];
        [alert addButtonWithTitle:@"OK"];
        [alert show];
        return;
    }else if (!self.journeyService.destinationAddress || [self.journeyService.destinationAddress.locationName isEqualToString:@""]) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Info"
                                                         message:@"Bitte Ziel-Addresse eintragen."
                                                        delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles: nil];
        [alert addButtonWithTitle:@"OK"];
        [alert show];
        return;
    }
    
    STFahrplanConnectionsVC *connectionsVC = [[STFahrplanConnectionsVC alloc] initWithNibName:@"STFahrplanConnectionsVC" bundle:nil];
    connectionsVC.title = @"VERBINDUNGEN";
    [self.navigationController pushViewController:connectionsVC animated:YES];
}

- (IBAction)actionOpenAdressFinderOverlayForStart:(id)sender {
    NSLog(@"actionOpenAdressFinderOverlayForStart");
    
    self.nameFinderSelection = @"start";
    
    STFahrplanLocationNameFinderOverlayVC *locationNameFinderVC = [[STFahrplanLocationNameFinderOverlayVC alloc] initWithNibName:@"STFahrplanLocationNameFinderOverlayVC" bundle:nil];
    [locationNameFinderVC setAddress:self.journeyService.originAddress];
    locationNameFinderVC.delegate = self;
    locationNameFinderVC.title = @"Abfahrt";
    [self presentViewController:locationNameFinderVC animated:YES completion:^{
        NSLog(@"STFahrplanLocationNameFinderOverlayVC presentViewController completion");
        
    }];
    
    /*
     //Test with UINavigationController
    UINavigationController *naviController = [[UINavigationController alloc] init];
    [naviController pushViewController:locationNameFinderVC animated:NO];
    [naviController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    naviController.navigationBar.shadowImage = [UIImage new];
    naviController.navigationBar.translucent = YES;
    [self presentViewController:naviController animated:YES completion:nil];
    */
}

- (IBAction)actionOpenAdressFinderOverlayForTarget:(id)sender {
    NSLog(@"actionOpenAdressFinderOverlayTarget");
    
    self.nameFinderSelection = @"target";
    
    STFahrplanLocationNameFinderOverlayVC *locationNameFinderVC = [[STFahrplanLocationNameFinderOverlayVC alloc] initWithNibName:@"STFahrplanLocationNameFinderOverlayVC" bundle:nil];
    [locationNameFinderVC setAddress:self.journeyService.destinationAddress];
    locationNameFinderVC.delegate = self;
    locationNameFinderVC.title = @"Ankunft";
    [self presentViewController:locationNameFinderVC animated:YES completion:^{
        NSLog(@"STFahrplanLocationNameFinderOverlayVC presentViewController completion");
        
    }];
}

- (IBAction)actionToggleOwnLocation:(id)sender {
    if ([self gpsActivated]) {
        if ([self.startAddressLabel.text isEqualToString:@"Aktueller Standort"]) {
            [self.startAddressLabel setText:@"Start"];
            [self.startAddressLabel setTextColor:[UIColor whiteColor]];
            
            UIImage *image = [UIImage imageNamed:@"icon_content_oepnv_location"];
            [self.ownLocationImageView setImage:image];
            self.ownLocationImageView.tintColor = [UIColor whiteColor];
            
            [self.journeyService setOriginAddress:nil];
        }else if (self.ownLocation) {
            [self.startAddressLabel setText:@"Aktueller Standort"];
            [self.startAddressLabel setTextColor:[UIColor partnerColor]];
            
            UIImage *image = [UIImage imageNamed:@"icon_content_oepnv_location"];
            image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.ownLocationImageView setImage:image];
            self.ownLocationImageView.tintColor = [UIColor partnerColor];
            
            [self.journeyService setOriginAddress:self.ownLocation];
        }
    }
    
    [self updateLabels];
}


#pragma mark DEBUG

- (IBAction)debugAction:(id)sender {
    STFahrplanDebugVC *viewController = [[STFahrplanDebugVC alloc] initWithNibName:@"STFahrplanDebugVC" bundle:nil];
    [self presentViewController:viewController animated:YES completion:nil];
}


#pragma mark - Locations

- (void)initCoreLocationManager
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == self.locationManager)
        self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    /*
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    // Set a movement threshold for new events.
    self.locationManager.distanceFilter = 2000; // meters
    
    [self.locationManager startUpdatingLocation];
    */
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    NSLog(@"locationManager didUpdateLocations");
    
    
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (fabs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
        
        //[self loadNearbyStopsForLatitude:location.coordinate.latitude andLongitude:location.coordinate.longitude];
        
        
        
        [self.locationManager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

-(void)startLocationUpdates
{
    //self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
    
    //[self.locationManager startUpdatingLocation];
}

-(void) stopLocationUpdates
{
    self.mapView.userTrackingMode = MKUserTrackingModeNone;
    
    [self.locationManager stopUpdatingLocation];
}


#pragma mark - MapKit

-(void)initMapView
{
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
    
    [self performSelector:@selector(mapViewTrackingModeNone) withObject:nil afterDelay:0.2];
}

-(void)mapViewTrackingModeNone
{
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    NSLog(@"mapView didUpdateUserLocation location:%f, %f", userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    
    if (userLocation.coordinate.longitude!=0.0 && userLocation.coordinate.latitude!=0.0) {
        if (!self.firstUserLocation) {
            [self.mapView setCenterCoordinate:userLocation.coordinate zoomLevel:14 animated:YES];
            
            //load the first nearby locations
            //[self loadNearbyStopsForLatitude:userLocation.coordinate.latitude andLongitude:userLocation.coordinate.longitude];
            
            //[self.journeyService nearbyStopsForLatitude:userLocation.coordinate.latitude andLongitude:userLocation.coordinate.longitude];
            
            
            if (!self.journeyService.originAddress) {
                STFahrplanLocation *ownLocation = [[STFahrplanLocation alloc] init];
                ownLocation.locationName = @"Aktueller Standort";
                ownLocation.longitude = userLocation.coordinate.longitude;
                ownLocation.latitude = userLocation.coordinate.latitude;
                
                self.ownLocation = ownLocation;
                
                //[self.journeyService setOriginAddress:ownLocation];
            }
            
            [self stopLocationUpdates];
            self.firstUserLocation = userLocation;
            [self.journeyService setUserLocation:userLocation];
            
            self.centerUserLocationImageView.alpha = 0.7;
            
            [self loadNearbyStops];
        }
        
        self.lastUserLocation = userLocation;
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[STFahrplanNearbyStopAnnotation class]]) {
        STFahrplanNearbyStopAnnotation *location = (STFahrplanNearbyStopAnnotation *)annotation;
        
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"STFahrplanNearbyStopAnnotation"];
        
        if (annotationView == nil) {
            annotationView = location.annotationView;
        }else{
            annotationView.annotation = annotation;
        }
        return annotationView;
    }else{
        return nil;
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[STFahrplanNearbyStopAnnotation class]]) {
        STFahrplanNearbyStopAnnotation *annotation = (STFahrplanNearbyStopAnnotation *) view.annotation;
        NSLog(@"didSelectAnnotationView annotation.title:%@", annotation.title);
        
        view.alpha = 1.0;
    }
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    view.alpha = 0.7;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:[STFahrplanNearbyStopAnnotation class]]) {
        STFahrplanNearbyStopAnnotation *annotation = (STFahrplanNearbyStopAnnotation *) view.annotation;
        NSLog(@"annotationView calloutAccessoryControlTapped annotation.title:%@ control:", annotation.title);
        
        switch(control.state) {
            case UIControlStateNormal:
                NSLog(@"UIControlStateNormal");
                [self openNearbyStopInformationOverlayFor:annotation.location];
                break;
            case UIControlStateHighlighted:
                NSLog(@"UIControlStateHighlighted");
                [self openNearbyStopInformationOverlayFor:annotation.location];
                break;
            case UIControlStateDisabled:
                NSLog(@"UIControlStateDisabled");
                break;
            case UIControlStateSelected:
                NSLog(@"UIControlStateSelected");
                break;
            case UIControlStateFocused:
                NSLog(@"UIControlStateFocused");
                break;
            case UIControlStateApplication:
                NSLog(@"UIControlStateApplication");
                break;
            case UIControlStateReserved:
                NSLog(@"UIControlStateReserved");
                break;
            default:
                NSLog(@"default");
                break;
        }
    }
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"regionDidChangeAnimated center coordinates.lat:%f long:%f zoomLevel:%lu", [mapView centerCoordinate].latitude, [mapView centerCoordinate].longitude, [self.mapView zoomLevel]);
    
    MKMapPoint mapCenterCoordinate = MKMapPointForCoordinate([mapView centerCoordinate]);
    MKMapPoint previousCoordinate = MKMapPointForCoordinate(self.lastUserLocation.coordinate);
    CLLocationDistance distance = MKMetersBetweenMapPoints(mapCenterCoordinate, previousCoordinate);
    
    if (distance >= 500) {
        self.centerUserLocationImageView.alpha = 1.0;
    }
    
    if (self.reloadNearbyStopyTimer) {
        [self.reloadNearbyStopyTimer invalidate];
    }
    
    self.reloadNearbyStopyTimer = [NSTimer scheduledTimerWithTimeInterval:1.2 target:self selector:@selector(loadNearbyStops) userInfo:nil repeats:NO];
}

- (void) openNearbyStopInformationOverlayFor:(STFahrplanNearbyStopLocation*)location
{
    NSLog(@"openNearbyStopInformationOverlayFor");
    
    @try {
        STFahrplanTimetableVC *timetableVC = [[STFahrplanTimetableVC alloc] initWithNibName:@"STFahrplanTimetableVC" bundle:nil];
        [timetableVC setLocation:location];
        //timetableVC.title = @"Fahrplan";
        [self presentViewController:timetableVC animated:YES completion:^{
            NSLog(@"STFahrplanTimetableVC presentViewController completion");
            
        }];
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", [exception description]);
    }
    @finally {
        
    }
}

#pragma mark - Logic

-(void)loadNearbyStops
{
    if (self.firstUserLocation) { // Ensure that was completed animation to the first user location.
        //Load after doNotLoadTimeDelta reached
        @try {//lastLoaded
            [self.journeyService nearbyStopsPerformantForCoordinate:[self.mapView centerCoordinate] performantWithOldCoordinate:CLLocationCoordinate2DMake(self.lastLoadedUserLocation.latitude, self.lastLoadedUserLocation.longitude) withActualZoomLevelOf:self.mapView.zoomLevel];
            
            self.lastLoadedUserLocation = [self.mapView centerCoordinate];
            //CLLocationCoordinate2D
            
            //hide message
            [self hideZoomAlertMessage];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",[exception description]);
            
            //[self.zoomAlertMessageLabel setText:[exception description]];
            
            if ([[exception description] isEqualToString:@"Please zoom into the map."]) {
                //unhide message
                [self unhideZoomAlertMessage];
            }
        }
        @finally {
            
        }
    }
}

-(void) hideZoomAlertMessage
{
    [self.zoomAlertMessageLabel setAlpha:0.0];
}

-(void) unhideZoomAlertMessage
{
    [self.zoomAlertMessageLabel setAlpha:1.0];
}

- (void) refreshNearbyStopsOnMap
{
    NSLog(@"refreshNearbyStopsOnMap");
     
    //[[STDebugHelper sharedInstance] incrementCounterOfKey:@"map.refreshNearbyStopsOnMap"];
    
    //Remove all previously added annotations
    [self.mapView removeAnnotations:[self.mapView annotations]];
    
    //Add new annotations
    for (int i=0; i < [self.nearbyStops count];i++){
        STFahrplanNearbyStopLocation *stop = [self.nearbyStops objectAtIndex:i];
        //NSLog(@"Stop name:%@ lat:%f long:%f", stop.locationName, stop.latitude, stop.longitude);
        
        CLLocationCoordinate2D stopLocation = CLLocationCoordinate2DMake(stop.latitude, stop.longitude);
        STFahrplanNearbyStopAnnotation *annotation = [[STFahrplanNearbyStopAnnotation alloc] initWithLocation:stop];
        
        [self.mapView addAnnotation:annotation];
    }
}

-(void)updateLabels
{
    if (self.journeyService.originAddress.locationName) {
        [self.startAddressLabel setText:self.journeyService.originAddress.locationName];
    }
    
    if (self.journeyService.destinationAddress.locationName) {
        [self.targetAddressLabel setText:self.journeyService.destinationAddress.locationName];
    }
}

-(BOOL)gpsActivated
{
    if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Ortungsdienst" message:@"Bitte in den Einstellungen den Ortungsdienst für diese App freigeben." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Abbrechen", @"" ) style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Einstellungen", @"" ) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                        UIApplicationOpenSettingsURLString]];
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:settingsAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        //To re-enable, please go to Settings and turn on Location Service for this app.
        return false;
    }
    return true;
}

/*
-(void)updateViews
{
    if (self.startAddress){
        [self.startAddressLabel setText:self.startAddress.locationName];
    }
    
    if (self.targetAddress){
        [self.targetAddressLabel setText:self.targetAddress.locationName];
    }
}*/


#pragma mark - STFahrplanLocationNameFinder delegate

- (void)locationNameFinderAdressChoosed:(STFahrplanNearbyStopLocation *)adress
{
    NSLog(@"STFahrplanSearchVC");
    NSLog(@"locationNameFinderAdressChoosed: %@", adress.locationName);
    
    if ([adress isKindOfClass:[STFahrplanLocation class]]) {
        STFahrplanLocation *locModeladdress = (STFahrplanLocation *)adress;
        
        NSLog(@"id:%@ name:%@ longitutde:%f latitude:%f", locModeladdress.locationID, locModeladdress.locationName, locModeladdress.longitude, locModeladdress.latitude);
        
        if ([self.nameFinderSelection isEqualToString:@"start"] && locModeladdress) {
            //self.startAddress = adress;
            //[self.startAddressLabel setText:startAddress.locationName];
            [[STFahrplanJourneyPlannerService sharedInstance] setOriginAddress:locModeladdress];
            [self.startAddressLabel setTextColor:[UIColor whiteColor]];
            
            UIImage *image = [UIImage imageNamed:@"icon_content_oepnv_location"];
            image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.ownLocationImageView setImage:image];
            self.ownLocationImageView.tintColor = [UIColor whiteColor];
            
        }else if ([self.nameFinderSelection isEqualToString:@"target"] && locModeladdress) {
            //self.targetAddress = adress;
            //[self.targetAddressLabel setText:targetAddress.locationName];
            [[STFahrplanJourneyPlannerService sharedInstance] setDestinationAddress:locModeladdress];
            [self.targetAddressLabel setTextColor:[UIColor whiteColor]];
        }
        
        //[self updateViews];
    }
}


#pragma mark - STFahrplanJourneyPlannerServiceDelegate

-(void)originDateChangedTo:(NSDate *)date
{
    NSLog(@"STFahrplanSearchVC originDateChangedTo");
    
}

-(void)originAddressChangedTo:(STFahrplanLocation *)address
{
    NSLog(@"STFahrplanSearchVC originAddressChangedTo");
    
    [self updateLabels];
    
}

-(void)destinationDateChangedTo:(NSDate *)date;
{
    NSLog(@"STFahrplanSearchVC destinationDateChangedTo");
    
}

-(void)destinationAddressChangedTo:(STFahrplanLocation *)address;
{
    NSLog(@"STFahrplanSearchVC destinationAddressChangedTo");
    
    if (address.locationName) {
        [self.targetAddressLabel setText:address.locationName];
    }
}

-(void)connectionsChangedTo:(NSArray *)connections;
{
    NSLog(@"STFahrplanSearchVC connectionsChangedTo");
    
}

-(void)selectedConnectionChangedTo:(STFahrplanTripModel *)selectedConnection;
{
    NSLog(@"STFahrplanSearchVC selectedConnectionChangedTo");
    
}

-(void)nearbyStopsUpdatedTo:(NSArray *)nearbyStops;
{
    NSLog(@"STFahrplanSearchVC nearbyStopsUpdatedTo");
    
    self.nearbyStops = nearbyStops;
    [self refreshNearbyStopsOnMap];
    [self hideZoomAlertMessage];
}

#pragma mark - DebugHelperDelegate

-(void)debugHelperDataChanged
{
    [self.debugStopsCountLabel setText:[NSString stringWithFormat:@"calls:%lu", (unsigned long)[[STDebugHelper sharedInstance] countOfKey:@"search.NearbyStops"]]];
}

#pragma mark - Test

-(void) loadDummyDataNearbyPins
{
    STFahrplanNearbyStopLocation *nearbyStop1 = [[STFahrplanNearbyStopLocation alloc] init];
    nearbyStop1.latitude = 53.54162;
    nearbyStop1.longitude = 9.99672;
    nearbyStop1.locationName = @"Test";
    
    self.nearbyStops = [NSMutableArray arrayWithObjects:nearbyStop1, nil];
    [self refreshNearbyStopsOnMap];
}

-(void) loadStartAndTargetTestAddress
{
    
}

@end

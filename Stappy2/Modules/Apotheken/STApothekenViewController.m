//
//  STApothekenViewController.m
//  Stappy2
//
//  Created by Denis Grebennicov on 08/01/16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STApothekenViewController.h"
#import "SWRevealViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AFNetworking/AFNetworking.h>
#import "NSDictionary+Default.h"
#import "STRequestsHandler.h"
#import "NSObject+AssociatedObject.h"
#import "STNewsAndEventsDetailViewController.h"
#import "UIColor+STColor.h"
#import "UIImage+tintImage.h"
#import "STAppSettingsManager.h"
#import "STAppSettingsManager.h"
#import "STRoundedButton.h"
#import "MKMapView+ZoomLevel.h"

@interface STApothekenViewController ()
@property (nonatomic, strong) NSMutableDictionary *annotations;
@property (nonatomic, assign, getter=isFirstLoad) BOOL firstLoad;
@property (nonatomic, strong) NSNumber *nearestEmergencyId;
@property (nonatomic, strong) AFHTTPRequestOperation *currentLoadOperation;
@property (weak, nonatomic) IBOutlet STRoundedButton *locationButton;
-(IBAction)locationButtonTapped:(id)sender;

@property (assign, nonatomic) BOOL shouldCenterOnUserLocation;


- (CLLocationCoordinate2D)defaultLocation;
@end

@implementation STApothekenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        [self.barButton setTarget: self.revealViewController];
        [self.barButton setAction: @selector(revealToggle:)];
        
        [self.rightBarButton setTarget: self.revealViewController];
        [self.rightBarButton setAction: @selector(rightRevealToggle:)];
    }
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    { [self.locationManager requestWhenInUseAuthorization]; }
    
    [self.locationManager startUpdatingLocation];
    self.shouldCenterOnUserLocation = YES;

    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    [self segmentedControlValueChanged:self.segmentedControl];
    
    CLLocationCoordinate2D coords = [self defaultLocation];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coords, 40000, 40000);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:NO];
    
    // UI customizations
    [self.segmentedControl setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] } forState:UIControlStateSelected];

    UIFont *segmentControlFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"apotheken_notdienst.segment_control.font"];
    if (segmentControlFont) [self.segmentedControl setTitleTextAttributes:@{ NSFontAttributeName : segmentControlFont } forState:UIControlStateNormal];
    
    [self.segmentedControl setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self checkLocationAuthorization];
}


#pragma mark - Loading the Data from the Network for Drugstores and Emergencies

- (void)loadDrugstores
{
    
    [self.activityIndicator startAnimating];
    
    self.currentLoadOperation = [[STRequestsHandler sharedInstance] drugstoresWithSuccess:^(NSArray <STDrugstoresModel *> *drugstores) {
        for (STDrugstoresModel *drugstore in drugstores)
        {
            // Add an annotation
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            point.coordinate = CLLocationCoordinate2DMake(drugstore.latitude.doubleValue, drugstore.longitude.doubleValue);
            point.title = drugstore.title;
            point.associatedObject = drugstore;
            [self.mapView addAnnotation:point];
        }
        
        [self.mapView showAnnotations:self.mapView.annotations animated:YES];
        [self.activityIndicator stopAnimating];
    } failure:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Fehler beim Laden der Daten." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [self.activityIndicator stopAnimating];
    }];
}

+ (NSString *)urlForEmergenciesWithLatitude:(double)latitude longitude:(double)longitude distance:(NSUInteger)distance
{
    return [NSString stringWithFormat:@"https://apo.stappy.de/Data/apo_open/%f/%f/%lu/0", latitude, longitude, (unsigned long)distance];
}

- (void)loadEmergencies
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes =
    [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    double lat = [STAppSettingsManager sharedSettingsManager].cityLocation.latitude;
    double longi = [STAppSettingsManager sharedSettingsManager].cityLocation.longitude;
    
    
//    double lat = self.mapView.centerCoordinate.latitude;
//    double longi = self.mapView.centerCoordinate.longitude;
    NSUInteger distance = [self distanceInKilometersBetweenEastAndWestEndPointsOfTheMap];
    
    NSString *url = [[self class] urlForEmergenciesWithLatitude:lat longitude:longi distance:distance];
    [self.activityIndicator startAnimating];
    
    [[STRequestsHandler sharedInstance] setEmergenciesUrl:url];
    self.currentLoadOperation = [[STRequestsHandler sharedInstance] emergenciesWithSuccess:^(NSArray<STEmergenciesModel *> *data) {
        NSObject *nearestAnnotation = self.annotations[self.nearestEmergencyId];
        
        NSUInteger ignored = 0;
        NSUInteger added = 0;
        
        for (STEmergenciesModel *emergency in data)
        {
            if (self.nearestEmergencyId == nil) self.nearestEmergencyId = emergency.itemId;
            
            // Ignore drugstores/emergencies, that we already have
            if (self.annotations[emergency.itemId] != nil)
            {
                ++ignored;
                continue;
            }
            
            // Add an annotation
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            point.coordinate = CLLocationCoordinate2DMake(emergency.latitude.doubleValue, emergency.longitude.doubleValue);
            point.title = emergency.name;
            point.associatedObject = emergency;
            
            if ([emergency.itemId isEqualToNumber:self.nearestEmergencyId])
            {
                nearestAnnotation = point;
            }
            
            self.annotations[emergency.itemId] = point;
            [self.mapView addAnnotation:point];
            
            ++added;
        }
        
        [self.activityIndicator stopAnimating];
    } failure:^(NSError *error) {
        if (self.currentLoadOperation.cancelled)    return;
        
        [[[UIAlertView alloc] initWithTitle:@"Fehler beim Laden der Daten." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        [self.activityIndicator stopAnimating];
    }];
}

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender
{
    // UI
    [self.segmentedControl.subviews[1 - sender.selectedSegmentIndex] setTintColor:[UIColor partnerColor]];
    [self.segmentedControl.subviews[sender.selectedSegmentIndex]     setTintColor:[UIColor whiteColor]];
    
    // remove all annotations from the map
    [self.mapView removeAnnotations:self.mapView.annotations];
    self.annotations = nil;
    self.nearestEmergencyId = nil;
    
    [self reload];
}

- (void)reload
{
    [self.currentLoadOperation cancel];
    
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0: [self loadEmergencies]; break;
        case 1: [self loadDrugstores];  break;
        default: break;
    }
}

#pragma mark - MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"default";
    
    if (mapView.userLocation == annotation)
        return nil;
    
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (!view) {
        view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        view.canShowCallout = YES;
        view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }

    view.image = [[UIImage imageNamed:@"pin"] imageTintedWithColor:[UIColor partnerColor]];
    view.centerOffset = CGPointMake(0, -(view.image.size.height / 2));
    
    return view;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    id dataToShowInDetailVC = [((NSObject *)view.annotation) associatedObject];
    
    UIViewController *vc = [[STNewsAndEventsDetailViewController alloc] initWithNibName:@"STNewsAndEventsDetailViewController" bundle:nil andDataModel:dataToShowInDetailVC];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.segmentedControl.selectedSegmentIndex == 0)
    { [self reload]; }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [self.mapView setCenterCoordinate:view.annotation.coordinate animated:YES];
}

#pragma mark - helper methods

- (NSUInteger)distanceInKilometersBetweenEastAndWestEndPointsOfTheMap
{
    MKMapRect mRect = self.mapView.visibleMapRect;
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));
    return (NSUInteger)(MKMetersBetweenMapPoints(eastMapPoint, westMapPoint) / 1000);
}

- (NSMutableDictionary *)annotations
{
    if (_annotations == nil)
    { _annotations = [[NSMutableDictionary alloc] init]; }
    
    return _annotations;
}

- (CLLocationCoordinate2D)defaultLocation { return [STAppSettingsManager sharedSettingsManager].cityLocation; }



-(void)checkLocationAuthorization{
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status==kCLAuthorizationStatusAuthorizedAlways || status==kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.mapView.showsUserLocation = YES;
        self.locationButton.hidden = NO;
    }
    else{
        self.mapView.showsUserLocation = NO;
        self.locationButton.hidden = YES;
        [[[UIAlertView alloc] initWithTitle:nil message:@"Bitte aktiviere in den Einstellungen deine Telefons die Ortungsdienste, um diese Funktion zu nutzen" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    
}


#pragma mark - Location

-(IBAction)locationButtonTapped:(id)sender{
    
    self.shouldCenterOnUserLocation = YES;
    [self.locationManager startUpdatingLocation];
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    if (self.shouldCenterOnUserLocation) {
        
        CLLocation*lastLocation = [locations lastObject];
        NSDate*eventDate = lastLocation.timestamp;
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        
        //just tests if the location is current
        if (howRecent<-5.0) {
            return;
        }
        
        if (lastLocation.horizontalAccuracy<=1500) {
            
            [self.locationManager stopUpdatingLocation];
            self.shouldCenterOnUserLocation = NO;
            CLLocationCoordinate2D defaultCityLocation = [locations lastObject].coordinate;
            [self.mapView setCenterCoordinate:defaultCityLocation zoomLevel:15 animated:NO];
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    [self checkLocationAuthorization];
}


-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [self checkLocationAuthorization];
}


@end

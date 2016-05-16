//
//  STReporterLocationViewController.m
//  Stappy2
//
//  Created by Pavel Nemecek on 10/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STReporterLocationViewController.h"
#import <MapKit/MapKit.h>
#import "SWRevealViewController.h"
#import "STAppSettingsManager.h"
#import "STRoundedButton.h"
#import "UIImage+tintImage.h"
#import "UIColor+STColor.h"
#import "STReporterInfoViewController.h"
#import "STReportAddressSearchViewController.h"
#import "STRequestsHandler.h"
#import "STGoogleLocation.h"
#import "MKMapView+ZoomLevel.h"
@import AddressBookUI;

@interface STReporterLocationViewController ()<CLLocationManagerDelegate, MKMapViewDelegate,STReportAddressSearchViewControllerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButton;
@property (weak, nonatomic) IBOutlet UIImageView *pinImageView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet STRoundedButton *locationButton;
-(IBAction)locationButtonTapped:(id)sender;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (assign, nonatomic) BOOL shouldCenterOnUserLocation;

@end

@implementation STReporterLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        [self.leftBarButton setTarget: self.revealViewController];
        [self.leftBarButton setAction: @selector(revealToggle:)];
    }
    
    self.shouldCenterOnUserLocation = YES;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    CLLocationCoordinate2D defaultCityLocation = [STAppSettingsManager sharedSettingsManager].cityLocation;
    [self.mapView setCenterCoordinate:defaultCityLocation zoomLevel:15 animated:NO];
    self.mapView.showsUserLocation = YES;
    
    self.currentReport = [STReport new];
    
    [self customizeAppearance];
}

-(void)customizeAppearance{
    
    UIImage *image = [UIImage imageNamed:@"Reporter"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.pinImageView setImage:image];
    self.pinImageView.tintColor = [UIColor partnerColor];
    
    UIFont* inputTextFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"reporter.inputText.font"];
    UIFont* buttonTextFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"reporter.buttonText.font"];
    
    if (buttonTextFont) {
        self.nextButton.titleLabel.font = buttonTextFont;
    }
    if (inputTextFont) {
        self.searchButton.titleLabel.font = inputTextFont;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self checkLocationAuthorization];
}


-(void)checkLocationAuthorization{
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status==kCLAuthorizationStatusAuthorizedAlways || status==kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.mapView.showsUserLocation = YES;
        self.locationButton.hidden = NO;
    }
    else{
        self.mapView.showsUserLocation = NO;
        self.locationButton.hidden = YES;
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


#pragma mark - MapView

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    [self updateAddress:@"Suchen..."];
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    [self gecodeCoordinate:self.mapView.centerCoordinate];

}

#pragma mark - Address

-(void)updateAddress:(NSString*)address{
    [self.searchButton setTitle:address forState:UIControlStateNormal];
    self.currentReport.fullAddress= address;    
}

-(void)updateAddress:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate{
    [self.searchButton setTitle:address forState:UIControlStateNormal];
    self.currentReport.fullAddress= address;
    self.currentReport.latitude = coordinate.latitude;
    self.currentReport.longitude = coordinate.longitude;
}

-(void)gecodeCoordinate:(CLLocationCoordinate2D)coordinate{

    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!(error)) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            if (placemark.name) {
                
                if (placemark.thoroughfare) {
                    self.currentReport.street = placemark.thoroughfare;
               }
                if (placemark.locality) {
                    self.currentReport.town = placemark.locality;
                }
            
                [self updateAddress:ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO) coordinate:coordinate];
            }
        }
    }];
}

#pragma mark - Address Search

-(void)searchControllerDidSelectPrediction:(STPrediction *)prediction{
    [self updateAddress:@"Suchen..."];
    
    [[STRequestsHandler sharedInstance] placeLocationForId:prediction.placeId completion:^(STGoogleLocation *location, NSError *error) {
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(location.lat, location.lng);
        
        [self gecodeCoordinate:coordinate];
        [self.mapView setCenterCoordinate:coordinate zoomLevel:15 animated:YES];
    }];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"infoSegue"])
    {
        STReporterInfoViewController *viewController = [segue destinationViewController];
        viewController.currentReport = self.currentReport;
    }
    if ([segue.identifier isEqualToString:@"searchSegue"]) {
        STReportAddressSearchViewController *viewController= segue.destinationViewController;
        viewController.delegate = self;
    }
    
}

// user input validation
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{

    if ([identifier isEqualToString:@"infoSegue"]){
        if (self.currentReport.fullAddress.length>0 && self.currentReport.latitude != 0.0) {
            return YES;
        }
        else{
            [[[UIAlertView alloc] initWithTitle:nil message:@"Es konnte kein Ort festgestellt werden." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            return NO;
        }
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

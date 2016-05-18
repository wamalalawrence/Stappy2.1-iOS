//
//  TankUndLadesaulenViewController.m
//  Stappy2
//
//  Created by Pavel Nemecek on 04/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STTankStationsViewController.h"
#import <MapKit/MapKit.h>
#import "SWRevealViewController.h"
#import "STAppSettingsManager.h"
#import "STRequestsHandler.h"
#import "STTankStationModel.h"
#import "NSObject+AssociatedObject.h"
#import "STNewsAndEventsDetailViewController.h"
#import "STTankStationAnnotation.h"
#import "STTankStationAnnotationView.h"
#import "STRoundedButton.h"
@interface STTankStationsViewController ()<CLLocationManagerDelegate, UIGestureRecognizerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet STRoundedButton *locationButton;
-(IBAction)locationButtonTapped:(id)sender;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (assign, nonatomic) BOOL shouldCenterOnUserLocation;

@end

@implementation STTankStationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.shouldCenterOnUserLocation = NO;
    self.locationButton.hidden = YES;
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        [self.leftBarButton setTarget: self.revealViewController];
        [self.leftBarButton setAction: @selector(revealToggle:)];
        [self.rightBarButton setTarget: self.revealViewController];
        [self.rightBarButton setAction: @selector(rightRevealToggle:)];
    }
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    CLLocationCoordinate2D defaultCityLocation = [STAppSettingsManager sharedSettingsManager].cityLocation;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(defaultCityLocation, 40000, 40000);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:NO];
    self.mapView.showsUserLocation = NO;

    [self fetchTankStationsFromServer];
}

-(void)fetchTankStationsFromServer{
    
    __weak typeof(self) weakSelf = self;
    
    [[STRequestsHandler sharedInstance] allTankStationsWithCompletion:^(NSArray *stations, NSError *error) {
        if (!error) {
             __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf addAnnotationsFromStationArray:stations];
        }
        else{
          [[[UIAlertView alloc] initWithTitle:@"Fehler beim Laden der Daten." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
    
    [[STRequestsHandler sharedInstance] allElektroTankStationWithCompletion:^(NSArray *stations, NSError *error) {
        if (!error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf addAnnotationsFromStationArray:stations];
        }
        else{
             [[[UIAlertView alloc] initWithTitle:@"Fehler beim Laden der Daten." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

-(void)addAnnotationsFromStationArray:(NSArray*)stationArray{
  
    for (STTankStationModel *tankStationModel in stationArray)
    {
        STTankStationAnnotation*annotation = [[STTankStationAnnotation alloc] initWithTankStationModel:tankStationModel];
        [self.mapView addAnnotation:annotation];
        [self.mapView showAnnotations:self.mapView.annotations animated:YES];
    }
}
#pragma mark - Button actions

-(IBAction)locationButtonTapped:(id)sender{
    
    self.shouldCenterOnUserLocation = YES;
    self.mapView.showsUserLocation = YES;

    [self.locationManager startUpdatingLocation];
}

#pragma mark - Annotations methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"pinAnnotation";

    if ([annotation isKindOfClass:[STTankStationAnnotation class]]) {
        
        STTankStationAnnotation*annot =(STTankStationAnnotation*)annotation;
        STTankStationAnnotationView *view = (STTankStationAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (!view) {
            view = [annot annotationViewWithIndetifier:identifier];
        }
        else{
            view.annotation = annotation;
        }
        return view;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    STTankStationAnnotation*annotation = (STTankStationAnnotation*)view.annotation;
    if (annotation.tankStationModel) {
        [self presentTankStationDetailScreenWithModel:annotation.tankStationModel];
    }
}

-(void)presentTankStationDetailScreenWithModel:(STTankStationModel*)tankStationModel {
    
    STNewsAndEventsDetailViewController *detailViewController = [[STNewsAndEventsDetailViewController alloc] initWithNibName:@"STNewsAndEventsDetailViewController" bundle:nil andTankStationModel:tankStationModel];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - Location methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{

    if (self.shouldCenterOnUserLocation) {
        
        CLLocation*lastLocation = [locations lastObject];
        NSDate*eventDate = lastLocation.timestamp;
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        
        if (howRecent<-5.0) {
            return;
        }
        
        if (lastLocation.horizontalAccuracy<=1500) {
            
            [self.locationManager stopUpdatingLocation];
            
            CLLocationCoordinate2D defaultCityLocation = [locations lastObject].coordinate;
            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(defaultCityLocation, 40000, 40000);
            MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
            [self.mapView setRegion:adjustedRegion animated:YES];
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{

    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        self.locationButton.hidden = NO;

    }
    else{
        self.locationButton.hidden = YES;
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    self.locationButton.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

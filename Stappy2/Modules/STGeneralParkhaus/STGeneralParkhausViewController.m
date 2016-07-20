//
//  STGeneralParkhausViewControlle.m
//  Stappy2
//
//  Created by Pavel Nemecek on 04/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STGeneralParkhausViewController.h"
#import <MapKit/MapKit.h>
#import "STAppSettingsManager.h"
#import "STRequestsHandler.h"
#import "STGeneralParkhausModel.h"
#import "NSObject+AssociatedObject.h"
#import "SWRevealViewController.h"
#import "STDetailViewController.h"
#import "STParkhausAnnotation.h"
#import "STRoundedButton.h"
#import "STParkhausAnnotationView.h"
#import "STAppSettingsManager.h"
@interface STGeneralParkhausViewController ()<CLLocationManagerDelegate, UIGestureRecognizerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet STRoundedButton *locationButton;
-(IBAction)locationButtonTapped:(id)sender;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (assign, nonatomic) BOOL shouldCenterOnUserLocation;

@end

@implementation STGeneralParkhausViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([STAppSettingsManager sharedSettingsManager].startScreenNamingsScrollItems[@"parking"]) {
        self.navigationItem.title = [STAppSettingsManager sharedSettingsManager].startScreenNamingsScrollItems[@"parking"];
    }
    
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
    self.mapView.showsUserLocation = YES;

    [self fetchParkahusesFromServer];
}

-(void)fetchParkahusesFromServer{
    
    __weak typeof(self) weakSelf = self;
    
    [[STRequestsHandler sharedInstance] allGeneralParkHausesWithCompletion:^(NSArray *parkHauses, NSError *error) {
        if (!error) {
             __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf addAnnotationsFromHausesArray:parkHauses];
        }
        else{
          [[[UIAlertView alloc] initWithTitle:@"Fehler beim Laden der Daten." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];

}

-(void)addAnnotationsFromHausesArray:(NSArray*)hausArray{
  
    for (STGeneralParkhausModel *parkHausModel in hausArray)
    {
        STParkhausAnnotation*annotation = [[STParkhausAnnotation alloc] initWithParkHausModel:parkHausModel];
        [self.mapView addAnnotation:annotation];
        [self.mapView showAnnotations:self.mapView.annotations animated:YES];
    }
}
#pragma mark - Button actions

-(IBAction)locationButtonTapped:(id)sender{
    
    self.shouldCenterOnUserLocation = YES;
    [self.locationManager startUpdatingLocation];
}

#pragma mark - Annotations methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"pinAnnotation";

    if ([annotation isKindOfClass:[STParkhausAnnotation class]]) {
        
        STParkhausAnnotation*annot =(STParkhausAnnotation*)annotation;
        STParkhausAnnotationView *view = (STParkhausAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
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
    
    STParkhausAnnotation*annotation = (STParkhausAnnotation*)view.annotation;
    if (annotation.parkHausModel) {
        [self presentParkHausDetailScreenWithModel:annotation.parkHausModel];
    }
}

-(void)presentParkHausDetailScreenWithModel:(STGeneralParkhausModel*)parkHausModel {
    
    STDetailViewController *detailViewController = [[STDetailViewController alloc] initWithNibName:@"STDetailViewController" bundle:nil andGeneralParkHausModel:parkHausModel];
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

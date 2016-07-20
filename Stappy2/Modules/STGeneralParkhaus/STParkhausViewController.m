//
//  STParkhausViewController.m
//  Stappy2
//
//  Created by Cynthia Codrea on 11/04/2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STParkhausViewController.h"
#import "SWRevealViewController.h"
#import "STAppSettingsManager.h"
#import "STRequestsHandler.h"
#import "NSObject+AssociatedObject.h"
#import "STDetailViewController.h"
#import "UIImage+tintImage.h"
#import "UIColor+STColor.h"
#import "STParkingDetailsViewController.h"

//model
#import "STParkHausModel.h"
#import "STDetailGenericModel.h"

@interface STParkhausViewController ()
@property (nonatomic, strong) NSMutableDictionary *annotations;
@end

@implementation STParkhausViewController

- (void)viewDidLoad {
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
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    { [self.locationManager requestWhenInUseAuthorization]; }
    
    [self.locationManager startUpdatingLocation];
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    CLLocationCoordinate2D coords = [self defaultLocation];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coords, 40000, 40000);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:NO];
    
    [self loadParkhauses];

}

- (void)loadParkhauses
{
    [self.activityIndicator startAnimating];
    
    [[STRequestsHandler sharedInstance] loadParkHousesWithCompletion:^(NSArray *parkHouses, NSError *error) {
        for (STParkHausModel *parkhaus in parkHouses)
        {
            // Add an annotation
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            point.coordinate = CLLocationCoordinate2DMake(parkhaus.latitude.floatValue, parkhaus.longitude.floatValue);
            point.title = parkhaus.name;
            point.associatedObject = parkhaus;
            [self.mapView addAnnotation:point];
        }
        
        [self.mapView showAnnotations:self.mapView.annotations animated:YES];
        [self.activityIndicator stopAnimating];
    } failure:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Fehler beim Laden der Daten." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [self.activityIndicator stopAnimating];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - helper methods

- (CLLocationCoordinate2D)defaultLocation { return [STAppSettingsManager sharedSettingsManager].cityLocation; }

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse)
    { self.mapView.showsUserLocation = YES; }
}

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


#pragma mark - Annotations methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"pinLocation";
    
    if (mapView.userLocation == annotation)
        return nil;
    
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (!view) {
        view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        view.canShowCallout = YES;
        view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    
    UIImage* originalImage = [UIImage imageNamed:@"parkhaus_pin"];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:originalImage];
    UIImage* imageForRendering = [originalImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    imageView.image = imageForRendering;
    
    id data = (STParkHausModel*)[((NSObject *)view.annotation) associatedObject];
    if ([((STParkHausModel*)data).occupancy isEqualToString:@"medium"]) {
        view.tintColor = [UIColor yellowColor];
    }
    else if ([((STParkHausModel*)data).occupancy isEqualToString:@"low"]){
        view.tintColor = [UIColor greenColor];
    }
    else {
        view.tintColor = [UIColor redColor];
    }
    view.image = imageForRendering;
    [view addSubview:imageView];
    view.centerOffset = CGPointMake(0, -(view.image.size.height / 2));
    
    return view;
}

-(void)requestDetailedDataForItem:(long)detailsId {
    
    //request the detailed data for item
    __block STParkHausModel* detailData = [[STParkHausModel alloc] init];
    NSString* detailsUrl = [NSString stringWithFormat:@"http://parkinghq.com/services/v2/pois/%ld?access_key=WZBG_CITY&type=ParkingUnit&locale=de",detailsId];
    [[STRequestsHandler sharedInstance] parkHausDetailsForUrl:detailsUrl withCompletion:^(STParkHausModel *itemDetails, NSError *error) {
        detailData = itemDetails;
//        detailData.menuOrientationLeft = NO;
        //present detail screen
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentDetailScreenWithData:detailData];
        });
    }];
}

-(void)presentDetailScreenWithData:(STParkHausModel*)detailData {
    
    UIViewController *vc = [[STDetailViewController alloc] initWithNibName:@"STDetailViewController" bundle:nil andParkHausModel:detailData];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    id dataToShowInDetailVC = (STParkHausModel*)[((NSObject *)view.annotation) associatedObject];
    [self requestDetailedDataForItem:((STParkHausModel*)dataToShowInDetailVC).id];
}


@end

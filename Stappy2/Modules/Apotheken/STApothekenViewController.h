//
//  STApothekenViewController.h
//  Stappy2
//
//  Created by Denis Grebennicov on 08/01/16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface STApothekenViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) CLLocationManager *locationManager;

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender;
@end
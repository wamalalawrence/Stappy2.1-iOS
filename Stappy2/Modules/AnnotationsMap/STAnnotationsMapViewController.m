//
//  AnnotationsMapViewController.m
//  Schwedt
//
//  Created by Denis Grebennicov on 04/02/16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STAnnotationsMapViewController.h"
#import "NSObject+AssociatedObject.h"
#import "UIImage+tintImage.h"
#import "UIColor+STColor.h"
#import "STNewsAndEventsDetailViewController.h"

@interface STAnnotationsMapViewController () <MKMapViewDelegate>
@property (nonatomic, strong) NSArray<STMainModel *> *data;
@end

@implementation STAnnotationsMapViewController

- (instancetype)initWithData:(NSArray<STMainModel *> *)data {
    if (self = [super initWithNibName:@"STAnnotationsMapViewController" bundle:nil]) {
        self.data = data;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.mapView.delegate = self;
    
    for(STMainModel *model in self.data) {
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = CLLocationCoordinate2DMake([model.latitude doubleValue], [model.longitude doubleValue]);
        point.title = model.title;
        
        if ([model respondsToSelector:@selector(subtitle)]) point.subtitle = model.subtitle;
        
        point.associatedObject = model;
        [self.mapView addAnnotation:point];
    }
}

#pragma mark - MKMapViewDelegate

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *kMapAnnotationPinIdentifier = @"default";
    
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:kMapAnnotationPinIdentifier];
    if (!view) {
        view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kMapAnnotationPinIdentifier];
        view.canShowCallout = YES;
        view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    
    view.image = [[UIImage imageNamed:@"pin"] imageTintedWithColor:[UIColor partnerColor]];
    
    view.centerOffset = CGPointMake(0, -(view.image.size.height / 2));
    
    return view;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    id dataToShowInDetailVC = [((NSObject *)view.annotation) associatedObject];
    
    STNewsAndEventsDetailViewController *detailsView = [[STNewsAndEventsDetailViewController alloc] initWithNibName:@"STNewsAndEventsDetailViewController" bundle:nil andDataModel:dataToShowInDetailVC];
    detailsView.ignoreFavoritesButton = self.ignoreFavoritesButton;
    [self.navigationController pushViewController:detailsView animated:YES];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(view.annotation.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    NSMutableArray *annotations = [mapView.annotations mutableCopy];
    [annotations removeObject:mapView.userLocation];
    [self.mapView showAnnotations:annotations animated:YES];
}

@end
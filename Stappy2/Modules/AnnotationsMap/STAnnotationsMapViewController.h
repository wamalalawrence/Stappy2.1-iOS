//
//  AnnotationsMapViewController.h
//  Schwedt
//
//  Created by Denis Grebennicov on 04/02/16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "STMainModel.h"

@interface STAnnotationsMapViewController : UIViewController
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property(nonatomic, assign)BOOL ignoreFavoritesButton;

- (instancetype)initWithData:(NSArray<STMainModel *> *)data;

@end

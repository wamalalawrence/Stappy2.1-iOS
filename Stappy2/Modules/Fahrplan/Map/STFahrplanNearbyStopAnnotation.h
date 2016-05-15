//
//  NearbyStopAnnotation.h
//  Stappy2
//
//  Created by Andrej Albrecht on 21.01.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class STFahrplanNearbyStopLocation;

@interface STFahrplanNearbyStopAnnotation : NSObject <MKAnnotation>


@property (strong,nonatomic) STFahrplanNearbyStopLocation *location;
@property(nonatomic,readonly) CLLocationCoordinate2D coordinate;
@property(copy, nonatomic) NSString *title;


-(id)initWithLocation:(STFahrplanNearbyStopLocation*)location;
-(id)initWithTitle:(NSString*)newTitle location:(CLLocationCoordinate2D)location;
- (MKAnnotationView *)annotationView;

@end

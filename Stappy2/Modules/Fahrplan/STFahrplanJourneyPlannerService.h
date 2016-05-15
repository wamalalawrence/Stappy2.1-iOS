//
//  STFahrplanJourneyPlannerService.h
//  Schwedt
//
//  Created by Andrej Albrecht on 01.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class STFahrplanLocation;
@class STFahrplanTripModel;
@class STFahrplanJourneyDetail;
@class STFahrplanNearbyStopLocation;
@class STFahrplanDeparture;

@protocol STFahrplanJourneyPlannerServiceDelegate <NSObject>
@optional
-(void)originDateChangedTo:(NSDate *)date;
-(void)originAddressChangedTo:(STFahrplanLocation *)address;
-(void)destinationDateChangedTo:(NSDate *)date;
-(void)destinationAddressChangedTo:(STFahrplanLocation *)address;
-(void)connectionsChangedTo:(NSArray *)connections;
-(void)selectedConnectionChangedTo:(STFahrplanTripModel *)selectedConnection;
-(void)nearbyStopsUpdatedTo:(NSArray *)nearbyStops;
@end

@interface STFahrplanJourneyPlannerService : NSObject

@property (strong, nonatomic) NSDate *originDate;
@property (strong, nonatomic) STFahrplanLocation *originAddress;
@property (strong, nonatomic) NSDate *destinationDate;
@property (strong, nonatomic) STFahrplanLocation *destinationAddress;
@property (strong, nonatomic) NSArray *connectionsArray;
@property (strong, nonatomic) STFahrplanTripModel *selectedConnection;
@property (strong, nonatomic) NSArray *nearbyStops;
@property (strong,nonatomic) MKUserLocation *userLocation;

-(void)addObserver:(id<STFahrplanJourneyPlannerServiceDelegate>)observer;
-(void)removeObserver:(id<STFahrplanJourneyPlannerServiceDelegate>)observer;
-(void)nearbyStopsPerformantForCoordinate:(CLLocationCoordinate2D)coordinate performantWithOldCoordinate:(CLLocationCoordinate2D)oldCoordinate withActualZoomLevelOf:(NSUInteger)zoomLevel;
-(void)nearbyStopsForLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude;
-(void)updateConnections;

-(void)allLocationsForSearchTerm:(NSString*)searchTerm onSuccess:(void (^)(NSArray *))completion onFailure:(void (^)(NSError*))failureCallback;

-(void) getJourneyDetailofDeparture:(STFahrplanDeparture*)departure onSuccess:(void (^)(STFahrplanJourneyDetail *))completion onFailure:(void (^)(NSError*))failureCallback;
-(void) departureBoardForLocation:(STFahrplanNearbyStopLocation*)location onSuccess:(void (^)(NSArray *))completion onFailure:(void (^)(NSError*))failureCallback;
-(void)allLocationNearbyStopsWithParams:(NSDictionary*)params onSuccess:(void (^)(NSArray *))completion onFailure:(void (^)(NSError*))failureCallback;
//-(void)allLocationsBySearchWithParams:(NSDictionary*)params onSuccess:(void (^)(NSArray *))completion onFailure:(void (^)(NSError*))failureCallback;
-(void)allTripsToDestinationWithParams:(NSDictionary*)params onSuccess:(void (^)(NSArray *))completion onFailure:(void (^)(NSError*))failureCallback;



+ (id)sharedInstance;

@end

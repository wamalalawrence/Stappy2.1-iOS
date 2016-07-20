//
//  STFahrplanApiUrlBuilder.h
//  Stappy2
//
//  Created by Andrej Albrecht on 15.03.16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class STFahrplanLocation;
@class STFahrplanNearbyStopLocation;
@class STFahrplanDeparture;

@interface STFahrplanApiUrlBuilder : NSObject

-(NSString*)getApiUrlForSearchLocation;
-(NSDictionary*)getApiUrlParamsAllLocationsForSearchTerm:(NSString*)searchTerm;

//FAHRPLAN COORDINATE TEST
-(NSDictionary*)getApiUrlParamsAllLocationsForSearchTerm:(NSString*)searchTerm coordinate:(CLLocationCoordinate2D)coordinate;

-(NSString*)getApiUrlForJourneyDetail;
-(NSDictionary*)getApiUrlParamsForJourneyDetailOfDeparture:(STFahrplanDeparture*)departure;

-(NSString *)getApiUrlForDepartureBoard;
-(NSDictionary*)getApiUrlParamsForDepartureBoardLocation:(STFahrplanNearbyStopLocation*)location;

-(NSString *)getApiUrlForArrivalBoard;
-(NSDictionary*)getApiUrlParamsForArrivalBoardLocation:(STFahrplanNearbyStopLocation*)location;

-(NSString*)getApiUrlForAllLocationNearbyStops;
-(NSDictionary*)getApiUrlParamsNearbyStopsForLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude;

-(NSString*)getApiUrlForAllTripsToDestination;
-(NSDictionary*)getApiUrlParamsAllConnectionsForOriginLocation:(STFahrplanLocation*)originAddress andDestinationLocation:(STFahrplanLocation*)destinationAddress forOriginDate:(NSDate*)originDate andDestinationDate:(NSDate*)destinationDate;



@end

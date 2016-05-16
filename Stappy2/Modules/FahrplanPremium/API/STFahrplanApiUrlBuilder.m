//
//  STFahrplanApiUrlBuilder.m
//  Stappy2
//
//  Created by Andrej Albrecht on 15.03.16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STFahrplanApiUrlBuilder.h"
#import "STFahrplanLocation.h"
#import "STFahrplanDeparture.h"

@implementation STFahrplanApiUrlBuilder

/*
- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}*/

-(NSString*)getApiUrlForSearchLocation
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(NSDictionary*)getApiUrlParamsAllLocationsForSearchTerm:(NSString*)searchTerm
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}



-(NSString*)getApiUrlForJourneyDetail
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(NSDictionary*)getApiUrlParamsForJourneyDetailOfDeparture:(STFahrplanDeparture*)departure
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}



-(NSString *)getApiUrlForDepartureBoard
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(NSDictionary*)getApiUrlParamsForDepartureBoardLocation:(STFahrplanNearbyStopLocation*)location
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}


-(NSString *)getApiUrlForArrivalBoard
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(NSDictionary*)getApiUrlParamsForArrivalBoardLocation:(STFahrplanNearbyStopLocation*)location
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}


-(NSString*)getApiUrlForAllLocationNearbyStops
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(NSDictionary*)getApiUrlParamsNearbyStopsForLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}



-(NSString*)getApiUrlForAllTripsToDestination
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(NSDictionary*)getApiUrlParamsAllConnectionsForOriginLocation:(STFahrplanLocation*)originAddress andDestinationLocation:(STFahrplanLocation*)destinationAddress forOriginDate:(NSDate*)originDate andDestinationDate:(NSDate*)destinationDate
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}




@end

//
//  STFahrplanHafasMixedApiUrlBuilder.m
//  Stappy2
//
//  Created by Andrej Albrecht on 15.03.16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STFahrplanHafasMixedApiUrlBuilder.h"
#import "STAppSettingsManager.h"
#import <CoreLocation/CoreLocation.h>
#import "STFahrplanLocation.h"
#import "STFahrplanNearbyStopLocation.h"
#import "STFahrplanDeparture.h"

@implementation STFahrplanHafasMixedApiUrlBuilder

-(NSString*)getApiUrlForSearchLocation
{
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    //NSString *apiUrl = [settings backendValueForKey:@"fahrplan.api_url"];
//    NSString *apiUrl = @"http://fahrinfo.vbb.de/restproxy";
    NSString *apiUrl = @"http://endios.hafas.de/openapi";
    apiUrl = [apiUrl stringByAppendingString:@"/location.name"];
    
    //Demo
    //NSString* requestUrl = @"http://demo.hafas.de/openapi/dbrest/location.name";
    
    //VBB
    //NSString* requestUrl = @"http://demo.hafas.de/openapi/vbb-proxy/location.name";
    
    // NSLog(@"allLocationsBySearchWithParams apiUrl:%@", apiUrl);
    
    return apiUrl;
}

-(NSDictionary*)getApiUrlParamsAllLocationsForSearchTerm:(NSString*)searchTerm
{
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    NSString *accessId = [settings backendValueForKey:@"fahrplan.access_id"];
    
    NSDictionary* params = @{
                             @"input":[NSString stringWithFormat:@"%@*",searchTerm],
                             @"maxNo":@"10",
                             @"accessId":accessId,
                             @"format":@"json"
                             };
    return params;
}


-(NSString*)getApiUrlForJourneyDetail
{
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    //NSString *apiUrl = [settings backendValueForKey:@"fahrplan.api_url"];
    NSString *apiUrl = [settings backendValueForKey:@"fahrplan.api_url_test_openapi_demo"];
    
    apiUrl = [apiUrl stringByAppendingString:@"/journeyDetail"];
    return apiUrl;
}

-(NSDictionary*)getApiUrlParamsForJourneyDetailOfDeparture:(STFahrplanDeparture*)departure
{
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    //NSString *accessId = [settings backendValueForKey:@"fahrplan.access_id"];
    NSString *accessId = [settings backendValueForKey:@"fahrplan.access_id_test_openapi_demo"];
    
    
    NSLog(@"searchLocationName accessId:%@", accessId);
    
    NSString *identifier = @"";
    if (departure.journeyDetailRef) {
        identifier = departure.journeyDetailRef;
    }
    
    //__weak  typeof(self) weakSelf = self;
    NSDictionary* params = @{
                             @"id":identifier,
                             @"accessId":accessId,
                             @"format":@"json"
                             };
    
    return params;
}

-(NSString *)getApiUrlForDepartureBoard
{
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    NSString *apiUrl = [settings backendValueForKey:@"fahrplan.api_url_test_openapi_demo"];//works: fahrplan.api_url
    apiUrl = [apiUrl stringByAppendingString:@"/departureBoard"];
    return apiUrl;
}

-(NSDictionary*)getApiUrlParamsForDepartureBoardLocation:(STFahrplanNearbyStopLocation*)location
{
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    NSString *accessKey = [settings backendValueForKey:@"fahrplan.access_id_test_openapi_demo"];//access_id
    
    //NSLog(@"id:%@",location.locationID);
    
    NSDictionary* params = @{
                             @"id":location.locationID,
                             @"accessId":accessKey,
                             @"format":@"json"
                             };
    return params;
}


-(NSString *)getApiUrlForArrivalBoard
{
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    NSString *apiUrl = [settings backendValueForKey:@"fahrplan.api_url_test_openapi_demo"];//works: fahrplan.api_url
    apiUrl = [apiUrl stringByAppendingString:@"/arrivalBoard"];
    return apiUrl;
}

-(NSDictionary*)getApiUrlParamsForArrivalBoardLocation:(STFahrplanNearbyStopLocation*)location
{
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    NSString *accessKey = [settings backendValueForKey:@"fahrplan.access_id_test_openapi_demo"];//access_id
    
    //NSLog(@"id:%@",location.locationID);
    
    NSDictionary* params = @{
                             @"id":location.locationID,
                             @"accessId":accessKey,
                             @"format":@"json"
                             };
    return params;
}


-(NSString*)getApiUrlForAllLocationNearbyStops
{
    //NSString* requestUrl = @"http://demo.hafas.de/openapi/dbrest/location.nearbystops";
    
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    NSString *apiUrl = [settings backendValueForKey:@"fahrplan.api_url_test_openapi_demo"];
    apiUrl = [apiUrl stringByAppendingString:@"/location.nearbystops"];
    
    return apiUrl;
}

-(NSDictionary*)getApiUrlParamsNearbyStopsForLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude
{
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    NSString *accessKey = [settings backendValueForKey:@"fahrplan.access_id_test_openapi_demo"];
    
    NSDictionary *dictParams = @{@"originCoordLat":[NSString stringWithFormat:@"%f",latitude],
                                 @"originCoordLong":[NSString stringWithFormat:@"%f",longitude],
                                 @"r":@"2000",
                                 @"maxNo":@"100",
                                 @"format":@"json",
                                 @"accessId":accessKey,
                                 };
    return dictParams;
}

-(NSString*)getApiUrlForAllTripsToDestination
{
    //Demo
    //NSString* requestUrl = @"http://demo.hafas.de/openapi/dbrest/trip";
    //NSString *accessKey = @"endios-Schwedt-c4-ac64-ea40ec3edbd3";
    
    //VBB
    //NSString* requestUrl = @"http://demo.hafas.de/openapi/vbb-proxy/trip";
    //NSString *accessKey = @"endios-Schwedt-c4-ac64-ea40ec3edbd3";
    
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    NSString *apiUrl = [settings backendValueForKey:@"fahrplan.api_url"];
    apiUrl = [apiUrl stringByAppendingString:@"/trip"];
    
    return apiUrl;
}

-(NSDictionary*)getApiUrlParamsAllConnectionsForOriginLocation:(STFahrplanLocation*)originAddress andDestinationLocation:(STFahrplanLocation*)destinationAddress forOriginDate:(NSDate*)originDate andDestinationDate:(NSDate*)destinationDate
{
    NSString *originId = @"";
    NSString *originCoordLong = @"";
    NSString *originCoordLat = @"";
    if (originAddress.locationID==nil || [originAddress.locationID isEqualToString:@""]) {
        originCoordLong = [NSString stringWithFormat:@"%f",originAddress.longitude];
        originCoordLat = [NSString stringWithFormat:@"%f",originAddress.latitude];
    }else{
        originId = [NSString stringWithFormat:@"%@",originAddress.locationID];
    }
    
    NSString *destId = [NSString stringWithFormat:@"%@",destinationAddress.locationID];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"HH:mm";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"YYYY-MM-dd";
    
    NSString *date = @"";
    NSString *time = @"";
    NSString *searchForArrival = @"0";
    
    if (destinationDate){
        time = [timeFormatter stringFromDate:destinationDate];
        date = [dateFormatter stringFromDate:destinationDate];
        searchForArrival = @"1";
    } else if (originDate) {
        time = [timeFormatter stringFromDate:originDate];
        date = [dateFormatter stringFromDate:originDate];
    } else {
        time = [timeFormatter stringFromDate:[NSDate date]];
        date = [dateFormatter stringFromDate:[NSDate date]];
    }
    
    
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    NSString *accessKey = [settings backendValueForKey:@"fahrplan.access_id"];
    
    
    NSDictionary* params = nil;
    
    if (originId!=nil && ![originId isEqualToString:@""]) {
        params = @{
                   @"originId":originId,
                   @"destId":destId,
                   @"date": date,
                   @"time": time,
                   @"searchForArrival": searchForArrival,
                   @"accessId":accessKey,
                   @"format":@"json"
                   };
    }else{
        params = @{
                   @"originCoordLat":originCoordLat,
                   @"originCoordLong":originCoordLong,
                   @"destId":destId,
                   @"date": date,
                   @"time": time,
                   @"searchForArrival": searchForArrival,
                   @"accessId":accessKey,
                   @"format":@"json"
                   };
    }
    
    return params;
}


@end


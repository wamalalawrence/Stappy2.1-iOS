//
//  STFahrplanGoogleHafasMixed.m
//  Stappy2
//
//  Created by Andrej Albrecht on 24.03.16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STFahrplanGoogleHafasMixedApiUrlBuilder.h"

#import "STAppSettingsManager.h"
#import "STFahrplanLocation.h"
#import "STFahrplanNearbyStopLocation.h"
#import "STFahrplanDeparture.h"

@implementation STFahrplanGoogleHafasMixedApiUrlBuilder

-(NSString*)getApiUrlForSearchLocation
{
    //STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    //NSString *apiUrl = [settings backendValueForKey:@"fahrplan.api_url"];
    NSString *apiUrl = @"https://maps.googleapis.com/maps/api/place/autocomplete/json";
    //apiUrl = [apiUrl stringByAppendingString:@"/location.name"];
    
    //https://maps.googleapis.com/maps/api/place/autocomplete/json?input=Überseequart&types=geocode&key=AIzaSyDTD9Jlb7K76KRTzen3UtHBRB0poC6WoRI
    //https://maps.googleapis.com/maps/api/place/autocomplete/json?input=Paris&types=geocode&key=YOUR_API_KEY
    
    
    
    return apiUrl;
}

-(NSDictionary*)getApiUrlParamsAllLocationsForSearchTerm:(NSString*)searchTerm
{
    //STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    //NSString *accessId = [settings backendValueForKey:@"fahrplan.access_id"];
    NSString *accessId = @"AIzaSyDTD9Jlb7K76KRTzen3UtHBRB0poC6WoRI";
    
    NSDictionary* params = @{@"input":searchTerm,
                             @"types":@"geocode",
                             @"key":accessId};
    
    // Types supported in place autocomplete requests:
    // https://developers.google.com/places/supported_types?hl=de#table3
    
    return params;
}


-(NSString*)getApiUrlForJourneyDetail
{
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    //NSString *apiUrl = [settings backendValueForKey:@"fahrplan.api_url"];
    NSString *apiUrl = [settings backendValueForKey:@"fahrplan.fahrplan_api_productive.api_url"];
    
    apiUrl = [apiUrl stringByAppendingString:@"/journeyDetail"];
    return apiUrl;
}

-(NSDictionary*)getApiUrlParamsForJourneyDetailOfDeparture:(STFahrplanDeparture*)departure
{
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    //NSString *accessId = [settings backendValueForKey:@"fahrplan.access_id"];
    NSString *accessId = [settings backendValueForKey:@"fahrplan.fahrplan_api_productive.access_id"];
    
    
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
    NSString *apiUrl = [settings backendValueForKey:@"fahrplan.fahrplan_api_productive.api_url"];//works: fahrplan.api_url
    apiUrl = [apiUrl stringByAppendingString:@"/departureBoard"];
    return apiUrl;
}

-(NSDictionary*)getApiUrlParamsForDepartureBoardLocation:(STFahrplanNearbyStopLocation*)location
{
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    NSString *accessKey = [settings backendValueForKey:@"fahrplan.fahrplan_api_productive.access_id"];//access_id
    
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
    NSString *apiUrl = [settings backendValueForKey:@"fahrplan.fahrplan_api_productive.api_url"];//works: fahrplan.api_url
    apiUrl = [apiUrl stringByAppendingString:@"/arrivalBoard"];
    return apiUrl;
}

-(NSDictionary*)getApiUrlParamsForArrivalBoardLocation:(STFahrplanNearbyStopLocation*)location
{
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    NSString *accessKey = [settings backendValueForKey:@"fahrplan.fahrplan_api_productive.access_id"];//access_id
    
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
    NSString *apiUrl = [settings backendValueForKey:@"fahrplan.fahrplan_api_productive.api_url"];
    apiUrl = [apiUrl stringByAppendingString:@"/location.nearbystops"];
    
    return apiUrl;
}

-(NSDictionary*)getApiUrlParamsNearbyStopsForLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude
{
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    NSString *accessKey = [settings backendValueForKey:@"fahrplan.fahrplan_api_productive.access_id"];
    
    if (!accessKey) {
        @throw [NSException exceptionWithName:@"config error" reason:@"no access id found" userInfo:nil];
    }
    
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
    //STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    //NSString *apiUrl = [settings backendValueForKey:@"fahrplan.api_url"];
    //apiUrl = [apiUrl stringByAppendingString:@"/trip"];
    NSString *apiUrl = @"https://maps.googleapis.com/maps/api/directions/json";//HTTPS!
    
    
    return apiUrl;
}

-(NSDictionary*)getApiUrlParamsAllConnectionsForOriginLocation:(STFahrplanLocation*)originAddress andDestinationLocation:(STFahrplanLocation*)destinationAddress forOriginDate:(NSDate*)originDate andDestinationDate:(NSDate*)destinationDate
{
    //STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    //NSString *accessKey = [settings backendValueForKey:@"fahrplan.access_id"];
    NSString *accessKey = @"AIzaSyBLE9WaJvD-jaEaytWjCR7JuBmWL5_QwQA";
    
    NSDictionary *params = @{@"origin":[NSString stringWithFormat:@"place_id:%@",originAddress.locationID],
                             @"destination":[NSString stringWithFormat:@"place_id:%@",destinationAddress.locationID],
                             @"mode":@"transit",
                             @"alternatives":@"true",
                             @"key":accessKey};
    
    return params;
}


@end

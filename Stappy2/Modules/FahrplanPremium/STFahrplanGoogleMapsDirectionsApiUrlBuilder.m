//
//  STFahrplanGoogleMapsDirectionsApiUrlBuilder.m
//  Stappy2
//
//  Created by Andrej Albrecht on 15.03.16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STFahrplanGoogleMapsDirectionsApiUrlBuilder.h"

#import "STAppSettingsManager.h"
#import "STFahrplanLocation.h"

@implementation STFahrplanGoogleMapsDirectionsApiUrlBuilder

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
    NSString *apiUrl = [settings backendValueForKey:@"fahrplan.api_url"];
    
    //apiUrl = [apiUrl stringByAppendingString:@"/journeyDetail"];
    
    
    return apiUrl;
}


-(NSString *)getApiUrlForDepartureBoard
{
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    NSString *apiUrl = [settings backendValueForKey:@"fahrplan.api_url"];
    //apiUrl = [apiUrl stringByAppendingString:@"/departureBoard"];
    apiUrl = @"https://maps.googleapis.com/maps/api/directions/json";
    
    
    
    return apiUrl;
}

-(NSDictionary*)getApiUrlParamsForDepartureBoardLocation:(STFahrplanNearbyStopLocation*)location
{
    NSMutableDictionary *params = nil;
    
    
    
    return params;
}


-(NSString *)getApiUrlForArrivalBoard
{
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    NSString *apiUrl = [settings backendValueForKey:@"fahrplan.api_url"];
    //apiUrl = [apiUrl stringByAppendingString:@"/departureBoard"];
    apiUrl = @"https://maps.googleapis.com/maps/api/directions/json";
    
    
    
    return apiUrl;
}

-(NSDictionary*)getApiUrlParamsForArrivalBoardLocation:(STFahrplanNearbyStopLocation*)location
{
    NSMutableDictionary *params = nil;
    
    
    
    return params;
}


-(NSString*)getApiUrlForAllLocationNearbyStops
{
    //NSString* requestUrl = @"http://demo.hafas.de/openapi/dbrest/location.nearbystops";
    
    //STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    //NSString *apiUrl = [settings backendValueForKey:@"fahrplan.api_url"];
    //apiUrl = [apiUrl stringByAppendingString:@"/location.nearbystops"];
    NSString *apiUrl = @"https://maps.googleapis.com/maps/api/place/nearbysearch/json";
    //?location=-33.8670,151.1957&radius=500&types=food&name=cruise&key=";
    
    
    return apiUrl;
}

-(NSDictionary*)getApiUrlParamsNearbyStopsForLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude
{
    //STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    //NSString *accessKey = [settings backendValueForKey:@"fahrplan.access_id"];
    NSString *accessId = @"AIzaSyDTD9Jlb7K76KRTzen3UtHBRB0poC6WoRI";
    
    NSDictionary *dictParams = @{@"location":[NSString stringWithFormat:@"%f,%f",latitude, longitude],
                                 @"type":@"bus_station|subway_station|train_station|transit_station",//use "type" instead of "types"
                                 @"radius":@"500",
                                 //@"pagetoken":pagetoken,
                                 @"key":accessId};
    
    //Available types for the Google Places API: https://developers.google.com/places/supported_types?hl=de#table1
    
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

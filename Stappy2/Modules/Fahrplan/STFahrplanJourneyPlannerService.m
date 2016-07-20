//
//  STFahrplanJourneyPlannerService.m
//  Schwedt
//
//  Created by Andrej Albrecht on 01.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STFahrplanJourneyPlannerService.h"
#import "STFahrplanTripModel.h"
#import "STRequestsHandler.h"
#import <CoreLocation/CoreLocation.h>
#import "STDebugHelper.h"
#import "MapKit/MapKit.h"
#import "STAppSettingsManager.h"
#import "STFahrplanNearbyStopLocation.h"
#import "NSDate+Utils.h"
#import "STFahrplanLocation.h"
#import "STHTTPSessionManager.h"
//#import "STAppSettingsManager.h"
#import "STFahrplanApiUrlBuilder.h"
#import "STFahrplanApiResponseMapper.h"

#import "STFahrplanNearbyStopLocation.h"
#import "STFahrplanLocation.h"
#import "STFahrplanTripModel.h"
#import "STFahrplanDeparture.h"
#import "STFahrplanDepartureBoard.h"
#import "STFahrplanJourneyDetail.h"


//ApiUrlBuilder
#import "STFahrplanGoogleMapsDirectionsApiUrlBuilder.h"
#import "STFahrplanHafasMixedApiUrlBuilder.h"
#import "STFahrplanHafasRestProxyApiUrlBuilder.h"
#import "STFahrplanHafasOpenApiVbbProxyApiUrlBuilder.h"
#import "STFahrplanHafasOpenApiDbRestApiUrlBuilder.h"

//ApiResponseMapper
#import "STFahrplanGoogleMapsDirectionsApiResponseMapper.h"
#import "STFahrplanHafasMixedApiResponseMapper.h"
#import "STFahrplanHafasRestProxyApiResponseMapper.h"
#import "STFahrplanHafasOpenApiVbbProxyApiResponseMapper.h"
#import "STFahrplanHafasOpenApiDbRestApiResponseMapper.h"


NSString *const STOpenAPIErrorDomain = @"STOpenAPIErrorDomain";

@interface STFahrplanJourneyPlannerService ()

@property (assign, nonatomic) BOOL dirty;
@property (strong, nonatomic) NSMutableArray *listeners;

@property (strong,nonatomic) STFahrplanApiUrlBuilder *apiUrlBuilder;
@property (strong,nonatomic) STFahrplanApiResponseMapper *apiResponseMapper;

@end

@implementation STFahrplanJourneyPlannerService

#pragma mark - Lifecycle

+ (id)sharedInstance
{
    static STFahrplanJourneyPlannerService *sharedInstance = nil;
    @synchronized(self) {
        if (sharedInstance == nil){
            sharedInstance = [[self alloc] init];
            sharedInstance.listeners = [NSMutableArray array];
            sharedInstance.dirty = YES;
            sharedInstance.originDate = [NSDate date];
        }
    }
    return sharedInstance;
}

-(void)addObserver:(id<STFahrplanJourneyPlannerServiceDelegate>)observer
{
    if (![self.listeners containsObject:observer]) {
        [self.listeners addObject:observer];
    }
}

-(void)removeObserver:(id<STFahrplanJourneyPlannerServiceDelegate>)observer
{
    if ([self.listeners containsObject:observer]) {
        [self.listeners removeObject:observer];
    }
}


#pragma mark - ApiUrlBuilder

-(STFahrplanApiUrlBuilder *)apiUrlBuilder
{
    if (_apiUrlBuilder!=nil) {
        return _apiUrlBuilder;
    }
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    NSString *api_url_builder = [settings backendValueForKey:@"fahrplan.fahrplan_api.api_url_builder"];
    
    STFahrplanApiUrlBuilder *apiUrlBuilder = [[NSClassFromString(api_url_builder) alloc] init];
    if (apiUrlBuilder!=nil) {
        _apiUrlBuilder = apiUrlBuilder;
    }else{
        @throw [NSException exceptionWithName:@"ApiUrlBuilder not found!" reason:@"Please check the ApiUrlBuilder in the settings file. (fahrplan.fahrplan_api.api_url_builder)" userInfo:nil];
    }
    return apiUrlBuilder;
}


#pragma mark - ApiResponseMapper

-(STFahrplanApiResponseMapper *)apiResponseMapper
{
    if (_apiResponseMapper!=nil) {
        return _apiResponseMapper;
    }
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    NSString *api_response_mapper = [settings backendValueForKey:@"fahrplan.fahrplan_api.api_response_mapper"];
    
    STFahrplanApiResponseMapper *apiUrlResponseMapper = [[NSClassFromString(api_response_mapper) alloc] init];
    if (apiUrlResponseMapper!=nil) {
        _apiResponseMapper = apiUrlResponseMapper;
    }else{
        @throw [NSException exceptionWithName:@"ApiResponseMapper not found!" reason:@"Please check the ApiResponseMapper in the settings file. (fahrplan.fahrplan_api.api_response_mapper)" userInfo:nil];
    }
    return apiUrlResponseMapper;
}


#pragma mark - Logic

-(void)nearbyStopsForLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude
{
    [[STDebugHelper sharedInstance] incrementCounterOfKey:@"search.NearbyStops"];
    
    //STFahrplanApiResponseMapper *mapper = [self apiResponseMapper];
    STFahrplanApiUrlBuilder *urlBuilder = [self apiUrlBuilder];
    NSDictionary *dictParams = [urlBuilder getApiUrlParamsNearbyStopsForLatitude:latitude andLongitude:longitude];
    
    [self allLocationNearbyStopsWithParams:dictParams onSuccess:^(NSArray *nearbyStops) {
        self.nearbyStops = nearbyStops;
    } onFailure:^(NSError *error) {
        if (error) {
            if ([error code] == NSURLErrorNotConnectedToInternet) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hinweis" message:@"Keine Internetverbindung." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hinweis" message:@"Haltestellen können zur Zeit nicht abgefragt werden." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
    }];
}

-(void)nearbyStopsPerformantForCoordinate:(CLLocationCoordinate2D)coordinate performantWithOldCoordinate:(CLLocationCoordinate2D)oldCoordinate withActualZoomLevelOf:(NSUInteger)zoomLevel;
{
    if (zoomLevel < 13) {
        @throw([NSException exceptionWithName:@"Nearby stops are not loaded." reason:@"Please zoom into the map." userInfo:nil]);
    }
    
    MKMapPoint mapCenterCoordinate = MKMapPointForCoordinate(oldCoordinate);
    MKMapPoint previousCoordinate = MKMapPointForCoordinate(coordinate);
    CLLocationDistance distance = MKMetersBetweenMapPoints(mapCenterCoordinate, previousCoordinate);
    
    float doNotRefreshZoneRadius = [self getDoNotRefreshZoneRadius];
    
    if (distance > doNotRefreshZoneRadius) {
        [self nearbyStopsForLatitude:coordinate.latitude andLongitude:coordinate.longitude];
    }else{
        @throw([NSException exceptionWithName:@"Nearby stops are not loaded." reason:@"Please scroll outside of loaded area." userInfo:nil]);
    }
}

-(NSUInteger)getDoNotRefreshZoneRadius
{
    int defaultZoneRadius = 1000;
    float percent = 0.7;
    
    //ASSERT: The self.nearbyStops array is sorted.
    
    if (self.nearbyStops) {
        NSUInteger index = (NSUInteger)([self.nearbyStops count] * percent);
        STFahrplanNearbyStopLocation *stop = [self.nearbyStops objectAtIndex:index];
        if (stop.distance > defaultZoneRadius) {
            return stop.distance;
        }
    }
    
    return defaultZoneRadius;
}

-(void)updateConnections
{
    if (self.dirty) {
        if (self.originAddress && self.destinationAddress) {
            STFahrplanApiUrlBuilder *builder = [self apiUrlBuilder];
            NSDictionary *params = [builder getApiUrlParamsAllConnectionsForOriginLocation:self.originAddress andDestinationLocation:self.destinationAddress forOriginDate:self.originDate andDestinationDate:self.destinationDate];
            
            
            [[STDebugHelper sharedInstance] incrementCounterOfKey:@"search.Connections"];
            
            __weak  typeof(self) weakSelf = self;
            [self allTripsToDestinationWithParams:params
                                        onSuccess:^(NSArray *trips) {
                                            __strong typeof(weakSelf) strongSelf = weakSelf;
                                            //strongSelf.trips
                                            
                                            //
                                            NSMutableArray *cleanedArray = [[NSMutableArray alloc] init];
                                            
                                            
                                            for (int i=0; i < [trips count]; i++) {
                                                STFahrplanTripModel *trip = [trips objectAtIndex:i];
                                                
                                                //trip.departureDatetime;
                                                //strongSelf.originDate;
                                                
                                                // start output with entered originDate
                                                if (!strongSelf.destinationDate && trip.departureDatetime &&
                                                    [trip.departureDatetime timeIntervalSinceDate:strongSelf.originDate] >= 0) {
                                                    [cleanedArray addObject:trip];
                                                }else if (strongSelf.destinationDate &&
                                                          trip.arrivalDatetime &&
                                                          [strongSelf.destinationDate timeIntervalSinceDate:trip.arrivalDatetime] >= 0) {
                                                    [cleanedArray addObject:trip];
                                                }
                                            }
                                            
                                            strongSelf.connectionsArray = cleanedArray;
                                        }
             
                                        onFailure:^(NSError *error) {
                                            if (error) {
                                                if ([error code] == NSURLErrorNotConnectedToInternet) {
                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hinweis" message:@"Keine Internetverbindung." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                                    [alert show];
                                                }else {
                                                    __strong typeof(weakSelf) strongSelf = weakSelf;
                                                    strongSelf.connectionsArray = nil;
                                                    
                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hinweis" message:@"Es wurden keine Verbindungen gefunden." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                                    [alert show];
                                                }
                                            }
                                        }];
        }else{
            NSLog(@"Origin or target address is missing.");
            //@throw [NSException exceptionWithName:@"Origin or target address is missing." reason:@"No origin or target address choosed." userInfo:nil];
        }
        
        self.dirty = NO;
    }else{
        NSLog(@"journey planner service answered with previously connections ");
        [self.listeners makeObjectsPerformSelector:@selector(connectionsChangedTo:) withObject:self.connectionsArray];
    }
}

-(void)allTripsToDestinationWithParams:(NSDictionary*)params onSuccess:(void (^)(NSArray *))completion onFailure:(void (^)(NSError*))failureCallback
{
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        failureCallback([NSError errorWithDomain:@"Error: NSURLErrorNotConnectedToInternet" code:NSURLErrorNotConnectedToInternet userInfo:nil]);
        return;
    }
    
    STFahrplanApiUrlBuilder *apiUrlBuilder = [self apiUrlBuilder];
    NSString *apiUrl = [apiUrlBuilder getApiUrlForAllTripsToDestination];
    
    [[STHTTPSessionManager manager] GET:apiUrl
                             parameters:params
                                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                    if (completion) {
                                        NSError* mtlError = nil;
                                        @try {
                                            STFahrplanApiResponseMapper *mapper = [self apiResponseMapper];
                                            NSArray *trips = [mapper connectionsWithRouteOfResponse:responseObject error:&mtlError];
                                            
                                            if (!mtlError) {
                                                completion(trips);
                                            } else {
                                                failureCallback(mtlError);
                                            }
                                        }
                                        @catch (NSException *exception) {
                                            NSError *error = [NSError errorWithDomain:@"perhaps parse error"
                                                                                 code:1
                                                                             userInfo:nil];
                                            failureCallback(error);
                                        }
                                    }
                                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                    failureCallback(error);
                                }];
}

-(void)allLocationsForSearchTerm:(NSString*)searchTerm coordinate:(CLLocationCoordinate2D)coordinate onSuccess:(void (^)(NSArray *))completion onFailure:(void (^)(NSError*))failureCallback
{
    [[STDebugHelper sharedInstance] incrementCounterOfKey:@"search.LocationName"];
    
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        failureCallback([NSError errorWithDomain:@"Error: NSURLErrorNotConnectedToInternet" code:NSURLErrorNotConnectedToInternet userInfo:nil]);
        return;
    }
    
    STFahrplanApiUrlBuilder *apiUrlBuilder = [self apiUrlBuilder];
    NSString *apiUrl = [apiUrlBuilder getApiUrlForSearchLocation];
    NSDictionary* params;
    
    //FAHRPLAN COORDINATE TEST
    if ([apiUrl containsString:@"hafas"] && CLLocationCoordinate2DIsValid(coordinate)) {
      params=  [apiUrlBuilder getApiUrlParamsAllLocationsForSearchTerm:searchTerm coordinate:coordinate];

    }
    else{
         params=  [apiUrlBuilder getApiUrlParamsAllLocationsForSearchTerm:searchTerm];
    
}
    
    [[STHTTPSessionManager manager] GET:apiUrl
                             parameters:params
                                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                    if (completion) {
                                        NSError *mtlError = nil;
                                        
                                        STFahrplanApiResponseMapper *responseMapper = [self apiResponseMapper];
                                        NSArray *nearbyLocations = [responseMapper nearbyLocationsOfResponse:responseObject error:mtlError];
                                        
                                        if (!mtlError) {
                                            completion(nearbyLocations);
                                        } else {
                                            NSError *error = [NSError errorWithDomain:STOpenAPIErrorDomain
                                                                                 code:1
                                                                             userInfo:nil];
                                            failureCallback(error);
                                        }
                                    }
                                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                    failureCallback(error);
                                }];
}

-(void) getJourneyDetailofDeparture:(STFahrplanDeparture*)departure onSuccess:(void (^)(STFahrplanJourneyDetail *))completion onFailure:(void (^)(NSError*))failureCallback
{
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        failureCallback([NSError errorWithDomain:@"Error: NSURLErrorNotConnectedToInternet" code:NSURLErrorNotConnectedToInternet userInfo:nil]);
        return;
    }
    
    STFahrplanApiUrlBuilder *apiUrlBuilder = [self apiUrlBuilder];
    NSString *apiUrl = [apiUrlBuilder getApiUrlForJourneyDetail];
    NSDictionary *params = [apiUrlBuilder getApiUrlParamsForJourneyDetailOfDeparture:departure];
    
    [[STHTTPSessionManager manager] GET:apiUrl
                             parameters:params
                                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                    if (completion) {
                                        NSError *mtlError = nil;
                                        
                                        
                                        
                                        //////// Hafas-API
                                        NSString *errorText = responseObject[@"errorText"];
                                        if (responseObject[@"errorText"] && ![errorText isEqualToString:@""]){
                                            NSError *error = [NSError errorWithDomain:@"Error"
                                                                                 code:1234002
                                                                             userInfo:nil];
                                            failureCallback(error);
                                            return;
                                        }
                                        ////////
                                        
                                        
                                        @try {
                                            STFahrplanJourneyDetail *journeyDetail = [[self apiResponseMapper] journeyDetailsOfResponse:responseObject error:&mtlError];
                                            
                                            if (!mtlError && journeyDetail) {
                                                completion(journeyDetail);
                                            } else {
                                                NSError *error = [NSError errorWithDomain:STOpenAPIErrorDomain
                                                                                     code:1
                                                                                 userInfo:nil];
                                                failureCallback(error);
                                            }
                                        }@catch(NSException *exception){
                                            NSError *error = [NSError errorWithDomain:@"parse error"
                                                                                 code:1234001
                                                                             userInfo:nil];
                                            failureCallback(error);
                                        }
                                    }
                                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                    failureCallback(error);
                                }];
}

-(void) departureBoardForLocation:(STFahrplanNearbyStopLocation*)location onSuccess:(void (^)(NSArray *))completion onFailure:(void (^)(NSError*))failureCallback
{
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        failureCallback([NSError errorWithDomain:@"Error: NSURLErrorNotConnectedToInternet" code:NSURLErrorNotConnectedToInternet userInfo:nil]);
        return;
    }
    
    STFahrplanApiUrlBuilder *apiUrlBuilder = [self apiUrlBuilder];
    NSString *apiUrl = [apiUrlBuilder getApiUrlForDepartureBoard];
    NSDictionary *params = [apiUrlBuilder getApiUrlParamsForDepartureBoardLocation:location];
    
    [[STHTTPSessionManager manager] GET:apiUrl
                             parameters:params
                                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                    if (completion) {
                                        NSError *mtlError = nil;
                                        
                                        @try {
                                            
                                            NSArray *departures = [[self apiResponseMapper] departureBoardFromResponse:responseObject error:&mtlError];
                                            
                                            if (!mtlError) {
                                                completion(departures);
                                            } else {
                                                NSError *error = [NSError errorWithDomain:STOpenAPIErrorDomain
                                                                                     code:1
                                                                                 userInfo:nil];
                                                failureCallback(error);
                                            }
                                        }@catch(NSException *exception){
                                            NSError *error = [NSError errorWithDomain:@"parse error"
                                                                                 code:1234001
                                                                             userInfo:nil];
                                            failureCallback(error);
                                        }
                                    }
                                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                    failureCallback(error);
                                }];
}

-(void)allLocationNearbyStopsWithParams:(NSDictionary*)params onSuccess:(void (^)(NSArray *))completion onFailure:(void (^)(NSError*))failureCallback {
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        failureCallback([NSError errorWithDomain:@"Error: NSURLErrorNotConnectedToInternet" code:NSURLErrorNotConnectedToInternet userInfo:nil]);
        return;
    }
    
    STFahrplanApiUrlBuilder *apiUrlBuilder = [self apiUrlBuilder];
    NSString *apiUrl = [apiUrlBuilder getApiUrlForAllLocationNearbyStops];
    
    [[STHTTPSessionManager manager] GET:apiUrl
                             parameters:params
                                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                    NSError *mtlError = nil;
                                    
                                    NSArray *nearbyLocations = [[self apiResponseMapper] nearbyStopsOfResponse:responseObject error:&mtlError];
                                    
                                    if (!mtlError) {
                                        completion(nearbyLocations);
                                    }
                                    else {
                                        NSError *error = [NSError errorWithDomain:STOpenAPIErrorDomain
                                                                             code:1
                                                                         userInfo:nil];
                                        failureCallback(error);
                                    }
                                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                    failureCallback(error);
                                }];
}


#pragma mark - Properties

-(void)setOriginDate:(NSDate *)originDate
{
    _destinationDate = nil;
    _originDate = originDate;
    self.dirty = YES;
    [self.listeners makeObjectsPerformSelector:@selector(originDateChangedTo:) withObject:_originDate];
}

-(void)setOriginAddress:(STFahrplanLocation *)originAddress
{
    _originAddress = originAddress;
    self.dirty = YES;
    [self.listeners makeObjectsPerformSelector:@selector(originAddressChangedTo:) withObject:_originAddress];
}

-(void)setDestinationDate:(NSDate *)destinationDate
{
    _originDate = nil;
    _destinationDate = destinationDate;
    self.dirty = YES;
    [self.listeners makeObjectsPerformSelector:@selector(destinationDateChangedTo:) withObject:_destinationDate];
}

-(void)setDestinationAddress:(STFahrplanLocation *)destinationAddress
{
    _destinationAddress = destinationAddress;
    self.dirty = YES;
    [self.listeners makeObjectsPerformSelector:@selector(destinationAddressChangedTo:) withObject:_destinationAddress];
}

-(void)setConnectionsArray:(NSArray *)connectionsArray
{
    _connectionsArray = connectionsArray;
    //_connectionsArray = [self removeConnectionsOlderThenOriginDate:connectionsArray];
    
    [self.listeners makeObjectsPerformSelector:@selector(connectionsChangedTo:) withObject:_connectionsArray];
}

-(void)setSelectedConnection:(STFahrplanTripModel *)selectedConnection
{
    _selectedConnection = selectedConnection;
    [self.listeners makeObjectsPerformSelector:@selector(selectedConnectionChangedTo:) withObject:_selectedConnection];
}

-(void)setNearbyStops:(NSArray *)nearbyStops
{
    _nearbyStops = nearbyStops;
    [self.listeners makeObjectsPerformSelector:@selector(nearbyStopsUpdatedTo:) withObject:_nearbyStops];
}


#pragma mark - Logic

-(NSArray *)removeConnectionsOlderThenOriginDate:(NSArray *)array
{
    NSMutableArray *arrayWithoutOldConnections = [NSMutableArray array];
    
    for (int i=0; i < [array count]; i++) {
        STFahrplanTripModel *connection = [array objectAtIndex:i];
        if ([connection.departureDatetime timeIntervalSinceNow] >= 0) {
            [arrayWithoutOldConnections addObject:connection];
        }
    }
    
    return arrayWithoutOldConnections;
}


@end

//
//  STFahrplanHafasMixedApiResponseMapper.m
//  Stappy2
//
//  Created by Andrej Albrecht on 15.03.16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STFahrplanHafasMixedApiResponseMapper.h"

#import "STFahrplanLocation.h"
#import "STFahrplanLocationBuilder.h"

#import "STFahrplanTripModel.h"
#import "STFahrplanDeparture.h"
#import "STFahrplanNearbyStopLocation.h"
#import "STFahrplanJourneyDetail.h"
#import "STFahrplanJourneyStop.h"
#import "STFahrplanJourneyName.h"
#import "STFahrplanJourneyDirection.h"


@implementation STFahrplanHafasMixedApiResponseMapper

-(NSArray*)nearbyLocationsOfResponse:(id)response error:(NSError*)error
{
    NSMutableArray *nearbyLocations = [NSMutableArray array];
    
    if ([response[@"StopLocation"] isKindOfClass:[NSArray class]]) {
        NSArray *stopLocations = (NSArray *)response[@"StopLocation"];
        for (NSDictionary *dictLoc in stopLocations) {
            NSString *locationId = [dictLoc objectForKey:@"id"];
            double longitude = [[dictLoc objectForKey:@"lon"] doubleValue];
            double latitude = [[dictLoc objectForKey:@"lat"] doubleValue];
            NSString *locationName = [dictLoc objectForKey:@"name"];
            
            STFahrplanLocation *location = [STFahrplanLocationBuilder buildWithLocationId:locationId locationName:locationName latitude:latitude longitude:longitude];
            [nearbyLocations addObject:location];
        }
    }
    
    return nearbyLocations;
}

-(NSArray*)connectionsWithRouteOfResponse:(id)responseObject error:(NSError**)error
{
    NSArray *trips = [MTLJSONAdapter modelsOfClass:[STFahrplanTripModel class]
                                     fromJSONArray:responseObject[@"Trip"]
                                             error:error];
    
    /*
     @"duration":@"duration",
     @"tripStations":@"LegList.Leg"
     */
    
    /*
     @"transportationName":@"name",
     @"transportationType":@"category",
     @"direction":@"direction",
     
     @"startPointName":@"Origin.name",
     @"startPointTime":@"Origin.time",
     @"startPointDate":@"Origin.date",
     @"startPointTimeFormatted":@"Origin.time",
     @"startPointDateFormatted":@"Origin.date",
     @"startPointLatitude":@"Origin.lat",
     @"startPointLongitude":@"Origin.lon",
     @"startTrack":@"Origin.track",
     
     @"endPointName":@"Destination.name",
     @"endPointTime":@"Destination.time",
     @"endPointDate":@"Destination.date",
     @"endPointTimeFormatted":@"Destination.time",
     @"endPointDateFormatted":@"Destination.date",
     @"endPointLatitude":@"Destination.lat",
     @"endPointLongitude":@"Destination.lon",
     @"endTrack":@"Destination.track"
     */
    
    return trips;
}

-(NSArray*)departureBoardFromResponse:(id)responseObject error:(NSError**)error
{
    NSArray *departures = [MTLJSONAdapter modelsOfClass:[STFahrplanDeparture class] fromJSONArray:responseObject[@"Departure"] error:error];
    return departures;
}

-(NSArray*)nearbyStopsOfResponse:(id)responseObject error:(NSError**)error
{
    NSArray *nearbyLocations = [MTLJSONAdapter modelsOfClass:[STFahrplanNearbyStopLocation class]
                                               fromJSONArray:responseObject[@"stopLocationOrCoordLocation"]
                                                       error:error];
    return nearbyLocations;
}

-(STFahrplanJourneyDetail*)journeyDetailsOfResponse:(id)responseObject error:(NSError**)error
{
    //STFahrplanJourneyDetail *journeyDetail = [MTLJSONAdapter modelOfClass: [STFahrplanJourneyDetail class] fromJSONDictionary:responseObject error:error];
    
    STFahrplanJourneyDetail *journeyDetail = [[STFahrplanJourneyDetail alloc] init];
    NSMutableArray *stops = [NSMutableArray array];
    NSMutableArray *names = [NSMutableArray array];
    NSMutableArray *directions = [NSMutableArray array];
    
    NSDictionary *stopsDict = (NSDictionary*)responseObject[@"Stops"];
    NSDictionary *namesDict = (NSDictionary*)responseObject[@"Names"];
    NSDictionary *directionsDict = (NSDictionary*)responseObject[@"Directions"];
    
    if ([stopsDict[@"Stop"] isKindOfClass:[NSArray class]]) {
        /*
         "name" : "Poppenbüttel (S), Hamburg",
         "id" : "A=1@O=Poppenbüttel (S), Hamburg@X=10092647@Y=53651820@U=80@L=692929@",
         "extId" : "692929",
         "routeIdx" : 0,
         "lon" : 10.092647,
         "lat" : 53.65182,
         "depTime" : "16:38:00",
         "depDate" : "2016-03-16"
         */
        for (NSDictionary *stopDict in stopsDict[@"Stop"]) {
            STFahrplanJourneyStop *stopObject = [[STFahrplanJourneyStop alloc] init];
            
            NSString *depTime = stopDict[@"depTime"];
            if (depTime!=nil) {
                @try {
                    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@":00$" options:0 error:NULL];
                    NSString *depTimeFormatted = [regex stringByReplacingMatchesInString:depTime options:0 range:NSMakeRange(0, [depTime length]) withTemplate:@""];
                    depTime = depTimeFormatted;
                }
                @catch (NSException *exception) {
                    
                }
            }else{
                depTime = @"-";
            }
            
            stopObject.name = stopDict[@"name"];
            stopObject.identifier = stopDict[@"id"];
            stopObject.extId = stopDict[@"extId"];
            stopObject.routeIdx = stopDict[@"routeIdx"];
            stopObject.lon = stopDict[@"lon"];
            stopObject.lat = stopDict[@"lat"];
            stopObject.depTime = depTime;
            stopObject.depDate = stopDict[@"depDate"];
            [stops addObject:stopObject];
        }
    }
    
    if ([namesDict[@"Name"] isKindOfClass:[NSArray class]]) {
        /*
         {
         "Product" : {
         "name" : "Bus  179",
         "num" : "0",
         "line" : "179",
         "catOut" : "Bus",
         "catIn" : "Bus",
         "catCode" : "5",
         "catOutS" : "Bus",
         "catOutL" : "Bus",
         "operatorCode" : "DPN",
         "operator" : "Nahreisezug",
         "admin" : "hvvHHA"
         },
         "name" : "Bus  179",
         "number" : "0",
         "category" : "Bus",
         "routeIdxFrom" : 0,
         "routeIdxTo" : 24
         }
         */
        for (NSDictionary *nameDict in namesDict[@"Name"]) {
            STFahrplanJourneyName *nameObject = [[STFahrplanJourneyName alloc] init];
            //nameObject.name = nameDict[@"name"];
            nameObject.number = nameDict[@"number"];
            nameObject.category = nameDict[@"category"];
            nameObject.routeIdxFrom = nameDict[@"routeIdxFrom"];
            nameObject.routeIdxTo = nameDict[@"routeIdxTo"];
            
            [names addObject:nameObject];
        }
    }
    
    if ([directionsDict[@"Direction"] isKindOfClass:[NSArray class]]) {
        /*
         {
         "value" : "Borgweg (U), Hamburg",
         "routeIdxFrom" : 0,
         "routeIdxTo" : 24
         } 
         */
        for (NSDictionary *directionDict in directionsDict[@"Direction"]) {
            STFahrplanJourneyDirection *directionObject = [[STFahrplanJourneyDirection alloc] init];
            directionObject.value = directionDict[@"value"];
            directionObject.routeIdxFrom = directionDict[@"routeIdxFrom"];
            directionObject.routeIdxTo = directionDict[@"routeIdxTo"];
            
            [directions addObject:directionObject];
        }
    }
    
    journeyDetail.stops = stops;
    journeyDetail.names = names;
    journeyDetail.directions = directions;
    
    return journeyDetail;
}

@end

//
//  STFahrplanGoogleHafasMixedApiResponseMapper.m
//  Stappy2
//
//  Created by Andrej Albrecht on 24.03.16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STFahrplanGoogleHafasMixedApiResponseMapper.h"

#import "STFahrplanLocation.h"
#import "STFahrplanLocationBuilder.h"

#import "STFahrplanTripModel.h"
#import "STFahrplanSubTripModel.h"
#import "STFahrplanDeparture.h"
#import "STFahrplanNearbyStopLocation.h"
#import "STFahrplanJourneyDetail.h"
#import "STFahrplanJourneyStop.h"
#import "STFahrplanJourneyName.h"
#import "STFahrplanJourneyDirection.h"

@implementation STFahrplanGoogleHafasMixedApiResponseMapper

-(NSArray*)nearbyLocationsOfResponse:(id)response error:(NSError*)error
{
    NSMutableArray *nearbyLocations = [NSMutableArray array];
    
    if ([response[@"predictions"] isKindOfClass:[NSArray class]]) {
        NSArray *stopLocations = (NSArray *)response[@"predictions"];
        for (NSDictionary *dictLoc in stopLocations) {
            //NSString *locationId = [dictLoc objectForKey:@"id"];
            NSString *placeId = [dictLoc objectForKey:@"place_id"];
            //NSString *reference = [dictLoc objectForKey:@"reference"];
            
            double longitude = [[dictLoc objectForKey:@"lon"] doubleValue];
            double latitude = [[dictLoc objectForKey:@"lat"] doubleValue];
            NSString *locationName = [dictLoc objectForKey:@"description"];
            
            STFahrplanLocation *location = [STFahrplanLocationBuilder buildWithLocationId:placeId locationName:locationName latitude:latitude longitude:longitude];
            [nearbyLocations addObject:location];
        }
    }
    
    return nearbyLocations;
}

-(NSArray*)connectionsWithRouteOfResponse:(id)response error:(NSError**)error
{
    NSMutableArray *trips = [NSMutableArray array];
    
    if ([response[@"routes"] isKindOfClass:[NSArray class]]) {
        NSArray *routes = (NSArray *)response[@"routes"];
        
        for (NSDictionary *dictRoute in routes) {
            NSArray *legs = [dictRoute objectForKey:@"legs"];
            NSMutableArray *tripStationsArray = [NSMutableArray array];
            for (NSDictionary *leg in legs) {
                /*
                 "arrival_time" : {
                 "text" : "10:41am",
                 "time_zone" : "Europe/Berlin",
                 "value" : 1458294060
                 },
                 "departure_time" : {
                 "text" : "9:26am",
                 "time_zone" : "Europe/Berlin",
                 "value" : 1458289560
                 },
                 "distance" : {
                 "text" : "119 km",
                 "value" : 119113
                 },
                 "duration" : {
                 "text" : "1 hour 15 mins",
                 "value" : 4500
                 },
                 "end_address" : "Bremen, Germany",
                 "end_location" : {
                 "lat" : 53.0830958,
                 "lng" : 8.813413299999999
                 },
                 "start_address" : "Überseequartier, 20457 Hamburg, Germany",
                 "start_location" : {
                 "lat" : 53.54054,
                 "lng" : 9.999043
                 }
                 */
                
                NSString *arrival_time_timestamp = [leg objectForKey:@"arrival_time.value"];
                NSString *departure_time_timestamp = [leg objectForKey:@"departure_time.value"];
                
                NSString *start_address = [leg objectForKey:@"start_address"];
                NSDictionary *start_location = [leg objectForKey:@"start_location"];
                NSNumber *start_location_lat = [start_location objectForKey:@"lat"];
                NSNumber *start_location_lng = [start_location objectForKey:@"lng"];
                
                NSString *end_address = [leg objectForKey:@"end_address"];
                NSDictionary *end_location = [leg objectForKey:@"end_location"];
                NSNumber *end_location_lat = [end_location objectForKey:@"lat"];
                NSNumber *end_location_lng = [end_location objectForKey:@"lng"];
                
                STFahrplanTripModel *trip = [[STFahrplanTripModel alloc] init];
                
                //trip.
                //trip.departureDatetime = nil;
                
                NSArray *steps = [leg objectForKey:@"steps"];
                NSMutableArray *stepsArray = [NSMutableArray array];
                for (NSDictionary *step in steps) {
                    /*
                     {
                     "distance" : {
                     "text" : "3.8 km",
                     "value" : 3834
                     },
                     "duration" : {
                     "text" : "5 mins",
                     "value" : 300
                     },
                     "end_location" : {
                     "lat" : 53.554032,
                     "lng" : 10.006
                     },
                     "html_instructions" : "Subway towards Billstedt",
                     "polyline" : {
                     "points" : "kcxeI_}_|@@?FlCXbJRhINjI?`A?jAEzBIfBS`CK|@Mz@Mz@Qx@Mn@Qt@eA~CaAnCuAnDq@`BmBzDwA`C]f@m@p@_@Zc@\\c@Xg@VgAZeARc@Aq@?w@Is@Mq@Ym@UuAs@iC}AsAo@WEk@OgAMs@@_@Dc@HoA`@}@d@{@j@_CvAaA`@gATw@F{@C_@C_@I_A[{@g@_@_@aAeAc@y@_@m@Qk@_@aA[uA_@{BSmBEoAAeA@yABuAHsAP_BXaBXqA`@yAT}@\\sAVsAVyAR{ANyAb@eFHaABUBg@HuABe@@gAPkBNcBFu@Du@FaABiA@sB?eAAs@Eu@KwAEg@Gc@Ic@WkAYqAUu@k@wBYkAQqAIy@E_@Cc@Cy@Ey@_@{G"
                     },
                     "start_location" : {
                     "lat" : 53.54054,
                     "lng" : 9.999043
                     },
                     "transit_details" : {
                     "arrival_stop" : {
                     "location" : {
                     "lat" : 53.554032,
                     "lng" : 10.006
                     },
                     "name" : "Hamburg Hbf (S-Bahn)"
                     },
                     "arrival_time" : {
                     "text" : "9:31am",
                     "time_zone" : "Europe/Berlin",
                     "value" : 1458289860
                     },
                     "departure_stop" : {
                     "location" : {
                     "lat" : 53.54054,
                     "lng" : 9.999043
                     },
                     "name" : "Überseequartier"
                     },
                     "departure_time" : {
                     "text" : "9:26am",
                     "time_zone" : "Europe/Berlin",
                     "value" : 1458289560
                     },
                     "headsign" : "Billstedt",
                     "line" : {
                     "agencies" : [
                     {
                     "name" : "HVV",
                     "phone" : "011 49 40 19449",
                     "url" : "http://www.hvv.de/"
                     }
                     ],
                     "color" : "#00f291",
                     "short_name" : "U4",
                     "vehicle" : {
                     "icon" : "//maps.gstatic.com/mapfiles/transit/iw2/6/subway.png",
                     "local_icon" : "//maps.gstatic.com/mapfiles/transit/iw2/6/de-metro.png",
                     "name" : "Subway",
                     "type" : "SUBWAY"
                     }
                     },
                     "num_stops" : 2
                     },
                     "travel_mode" : "TRANSIT"
                     }
                     */
                    
                    
                    NSDictionary *start_location = [step objectForKey:@"start_location"];
                    NSDictionary *end_location = [step objectForKey:@"end_location"];
                    
                    NSDictionary *transit_details = [step objectForKey:@"transit_details"];
                    
                    NSDictionary *line = [transit_details objectForKey:@"line"];
                    double num_stops = [[transit_details objectForKey:@"num_stops"] integerValue];
                    
                    NSDictionary *arrival_stop_dict = [transit_details objectForKey:@"arrival_stop"];
                    NSString *arrival_stop_name = [arrival_stop_dict objectForKey:@"name"];
                    
                    NSDictionary *arrival_time_dict = [leg objectForKey:@"arrival_time"];
                    NSDate *arrival_time_value = [NSDate dateWithTimeIntervalSince1970:[[arrival_time_dict objectForKey:@"value"] doubleValue]];
                    
                    NSDateFormatter *df = [[NSDateFormatter alloc] init];
                    [df setDateFormat:@"HH:mm"];
                    
                    NSString *arrival_time_string_formatted = [df stringFromDate:arrival_time_value];
                    
                    NSDictionary *departure_stop_dict = [transit_details objectForKey:@"departure_stop"];
                    NSString *departure_stop_name = [departure_stop_dict objectForKey:@"name"];
                    
                    NSDictionary *vehicle = [line objectForKey:@"vehicle"];
                    NSString *vehicleType = [vehicle objectForKey:@"type"];
                    
                    //NSNumber *departure_time = [NSNumber numberWithDouble:[[leg objectForKey:@"departure_time.value"] doubleValue]];
                    NSDictionary *departure_time_dict = [leg objectForKey:@"departure_time"];
                    NSDate *departure_time_value = [NSDate dateWithTimeIntervalSince1970:[[departure_time_dict objectForKey:@"value"] doubleValue]];
                    NSString *departure_time_string_formatted = [df stringFromDate:departure_time_value];
                    
                    
                    STFahrplanSubTripModel *subTrip = [[STFahrplanSubTripModel alloc] init];
                    subTrip.transportationName = [line objectForKey:@"short_name"];
                    subTrip.transportationType = @"";
                    subTrip.direction = [leg objectForKey:@"headsign"];
                    subTrip.startPointName = departure_stop_name;
                    subTrip.startDate = departure_time_value;
                    subTrip.startPointTime = departure_time_string_formatted;
                    subTrip.startPointTimeFormatted = departure_time_string_formatted;
                    //subTrip.startPointDate = @"";
                    subTrip.startPointLatitude = nil;
                    subTrip.startPointLongitude = nil;
                    subTrip.startTrack = @"";
                    subTrip.endPointName = arrival_stop_name;
                    subTrip.endDate = arrival_time_value;
                    subTrip.endPointTime = arrival_time_string_formatted;
                    subTrip.endPointTimeFormatted = arrival_time_string_formatted;
                    //subTrip.endPointDate = @"";
                    subTrip.endPointLatitude = nil;
                    subTrip.endPointLongitude = nil;
                    subTrip.endTrack = @"";
                    subTrip.transportationType = vehicleType;
                    
                    [tripStationsArray addObject:subTrip];
                }
                
                trip.tripStations = tripStationsArray;
                
                [trips addObject:trip];
            }
        }
    }
    
    return trips;
}

-(NSArray*)departureBoardFromResponse:(id)responseObject error:(NSError**)error
{
    NSArray *departures = [MTLJSONAdapter modelsOfClass:[STFahrplanDeparture class] fromJSONArray:responseObject[@"Departure"] error:error];
    return departures;
}

-(NSArray*)nearbyStopsOfResponse:(id)response error:(NSError**)error
{
    NSArray *nearbyLocations = [MTLJSONAdapter modelsOfClass:[STFahrplanNearbyStopLocation class]
                                               fromJSONArray:response[@"stopLocationOrCoordLocation"]
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

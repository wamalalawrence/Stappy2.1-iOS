//
//  STFahrplanTransportationTypeStrategyGoogleMapsDirectionsApi.m
//  Stappy2
//
//  Created by Andrej Albrecht on 24.03.16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STFahrplanTransportationTypeStrategyGoogleMapsDirectionsApi.h"

@implementation STFahrplanTransportationTypeStrategyGoogleMapsDirectionsApi

/*
 Fahrzeugtyp
 Die Eigenschaft vehicle.type kann die folgenden Werte zurückgeben:
 
 
 Wert	Definition
 
 RAIL	Bahn
 METRO_RAIL	Stadtbahn
 SUBWAY	U-Bahn
 TRAM	Straßenbahn
 MONORAIL	Einschienenbahn
 HEAVY_RAIL	S-Bahn
 COMMUTER_TRAIN	Nahverkehr
 HIGH_SPEED_TRAIN	Schnellzug
 BUS	Bus
 INTERCITY_BUS	Fernbus
 TROLLEYBUS	Oberleitungsbus
 SHARE_TAXI	Sammeltaxi
 FERRY	Fähre
 CABLE_CAR	Seilbahn, die durch Drahtseile gezogen wird, in der Regel am Boden. Luftseilbahnen können zum Typ GONDOLA_LIFT gehören.
 GONDOLA_LIFT	Gondelbahn, eine Art Luftseilbahn.
 FUNICULAR	Standseilbahn. Besteht normalerweise aus zwei Wagen, von denen einer als Gegengewicht zum anderen dient.
 OTHER	Alle anderen Fahrzeuge geben diesen Typ zurück.
 */

-(BOOL)isPedestrian:(NSString *)transportationType
{
    
    return NO;
}

-(BOOL)isTrain:(NSString *)transportationType
{
    NSArray *busArray = @[
                          @"RAIL",
                          @"METRO_RAIL",
                          @"SUBWAY",
                          @"TRAM",
                          @"MONORAIL",
                          @"HEAVY_RAIL",
                          @"COMMUTER_TRAIN",
                          @"HIGH_SPEED_TRAIN"
                          ];
    
    NSArray *lowercaseArray = [busArray valueForKey:@"lowercaseString"];
    
    NSString *tp = transportationType;
    NSString *tType = [tp lowercaseString];
    
    /*
    tType = [[tType componentsSeparatedByCharactersInSet:
              [[NSCharacterSet letterCharacterSet] invertedSet]]
             componentsJoinedByString:@""];*/
    
    return [lowercaseArray containsObject:tType];
}

-(BOOL)isBus:(NSString *)transportationType
{
    NSArray *busArray = @[
                          @"BUS",
                          @"INTERCITY_BUS",
                          @"TROLLEYBUS"
                          ];
    
    NSArray *lowercaseArray = [busArray valueForKey:@"lowercaseString"];
    
    NSString *tp = transportationType;
    NSString *tType = [tp lowercaseString];
    
    /*
    tType = [[tType componentsSeparatedByCharactersInSet:
              [[NSCharacterSet letterCharacterSet] invertedSet]]
             componentsJoinedByString:@""];*/
    
    return [lowercaseArray containsObject:tType];
}

@end

//
//  STFahrplanHafasApiResponseMapper.m
//  Stappy2
//
//  Created by Cynthia Codrea on 08/04/2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STFahrplanHafasApiResponseMapper.h"
#import "STFahrplanLocation.h"
#import "STFahrplanLocationBuilder.h"

@implementation STFahrplanHafasApiResponseMapper

-(NSArray*)nearbyLocationsOfResponse:(id)response error:(NSError*)error
{
    NSMutableArray *nearbyLocations = [NSMutableArray array];
    
    if ([response[@"stopLocationOrCoordLocation"] isKindOfClass:[NSArray class]]) {
        NSArray *stopLocations = (NSArray *)response[@"stopLocationOrCoordLocation"];
        for (NSDictionary *dictLoc in stopLocations) {
            NSString *locationId = [dictLoc[@"StopLocation"] objectForKey:@"id"];
            double longitude = [[dictLoc[@"StopLocation"] objectForKey:@"lon"] doubleValue];
            double latitude = [[dictLoc[@"StopLocation"] objectForKey:@"lat"] doubleValue];
            NSString *locationName = [dictLoc[@"StopLocation"] objectForKey:@"name"];
            
            STFahrplanLocation *location = [STFahrplanLocationBuilder buildWithLocationId:locationId locationName:locationName latitude:latitude longitude:longitude];
            [nearbyLocations addObject:location];
        }
    }
    
    return nearbyLocations;
}

@end

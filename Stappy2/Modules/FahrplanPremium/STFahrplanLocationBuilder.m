//
//  STFahrplanLocationBuilder.m
//  Stappy2
//
//  Created by Andrej Albrecht on 16.03.16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STFahrplanLocationBuilder.h"

#import "STFahrplanLocation.h"

@implementation STFahrplanLocationBuilder

+(STFahrplanLocation *) buildWithLocationId:(NSString*)locationId locationName:(NSString*)locationName latitude:(double)latitude longitude:(double)longitude
{
    STFahrplanLocation *location = [[STFahrplanLocation alloc] init];
    location.locationID = locationId;
    location.latitude = latitude;
    location.longitude = longitude;
    location.locationName = locationName;
    
    return location;
}

@end

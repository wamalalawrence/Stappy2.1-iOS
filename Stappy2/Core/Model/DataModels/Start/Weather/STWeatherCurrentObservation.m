//
//  STWeatherCurrentObservation.m
//  Stappy2
//
//  Created by Cynthia Codrea on 12/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STWeatherCurrentObservation.h"

@implementation STWeatherCurrentObservation

+(NSDictionary*) JSONKeyPathsByPropertyKey {
    
    return @{
             @"condition":@"weather",
             @"imageUrl":@"icon_url",
             @"temperature":@"temp_c",
             @"windSpeed":@"wind_kph",
             @"date":@"observation_time",
             @"icon":@"icon",
             };
}

@end

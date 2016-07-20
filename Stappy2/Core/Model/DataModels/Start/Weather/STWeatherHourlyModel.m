//
//  STWeatherHourlyModel.m
//  Stappy2
//
//  Created by Cynthia Codrea on 08/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STWeatherHourlyModel.h"

@implementation STWeatherHourlyModel

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{
             @"condition":@"condition",
             @"imageForecastUrl":@"icon_url",
             @"windSpeed":@"wspd.metric",
             @"temp":@"temp.metric",
             @"hour":@"FCTTIME.hour",
             @"rainChance":@"pop",
             @"icon":@"icon"
             };
}

- (NSString *)hour
{
    return [NSString stringWithFormat:@"%@:00", _hour];
}

@end

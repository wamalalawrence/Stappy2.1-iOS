//
//  STWeatherModel.m
//  Stappy2
//
//  Created by Cynthia Codrea on 07/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STWeatherModel.h"

@implementation STWeatherModel

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{
             @"condition":@"conditions",
             @"imageForecastUrl":@"icon_url",
             @"windSpeed":@"avewind.kph",
             @"tempHigh":@"high.celsius",
             @"tempLow":@"low.celsius",
             @"rainChance":@"pop",
             @"dateDay":@"date.weekday",
             @"numericDay":@"date.day",
             @"numericMonth":@"date.month",
             @"icon":@"icon"
             };
}

-(NSString *)tempHigh {
    NSString *temp = @"";
    return [_tempHigh isKindOfClass:[NSNull class]] ? temp :_tempHigh;
}

-(NSString *)tempLow {
    NSString *temp = @"";
    return [_tempLow isKindOfClass:[NSNull class]] ? temp :_tempLow;
}

@end

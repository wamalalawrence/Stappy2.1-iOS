//
//  STWeatherHourlyModel.h
//  Stappy2
//
//  Created by Cynthia Codrea on 08/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface STWeatherHourlyModel : MTLModel <MTLJSONSerializing>

@property(nonatomic,copy)NSString *condition;
@property(nonatomic,copy)NSString *imageForecastUrl;
@property(nonatomic,copy)NSString *hour;
@property(nonatomic, copy)NSString *rainChance;
@property(nonatomic, copy)NSString* windSpeed;
@property(nonatomic,copy)NSString* icon;
//temeperature
@property(nonatomic, copy)NSString* temp;
@end

//
//  STWeatherModel.h
//  Stappy2
//
//  Created by Cynthia Codrea on 07/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface STWeatherModel : MTLModel <MTLJSONSerializing>

@property(nonatomic,copy)NSString *condition;
@property(nonatomic,copy)NSString *imageForecastUrl;
@property(nonatomic,copy)NSString *dateDay;
@property(nonatomic,assign)int numericDay;
@property(nonatomic, assign)int numericMonth;
@property(nonatomic, assign)int rainChance;
@property(nonatomic, assign)int windSpeed;
@property(nonatomic,copy)NSString *icon;
//temeperature
@property(nonatomic, copy)NSString* tempHigh;
@property(nonatomic, copy)NSString* tempLow;

@end

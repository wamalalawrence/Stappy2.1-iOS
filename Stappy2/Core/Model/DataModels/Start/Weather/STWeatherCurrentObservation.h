//
//  STWeatherCurrentObservation.h
//  Stappy2
//
//  Created by Cynthia Codrea on 12/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface STWeatherCurrentObservation : MTLModel <MTLJSONSerializing>

@property(nonatomic, copy)NSString* condition;
@property(nonatomic, copy)NSString* imageUrl;
@property(nonatomic, assign)int temperature;
@property(nonatomic, assign)int windSpeed;
@property(nonatomic, assign)int precipitations;
@property(nonatomic, copy)NSString* date;
@property(nonatomic, copy)NSString* icon;

@end

//
//  WeatherService.h
//  Stappy2
//
//  Created by Denis Grebennicov on 23/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STWeatherCurrentObservation;

@interface STWeatherService : NSObject

+ (STWeatherService *)sharedInstance;

- (void)weatherForCurrentDayAndForecastForRegion:(NSString *)region withCompletion:(void(^)(NSArray*, NSArray*, id currentObservation, NSError*))completion;
- (void)weatherForCurrentDayAndForecastWithCompletion:(void(^)(NSArray*, NSArray*, id currentObservation, NSError*))completion;
- (void)weatherForStartScreenWithCompletion:(void(^)(STWeatherCurrentObservation *, NSError *))completion;
@end

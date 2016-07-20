//
//  WeatherService.m
//  Stappy2
//
//  Created by Denis Grebennicov on 23/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <AFNetworking/AFHTTPSessionManager.h>
#import <Mantle/MTLJSONAdapter.h>
#import "STWeatherService.h"
#import "STRegionManager.h"
#import "STAppSettingsManager.h"
#import "STWeatherHourlyModel.h"
#import "STWeatherModel.h"
#import "STWeatherCurrentObservation.h"

static NSString * const STWeatherServiceErrorDomain = @"de.stappy.endios.WeatherService";

typedef NS_ENUM(NSInteger, WeatherServiceErrorCode)
{
    WeatherServiceMTLParsingErrorCode,
    WeatherServiceRequestFailureErrorCode
};

@implementation STWeatherService

+ (STWeatherService *)sharedInstance
{
    static STWeatherService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [[self alloc] init]; });
    return instance;
}

#pragma mark - Requests

- (void)weatherForCurrentDayAndForecastForRegion:(NSString *)region withCompletion:(void(^)(NSArray*, NSArray*, id currentObservation, NSError*))completion {
  
    NSString*cityName = [[STRegionManager sharedInstance] weatherStationForRegion:region];
    NSString *weatherUrl = [[STAppSettingsManager sharedSettingsManager] backendValueForKey:@"weather.conditionsAndForecastData"];
    weatherUrl = [[NSString stringWithFormat:@"%@%@.json", weatherUrl, cityName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    [[AFHTTPSessionManager manager] GET:weatherUrl parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (completion) {
            NSError *mtlError = nil;
            NSArray *hourlyCurrentDayForecasts = [MTLJSONAdapter modelsOfClass:[STWeatherHourlyModel class]
                                                                 fromJSONArray:responseObject[@"hourly_forecast"]
                                                                         error:&mtlError];
            NSArray *daysForecasts = [MTLJSONAdapter modelsOfClass:[STWeatherModel class]
                                                     fromJSONArray:responseObject[@"forecast"][@"simpleforecast"][@"forecastday"]
                                                             error:&mtlError];
            
            STWeatherCurrentObservation *currentObservation = [MTLJSONAdapter modelOfClass:[STWeatherCurrentObservation class ] fromJSONDictionary:responseObject[@"current_observation"] error:&mtlError];
                                        
            if (!mtlError) {
                completion(hourlyCurrentDayForecasts,daysForecasts,currentObservation, nil);
            } else {
                NSError *error = [NSError errorWithDomain:STWeatherServiceErrorDomain code:WeatherServiceMTLParsingErrorCode userInfo:nil];
                completion(nil,nil,nil,error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         error = [NSError errorWithDomain:STWeatherServiceErrorDomain code:WeatherServiceRequestFailureErrorCode userInfo:nil];
         completion(nil, nil, nil, error);
    }];
}

- (void)weatherForCurrentDayAndForecastWithCompletion:(void(^)(NSArray*, NSArray*, id currentObservation, NSError*))completion {
    NSString *region = [STRegionManager sharedInstance].currentRegion;
    [self weatherForCurrentDayAndForecastForRegion:region withCompletion:completion];
}

- (void)weatherForStartScreenWithCompletion:(void(^)(STWeatherCurrentObservation *, NSError *))completion {
    NSString*cityName = [[STRegionManager sharedInstance] weatherStationForRegion:[STRegionManager sharedInstance].currentRegion];
    NSString *weatherUrl = [[STAppSettingsManager sharedSettingsManager] backendValueForKey:@"weather.conditionsAndForecastData"];
    weatherUrl = [[NSString stringWithFormat:@"%@%@.json", weatherUrl, cityName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    [[AFHTTPSessionManager manager] GET:weatherUrl parameters:nil success:^(NSURLSessionDataTask *_Nonnull task, id _Nonnull responseObject) {
        if (completion) {
            NSError *mtlError = nil;
            STWeatherCurrentObservation *currentObservation = [MTLJSONAdapter modelOfClass:[STWeatherCurrentObservation class ] fromJSONDictionary:responseObject[@"current_observation"] error:&mtlError];
                                        
            if (!mtlError) {
                completion(currentObservation,nil);
            } else {
                NSError *error = [NSError errorWithDomain:STWeatherServiceErrorDomain code:WeatherServiceMTLParsingErrorCode userInfo:nil];
                completion(nil, error);
            }
        }
    } failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        error = [NSError errorWithDomain:STWeatherServiceErrorDomain code:WeatherServiceRequestFailureErrorCode userInfo:nil];
        completion(nil, error);
    }];
}


@end

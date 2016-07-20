//
// Created by Denis Grebennicov on 23/05/16.
// Copyright (c) 2016 endios GmbH. All rights reserved.
//

#import "STRegionService.h"

@implementation STRegionService

+ (STRegionService *)sharedInstance
{
    static STRegionService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (void)getPostalCodeFromUserLocation:(CLLocationCoordinate2D)location success:(void (^)(NSString *))completion failure:(void (^)(NSError *))failure {
    NSString *googleApiKey = [STAppSettingsManager sharedSettingsManager].googleApiKey;
    NSDictionary *params = @{
            @"latlng": [NSString stringWithFormat:@"%f,%f", location.latitude, location.longitude],
            @"key": googleApiKey
    };

    NSString *url = [STAppSettingsManager sharedSettingsManager].googleMapsAPI[@"api_url"];

    [[AFHTTPSessionManager manager] GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject && [responseObject[@"results"] isKindOfClass:[NSArray class]]) {
            
            NSArray*results = responseObject[@"results"];
            
            if (results.count>0) {
                NSArray *addressComponents = results[0][@"address_components"];
                
                NSString *postalCodeData;
                
                for (NSDictionary*dict in addressComponents) {
                    
                    NSArray*types = dict[@"types"];
                    
                    for (NSString*type in types) {
                        if ([type isEqualToString:@"postal_code"]) {
                            postalCodeData = dict[@"short_name"];
                        }
                    }
                    
                }
                
                if (postalCodeData) completion(postalCodeData);
                else
                {
                    NSError *error = [[NSError alloc] initWithDomain:@"NoPostalCodeFoundInJSON" code:101 userInfo:nil];
                    failure(error);
                }
            }
            else{
                NSError *error = [[NSError alloc] initWithDomain:@"NoPostalCodeFoundInJSON" code:101 userInfo:nil];
                failure(error);
            }
            
           

        }
        else{
            NSError *error = [[NSError alloc] initWithDomain:@"NoPostalCodeFoundInJSON" code:101 userInfo:nil];
            failure(error);
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
    

}

- (void)getRegionIdFromPostalCode:(NSString *)postalCode success:(void (^)(NSNumber *))completion failure:(void (^)(NSError *))failure {
    NSString *url = [[STRequestsHandler sharedInstance] buildUrl:@"/region"];
    
    [[AFHTTPSessionManager manager] GET:url parameters:@{@"postalcode": postalCode} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *content = responseObject[@"content"];
        if ([content isEqual:[NSNull null]])
        {
            NSError *error = [[NSError alloc] initWithDomain:@"JSON Content is NULL" code:102 userInfo:nil];
            failure(error);
            return;
        }
        
        NSNumber *regionId = responseObject[@"content"][@"id"];
        completion(regionId);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(error);
    }];
    
    
  }

@end
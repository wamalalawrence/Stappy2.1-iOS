//
// Created by Denis Grebennicov on 23/05/16.
// Copyright (c) 2016 endios GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPSessionManager.h>
#import "STAppSettingsManager.h"
#import "STRequestsHandler.h"

@interface STRegionService : NSObject

+ (STRegionService *)sharedInstance;

- (void)getPostalCodeFromUserLocation:(CLLocationCoordinate2D)location success:(void (^)(NSString *))completion failure:(void (^)(NSError *))error;

- (void)getRegionIdFromPostalCode:(NSString *)postalCode success:(void (^)(NSNumber *))completion failure:(void (^)(NSError *))failure;

@end
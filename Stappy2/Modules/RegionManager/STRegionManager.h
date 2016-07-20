//
// Created by Denis Grebennicov on 23/05/16.
// Copyright (c) 2016 endios GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STRegionManager : NSObject
@property (nonatomic, strong) NSString *currentRegion;
@property (nonatomic, strong, readonly) NSArray<NSString *> *selectedAndCurrentRegions;

+ (STRegionManager *)sharedInstance;

- (void)setDefaultRegion;
- (void)getRegionFromCurrentUserLocation;
-(NSDictionary*)positionForRegion:(NSString*)region;
-(NSString*)weatherStationForRegion:(NSString*)region;


@end
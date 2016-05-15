//
//  STFahrplanTransportationTypeHelper.m
//  Schwedt
//
//  Created by Andrej Albrecht on 16.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STFahrplanTransportationTypeHelper.h"

#import "STAppSettingsManager.h"

#import "STFahrplanTransportationTypeStrategy.h"
#import "STFahrplanTransportationTypeStrategyGoogleMapsDirectionsApi.h"
#import "STFahrplanTransportationTypeStrategyHafas.h"

static STFahrplanTransportationTypeStrategy *staticTransportationTypeStrategy;

@interface STFahrplanTransportationTypeHelper()
@property (nonatomic,strong) STFahrplanTransportationTypeStrategy *transportationTypeStrategy;
@end


@implementation STFahrplanTransportationTypeHelper

+(STFahrplanTransportationTypeStrategy *)transportationTypeStrategy
{
    if (staticTransportationTypeStrategy!=nil) {
        return staticTransportationTypeStrategy;
    }
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    NSString *transportationTypeStrategyString = [settings backendValueForKey:@"fahrplan.fahrplan_api.api_transportationtype_strategy"];
    
    STFahrplanTransportationTypeStrategy *transportationTypeStrategy = [[NSClassFromString(transportationTypeStrategyString) alloc] init];
    if (transportationTypeStrategy!=nil) {
        staticTransportationTypeStrategy = transportationTypeStrategy;
    }else{
        @throw [NSException exceptionWithName:@"STFahrplanTransportationTypeStrategy not found!" reason:@"Please check the STFahrplanTransportationTypeStrategy in the settings file. (fahrplan.fahrplan_api.api_transportationtype_strategy)" userInfo:nil];
    }
    return transportationTypeStrategy;
}

+(BOOL)isPedestrian:(NSString*)transportationType
{
    STFahrplanTransportationTypeStrategy *ttStrategy = [self transportationTypeStrategy];
    return [ttStrategy isPedestrian:transportationType];
}

+(BOOL)isTrain:(NSString*)transportationType
{
    STFahrplanTransportationTypeStrategy *ttStrategy = [self transportationTypeStrategy];
    return [ttStrategy isTrain:transportationType];
}

+(BOOL)isBus:(NSString*)transportationType
{
    STFahrplanTransportationTypeStrategy *ttStrategy = [self transportationTypeStrategy];
    return [ttStrategy isBus:transportationType];
}

@end

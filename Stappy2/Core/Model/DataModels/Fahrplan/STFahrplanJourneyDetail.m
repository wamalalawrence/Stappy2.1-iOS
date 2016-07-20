//
//  STFahrplanJourneyDetail.m
//  Schwedt
//
//  Created by Andrej Albrecht on 16.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STFahrplanJourneyDetail.h"
#import "STFahrplanJourneyStop.h"
#import "STFahrplanJourneyName.h"
#import "STFahrplanJourneyDirection.h"

@implementation STFahrplanJourneyDetail

+(NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{@"stops":@"Stops",
             @"names":@"Names",
             @"directions":@"Directions"};
}

+ (NSValueTransformer *)stopsJSONTransformer __unused {
    return [MTLValueTransformer transformerWithBlock:^id(id stops) {
        if ( [stops isKindOfClass:[NSArray class]] ) {
            return [[MTLValueTransformer mtl_JSONArrayTransformerWithModelClass:[STFahrplanJourneyStop class]] transformedValue:stops];
        }
        else if ( [stops isKindOfClass:[NSDictionary class]] ) {
            NSMutableArray *tripStations = [[NSMutableArray alloc] init];
            [stops addObject:[[MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[STFahrplanJourneyStop class]] transformedValue:tripStations]];
            return stops;
        }
        return nil;
    }];
}

+ (NSValueTransformer *)namesJSONTransformer __unused {
    return [MTLValueTransformer transformerWithBlock:^id(id names) {
        if ( [names isKindOfClass:[NSArray class]] ) {
            return [[MTLValueTransformer mtl_JSONArrayTransformerWithModelClass:[STFahrplanJourneyName class]] transformedValue:names];
        }
        else if ( [names isKindOfClass:[NSDictionary class]] ) {
            NSMutableArray *names = [[NSMutableArray alloc] init];
            [names addObject:[[MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[STFahrplanJourneyName class]] transformedValue:names]];
            return names;
        }
        return nil;
    }];
}

+ (NSValueTransformer *)directionsJSONTransformer __unused {
    return [MTLValueTransformer transformerWithBlock:^id(id directions) {
        if ( [directions isKindOfClass:[NSArray class]] ) {
            return [[MTLValueTransformer mtl_JSONArrayTransformerWithModelClass:[STFahrplanJourneyDirection class]] transformedValue:directions];
        }
        else if ( [directions isKindOfClass:[NSDictionary class]] ) {
            NSMutableArray *directions = [[NSMutableArray alloc] init];
            [directions addObject:[[MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[STFahrplanJourneyDirection class]] transformedValue:directions]];
            return directions;
        }
        return nil;
    }];
}


@end

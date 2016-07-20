//
//  STFahrplanDepartureBoard.m
//  Schwedt
//
//  Created by Andrej Albrecht on 11.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STFahrplanDepartureBoard.h"
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>
#import "STFahrplanDeparture.h"

@implementation STFahrplanDepartureBoard

/*
 <DepartureBoard xmlns="hafas_rest_v1">
 <Departure direction="Gardermoen" name="F2" trainNumber="3781"
 trainCategory="5" stopid="A=1@O=Oslo S@X=10755332@Y=59910200 @U=70@L=7600100@" stop="Oslo S" date="2014-06-01" time="18:00:00" track="13">
 <JourneyDetailRef ref="1|25|0|70|1062014"/>
 </Departure>
 <Departure direction="Göteborg C" name="R20" trainNumber="127"
 trainCategory="2" stopid="A=1@O=Oslo S@X=10755332@Y=59910200 @U=70@L=7600100@" stop="Oslo S" date="2014-06-01" time="18:02:00" track="18">
 <JourneyDetailRef ref="1|1977|0|70|1062014"/>
 </Departure>
 <Departure direction="Skøyen" name="L22" trainNumber="1928"
 trainCategory="5" stopid="A=1@O=Oslo S@X=10755332@Y=59910200 @U=70@L=7600100@" stop="Oslo S" date="2014-06-01" time="18:03:00" track="7">
 <JourneyDetailRef ref="1|329|0|70|1062014"/>
 </Departure>
 ...
 <DepartureBoard>
 */

+(NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{
             @"departures":@"DepartureBoard"
             };
}

+ (NSValueTransformer *)departuresJSONTransformer __unused {
    return [MTLValueTransformer transformerWithBlock:^id(id departures) {
        if ( [departures isKindOfClass:[NSArray class]] ) {
            return [[MTLValueTransformer mtl_JSONArrayTransformerWithModelClass:[STFahrplanDeparture class]] transformedValue:departures];
        }
        else if ( [departures isKindOfClass:[NSDictionary class]] ) {
            NSMutableArray *departures = [[NSMutableArray alloc] init];
            [departures addObject:[[MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[STFahrplanDeparture class]] transformedValue:departures]];
            return departures;
        }
        return nil;
    }];
}

@end

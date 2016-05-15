//
//  STFahrplanNearbyStopLocation.m
//  Schwedt
//
//  Created by Andrej Albrecht on 09.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STFahrplanNearbyStopLocation.h"

@implementation STFahrplanNearbyStopLocation

+(NSDictionary*)JSONKeyPathsByPropertyKey {
    
    
    //Demo
    return @{@"locationID":@"StopLocation.id",
             @"locationName":@"StopLocation.name",
             @"latitude":@"StopLocation.lat",
             @"longitude":@"StopLocation.lon"
             // @"distance":@"StopLocation.dist"
             
             };
    
    /*
     return @{@"locationID":@"id",
     @"locationName":@"name",
     @"latitude":@"lat",
     @"longitude":@"lon"
     };*/
    
}

- (NSString *)autocompleteString
{
    return self.locationName;
}

@end

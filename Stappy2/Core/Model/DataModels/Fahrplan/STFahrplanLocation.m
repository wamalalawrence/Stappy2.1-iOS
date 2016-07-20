//
//  STFahrplanLocation.h
//  Stappy2
//
//  Created by Cynthia Codrea on 20/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STFahrplanLocation.h"

@implementation STFahrplanLocation

+(NSDictionary*)JSONKeyPathsByPropertyKey {
    
    /*
     //Demo
    return @{@"locationID":@"StopLocation.id",
             @"locationName":@"StopLocation.name",
             @"latitude":@"StopLocation.lat",
             @"longitude":@"StopLocation.lon"
            // @"distance":@"StopLocation.dist"
             
             };
     */
     
    
    return @{@"locationID":@"id",
             @"locationName":@"name",
             @"latitude":@"lat",
             @"longitude":@"lon"
             };
    
}

- (NSString *)autocompleteString
{
    return self.locationName;
}

@end

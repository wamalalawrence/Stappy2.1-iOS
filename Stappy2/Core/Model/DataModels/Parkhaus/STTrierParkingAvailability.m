//
//  STTrierParkingAvailability.m
//  Stappy2
//
//  Created by Pavel Nemecek on 11/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STTrierParkingAvailability.h"

@implementation STTrierParkingAvailability

+(instancetype)availabilityFromDictionary:(NSDictionary*)dictionary{

    STTrierParkingAvailability*avail = [[STTrierParkingAvailability alloc] init];
    avail.shortMax = [[dictionary objectForKey:@"shortmax"] integerValue];
    avail.shortFree = [[dictionary objectForKey:@"shortfree"] integerValue];
    avail.name = [dictionary objectForKey:@"phname"];
    return avail;
}
@end

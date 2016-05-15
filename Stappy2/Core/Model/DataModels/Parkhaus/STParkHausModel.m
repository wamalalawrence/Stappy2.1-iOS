//
//  STParkHausModel.m
//  Stappy2
//
//  Created by Cynthia Codrea on 18/12/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STParkHausModel.h"

#import "Utils.h"

@implementation STParkHausModel

- (id)initWithDictionary:(NSDictionary*)dict {
    self = [super init];
    if (self) {
        self.id = [[Utils sanitize:[dict valueForKey:@"id"] withDefault:0] longValue];
        self.name = [Utils sanitize:[dict valueForKey:@"name"] withDefault:@""];
        self.address = [Utils sanitize:[dict valueForKey:@"street1"] withDefault:@""];
        self.status = [Utils sanitize:[dict valueForKey:@"status"] withDefault:@""];
        self.capacity_actual_updated_at = [Utils sanitize:[dict valueForKey:@"capacity_actual_updated_at"] withDefault:@""];
        self.longitude = [NSNumber numberWithFloat:[[Utils sanitize:[dict valueForKey:@"longitude"] withDefault:0] floatValue]];
        self.latitude = [NSNumber numberWithFloat:[[Utils sanitize:[dict valueForKey:@"latitude"] withDefault:0] floatValue]];
        self.street1 = [Utils sanitize:[dict valueForKey:@"street1"] withDefault:@""];
        self.street2 = [Utils sanitize:[dict valueForKey:@"street2"] withDefault:@""];
        self.city = [Utils sanitize:[dict valueForKey:@"city"] withDefault:@""];
        self.zip = [Utils sanitize:[dict valueForKey:@"zip"] withDefault:@""];
        self.state = [Utils sanitize:[dict valueForKey:@"state"] withDefault:@""];
        self.floor_level = [[Utils sanitize:[dict valueForKey:@"floor_level"] withDefault:0] longValue];
        self.country = [Utils sanitize:[dict valueForKey:@"country"] withDefault:@""];
        self.email = [Utils sanitize:[dict valueForKey:@"email"] withDefault:@""];
        self.phone = [Utils sanitize:[dict valueForKey:@"phone"] withDefault:@""];
        self.website = [Utils sanitize:[dict valueForKey:@"website"] withDefault:@""];
        self.capacity_total = [[Utils sanitize:[dict valueForKey:@"capacity_total"] withDefault:0] longValue];
        self.capacity_actual = [[Utils sanitize:[dict valueForKey:@"capacity_actual"] withDefault:0] longValue];
        self.capacity_truck = [[Utils sanitize:[dict valueForKey:@"capacity_truck"] withDefault:0] longValue];
        self.occupancy = [Utils sanitize:[dict valueForKey:@"occupancy"] withDefault:@""];
        self.charging_demand = [Utils sanitize:[dict valueForKey:@"charging_demand"] withDefault:@""];
        self.charging_plug = [Utils sanitize:[dict valueForKey:@"charging_plug"] withDefault:@""];
        self.charging_payment = [Utils sanitize:[dict valueForKey:@"charging_payment"] withDefault:@""];
        self.charging_price = [Utils sanitize:[dict valueForKey:@"charging_price"] withDefault:@""];
        self.image_url = [Utils sanitize:[dict valueForKey:@"image_url"] withDefault:@""];
        self.descriptionParkhaus = [Utils sanitize:[dict valueForKey:@"description"] withDefault:@""];
        self.restrictions = [Utils sanitize:[dict valueForKey:@"restrictions"] withDefault:@""];
        self.restriction_height = [[Utils sanitize:[dict valueForKey:@"restriction_height"] withDefault:0] longValue];
        self.restriction_width = [[Utils sanitize:[dict valueForKey:@"restriction_width"] withDefault:0] longValue];
        self.restriction_length = [[Utils sanitize:[dict valueForKey:@"restriction_length"] withDefault:0] longValue];
        self.restriction_weight = [[Utils sanitize:[dict valueForKey:@"restriction_weight"] withDefault:0] longValue];
        self.no_costs = [Utils sanitize:[dict valueForKey:@"no_costs"] withDefault:@""];
        self.access = [Utils sanitize:[dict valueForKey:@"access"] withDefault:@""];
        self.location = [Utils sanitize:[dict valueForKey:@"location"] withDefault:@""];
        self.features_mask = [[Utils sanitize:[dict valueForKey:@"features_mask"] withDefault:0] longValue];
        self.payments_mask = [[Utils sanitize:[dict valueForKey:@"payments_mask"] withDefault:0] longValue];
        self.authentications_mask = [Utils sanitize:[dict valueForKey:@"authentications_mask"] withDefault:@""];
        self.openingTimes = [Utils sanitize:[dict valueForKey:@"opening_times"] withDefault:@""];
        self.rates = [Utils sanitize:[dict valueForKey:@"rates"] withDefault:@""];
        self.url_prebooking = [Utils sanitize:[dict valueForKey:@"url_prebooking"] withDefault:@""];
        self.url_long_term_parking = [Utils sanitize:[dict valueForKey:@"url_long_term_parking"] withDefault:@""];
        self.url_multi_purpose_card = [Utils sanitize:[dict valueForKey:@"url_multi_purpose_card"] withDefault:@""];
    }
    return self;
}

@end

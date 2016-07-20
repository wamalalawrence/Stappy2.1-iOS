//
//  STParkHausModel.h
//  Stappy2
//
//  Created by Cynthia Codrea on 18/12/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STMainModel.h"

@interface STParkHausModel : STMainModel

@property(nonatomic,copy)NSString* name;
@property(nonatomic,copy)NSString* address;
@property(nonatomic,copy)NSString* occupancy;
@property(nonatomic,assign)long id;
@property(nonatomic,copy)NSString* state;
@property(nonatomic,copy)NSString* country;
@property(nonatomic,copy)NSString* status;
@property(nonatomic,assign)long capacity_total;
@property(nonatomic,assign)long capacity_actual;
@property(nonatomic,copy)NSString* capacity_actual_updated_at;
@property(nonatomic,assign)long features_mask;
@property(nonatomic,assign)long payments_mask;
@property(nonatomic,copy)NSString* authentications_mask;
@property(nonatomic,assign)long restriction_height;
@property(nonatomic,assign)long restriction_width;
@property(nonatomic,assign)long restriction_length;
@property(nonatomic,assign)long restriction_weight;
@property(nonatomic,strong)NSString *openingTimes;
@property(nonatomic,assign)long floor_level;
@property(nonatomic,copy)NSString* charging_plug;
@property(nonatomic,copy)NSString* charging_demand;
@property(nonatomic,copy)NSString* charging_payment;
@property(nonatomic,copy)NSString* charging_price;
@property(nonatomic,copy)NSString* image_url;
@property(nonatomic,copy)NSString* no_costs;

@property(nonatomic,copy)NSString* access;
@property(nonatomic,copy)NSString* location;
@property(nonatomic,copy)NSString* url_prebooking;
@property(nonatomic,copy)NSString* url_long_term_parking;
@property(nonatomic,copy)NSString* url_multi_purpose_card;
@property(nonatomic,copy)NSString* restrictions;
@property(nonatomic,assign)long capacity_truck;
@property(nonatomic,copy)NSString* rates;
@property(nonatomic,copy)NSString* street1;
@property(nonatomic,copy)NSString* street2;
@property(nonatomic,copy)NSString* zip;
@property(nonatomic,copy)NSString* website;
@property(nonatomic,copy)NSString* descriptionParkhaus;

- (id)initWithDictionary:(NSDictionary*)dict;

@end

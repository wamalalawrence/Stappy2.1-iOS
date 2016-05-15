//
//  STFahrplanTripModel.h
//  Stappy2
//
//  Created by Cynthia Codrea on 20/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface STFahrplanTripModel : MTLModel <MTLJSONSerializing>

@property(nonatomic,copy)NSString* duration;
//array of stations models for the route.
@property(nonatomic,strong)NSArray* tripStations;
@property(nonatomic,readonly) NSUInteger changeNumber;

@property(nonatomic,readonly) NSDate *departureDatetime;
@property(nonatomic,readonly) NSDate *arrivalDatetime;

@end

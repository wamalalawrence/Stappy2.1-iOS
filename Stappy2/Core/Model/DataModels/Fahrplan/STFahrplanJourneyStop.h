//
//  STFahrplanJourneyStop.h
//  Schwedt
//
//  Created by Andrej Albrecht on 16.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface STFahrplanJourneyStop : MTLModel <MTLJSONSerializing>

@property(strong,nonatomic) NSString *identifier;
@property(strong,nonatomic) NSString *name;
@property(strong,nonatomic) NSString *routeIdx;
@property(strong,nonatomic) NSString *extId;
@property(strong,nonatomic) NSString *lon;
@property(strong,nonatomic) NSString *lat;
@property(strong,nonatomic) NSString *depDate;
@property(strong,nonatomic) NSString *depTime;
@property(strong,nonatomic) NSString *track;

@end

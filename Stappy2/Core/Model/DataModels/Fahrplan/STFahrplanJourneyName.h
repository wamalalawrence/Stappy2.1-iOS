//
//  STFahrplanJourneyName.h
//  Schwedt
//
//  Created by Andrej Albrecht on 16.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface STFahrplanJourneyName : MTLModel <MTLJSONSerializing>

@property(strong,nonatomic) NSString *name;
@property(strong,nonatomic) NSString *routeIdxFrom;
@property(strong,nonatomic) NSString *routeIdxTo;
@property(strong,nonatomic) NSString *number;
@property(strong,nonatomic) NSString *category;

@end

//
//  STFahrplanJourneyDirection.h
//  Schwedt
//
//  Created by Andrej Albrecht on 16.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface STFahrplanJourneyDirection : MTLModel <MTLJSONSerializing>

@property(strong,nonatomic) NSString *routeIdxFrom;
@property(strong,nonatomic) NSString *routeIdxTo;
@property(strong,nonatomic) NSString *value;


@end

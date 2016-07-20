//
//  STFahrplanJourneyDetail.h
//  Schwedt
//
//  Created by Andrej Albrecht on 16.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface STFahrplanJourneyDetail : MTLModel <MTLJSONSerializing>

@property (strong,nonatomic) NSArray *stops;
@property(nonatomic,strong) NSArray *names;
@property(nonatomic,strong) NSArray *directions;

@end

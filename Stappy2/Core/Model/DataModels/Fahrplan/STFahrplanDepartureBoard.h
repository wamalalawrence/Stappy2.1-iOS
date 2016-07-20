//
//  STFahrplanDepartureBoard.h
//  Schwedt
//
//  Created by Andrej Albrecht on 11.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface STFahrplanDepartureBoard : MTLModel <MTLJSONSerializing>

@property(nonatomic,strong) NSArray *departures;

/*
 <Departure direction="Gardermoen" name="F2" trainNumber="3781"
 trainCategory="5" stopid="A=1@O=Oslo S@X=10755332@Y=59910200 @U=70@L=7600100@" stop="Oslo S" date="2014-06-01" time="18:00:00" track="13">
 <JourneyDetailRef ref="1|25|0|70|1062014"/>
 */

@end

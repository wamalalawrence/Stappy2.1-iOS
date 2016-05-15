//
//  STFahrplanDeparture.h
//  Schwedt
//
//  Created by Andrej Albrecht on 11.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface STFahrplanDeparture : MTLModel <MTLJSONSerializing>

@property(nonatomic,strong) NSString *direction;
@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *type;
@property(nonatomic,strong) NSString *trainNumber;
@property(nonatomic,strong) NSString *trainCategory;
@property(nonatomic,strong) NSString *stopid;
@property(nonatomic,strong) NSString *stop;
@property(nonatomic,strong) NSString *date;
@property(nonatomic,strong) NSString *time;
@property(nonatomic,strong) NSString *timeFormatted;
@property(nonatomic,strong) NSDate *datetime;
//@property(nonatomic,strong) NSString *track;
@property(nonatomic,strong) NSString *journeyDetailRef;


/*
 <Departure direction="Gardermoen" name="F2" trainNumber="3781"
 trainCategory="5" stopid="A=1@O=Oslo S@X=10755332@Y=59910200 @U=70@L=7600100@" stop="Oslo S" date="2014-06-01" time="18:00:00" track="13">
 <JourneyDetailRef ref="1|25|0|70|1062014"/>
*/

@end

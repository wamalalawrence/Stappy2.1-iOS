//
//  STFahrplanDeparture.m
//  Schwedt
//
//  Created by Andrej Albrecht on 11.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STFahrplanDeparture.h"

@implementation STFahrplanDeparture

+(NSDictionary*)JSONKeyPathsByPropertyKey {
    /*
     <Departure direction="Gardermoen" name="F2" trainNumber="3781"
     trainCategory="5" stopid="A=1@O=Oslo S@X=10755332@Y=59910200 @U=70@L=7600100@" stop="Oslo S" date="2014-06-01" time="18:00:00" track="13">
     <JourneyDetailRef ref="1|25|0|70|1062014"/>
     */
    
    /*
    return @{@"direction":@"direction",
             @"name":@"name"};
    */
    
    return @{@"direction":@"direction",
             @"name":@"name",
             @"type":@"type",
             @"trainNumber":@"trainNumber",
             @"trainCategory":@"trainCategory",
             @"stopid":@"stopid",
             @"stop":@"stop",
             @"date":@"date",
             @"time":@"time",
             @"timeFormatted":@"time",
             @"journeyDetailRef":@"JourneyDetailRef.ref"
             };
    
    
    //@"track":@"track",
}

+ (NSValueTransformer *)timeFormattedJSONTransformer __unused
{
    return [MTLValueTransformer transformerWithBlock:^id(NSString *timeFormatted) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@":00$" options:0 error:NULL];
        NSString *modifiedString = [regex stringByReplacingMatchesInString:timeFormatted options:0 range:NSMakeRange(0, [timeFormatted length]) withTemplate:@""];
        
        return modifiedString;
    }];
}

@end

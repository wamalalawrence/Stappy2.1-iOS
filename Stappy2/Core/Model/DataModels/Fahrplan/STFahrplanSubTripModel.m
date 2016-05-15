//
//  STFahrplanSubTripModel.m
//  Stappy2
//
//  Created by Cynthia Codrea on 22/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STFahrplanSubTripModel.h"

@implementation STFahrplanSubTripModel

+(NSDictionary*)JSONKeyPathsByPropertyKey {
    
    return @{
             @"transportationName":@"name",
             @"transportationType":@"category",
             @"direction":@"direction",
             
             @"startPointName":@"Origin.name",
             @"startPointTime":@"Origin.time",
             @"startPointDate":@"Origin.date",
             @"startPointTimeFormatted":@"Origin.time",
             @"startPointDateFormatted":@"Origin.date",
             @"startPointLatitude":@"Origin.lat",
             @"startPointLongitude":@"Origin.lon",
             @"startTrack":@"Origin.track",
             
             @"endPointName":@"Destination.name",
             @"endPointTime":@"Destination.time",
             @"endPointDate":@"Destination.date",
             @"endPointTimeFormatted":@"Destination.time",
             @"endPointDateFormatted":@"Destination.date",
             @"endPointLatitude":@"Destination.lat",
             @"endPointLongitude":@"Destination.lon",
             @"endTrack":@"Destination.track"
             
             };
    
    /*
    return @{
             @"transportationName":@"name",
             @"transportationType":@"category",
             @"direction":@"direction",
             
             @"startPointName":@"Origin.name",
             @"startPointTime":@"Origin.time",
             @"startPointDate":@"Origin.date",
             @"startPointLatitude":@"Origin.lat",
             @"startPointLongitude":@"Origin.lon",
             
             @"endPointName":@"Destination.name",
             @"endPointTime":@"Destination.time",
             @"endPointDate":@"Destination.date",
             @"endPointLatitude":@"Destination.lat",
             @"endPointLongitude":@"Destination.lon"
             
             };*/
}

+ (NSValueTransformer *)startPointTimeFormattedJSONTransformer __unused
{
    return [MTLValueTransformer transformerWithBlock:^id(NSString *startPointTimeFormatted) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@":00$" options:0 error:NULL];
        NSString *modifiedString = [regex stringByReplacingMatchesInString:startPointTimeFormatted options:0 range:NSMakeRange(0, [startPointTimeFormatted length]) withTemplate:@""];
        
        return modifiedString;
    }];
}

+ (NSValueTransformer *)endPointTimeFormattedJSONTransformer __unused
{
    return [MTLValueTransformer transformerWithBlock:^id(NSString *endPointTimeFormatted) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@":00$" options:0 error:NULL];
        NSString *modifiedString = [regex stringByReplacingMatchesInString:endPointTimeFormatted options:0 range:NSMakeRange(0, [endPointTimeFormatted length]) withTemplate:@""];
        
        return modifiedString;
    }];
}

- (NSDate *)startDate
{
    if (_startDate) {
        return _startDate;
    }
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [NSString stringWithFormat:@"%@ %@",self.startPointDate, self.startPointTime];
    NSDate *myDate = [df dateFromString:dateString];
    
    return myDate;
}

- (NSDate *)endDate
{
    if (_endDate) {
        return _endDate;
    }
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [NSString stringWithFormat:@"%@ %@",self.endPointDate, self.endPointTime];
    NSDate *myDate = [df dateFromString:dateString];
    
    return myDate;
}

-(void)setStartPointTime:(NSString *)startPointTime
{
    _startPointTime = startPointTime;
}


@end

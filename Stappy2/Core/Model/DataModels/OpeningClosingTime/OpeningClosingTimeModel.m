//
//  OpeningClosingTimeModel.m
//  Stappy2
//
//  Created by Denis Grebennicov on 20/01/16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "OpeningClosingTimeModel.h"
#import "NSDate+DKHelper.h"

const double secondsInAnHour = 3600;
const double secondInAMinute = 60;

@implementation OpeningClosingTimeModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"closingTime": @"closingTime",
             @"openingTime": @"openingTime",
             @"dayOfWeek": @"dayOfWeek",
            };
}

-(NSInteger)remainingOpeningTime {
    if (!_remainingOpeningTime) {
        _remainingOpeningTime = 0;
    }
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    [components setHour:[self.closingTime integerValue]];
    NSDate *closingDate = [calendar dateFromComponents:components];
    
    NSTimeInterval distanceBetweenDates = [closingDate timeIntervalSinceDate:[NSDate date]];
   return distanceBetweenDates;
}

-(NSInteger)remainingOpeningHours {
    if (!_remainingOpeningHours) {
        _remainingOpeningHours = self.remainingOpeningTime / secondsInAnHour;
    }
    return _remainingOpeningHours;
}

-(NSInteger)remainingOpeningMinutes {
    if (!_remainingOpeningMinutes) {
        NSUInteger remainingMinutes = self.remainingOpeningTime - (self.remainingOpeningHours * secondsInAnHour);
        _remainingOpeningMinutes = remainingMinutes / secondInAMinute;
    }
    return _remainingOpeningMinutes;
}
@end

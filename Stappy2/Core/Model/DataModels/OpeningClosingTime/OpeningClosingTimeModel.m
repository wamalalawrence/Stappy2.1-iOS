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
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:now];
    [components setHour:[self.closingTime integerValue]];
    NSDate *closingDate = [calendar dateFromComponents:components];
    
    if ([NSDate date].day != [self.dayOfWeek integerValue] && [self.closingTime integerValue]<12 ) {
        return 0;
    }

    NSTimeInterval distanceBetweenDates = [closingDate timeIntervalSinceDate:[NSDate date]];
    return distanceBetweenDates;
}

-(NSInteger)remainingOpeningHours {
    if (!_remainingOpeningHours) {
        if (self.remainingOpeningTime > 0 ) {
            _remainingOpeningHours = self.remainingOpeningTime / secondsInAnHour;
        }
        else{
            _remainingOpeningHours = 0;
        }
    }
    return _remainingOpeningHours;
}

-(NSInteger)remainingOpeningMinutes {
    if (!_remainingOpeningMinutes) {
        if (self.remainingOpeningTime > 0) {
            NSUInteger remainingMinutes = self.remainingOpeningTime - (self.remainingOpeningHours * secondsInAnHour);
            _remainingOpeningMinutes = remainingMinutes / secondInAMinute;
        }
        else {
            _remainingOpeningMinutes = 0;
        }
    }
    return _remainingOpeningMinutes;
}
@end

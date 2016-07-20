//
//  NSDate+Utils.m
//  Schwedt
//
//  Created by Andrej Albrecht on 11.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "NSDate+Utils.h"

@implementation NSDate (Utils)

- (NSDate *)dateWithZeroSeconds
{
    NSTimeInterval time = floor([self timeIntervalSinceReferenceDate] / 60.0) * 60.0;
    return  [NSDate dateWithTimeIntervalSinceReferenceDate:time];
}

- (NSInteger)dayOfTheWeek {
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* comp = [cal components:NSCalendarUnitWeekday fromDate:self];
    
    NSInteger weekday = [comp weekday];
    
    if (weekday == 1) return 7; // sunday is 1
    else              return weekday - 1;
}

- (NSComparisonResult)compareDateOnly:(NSDate *)otherDate {
    NSUInteger dateFlags = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *selfComponents = [gregorianCalendar components:dateFlags fromDate:self];
    NSDate *selfDateOnly = [gregorianCalendar dateFromComponents:selfComponents];
    
    NSDateComponents *otherCompents = [gregorianCalendar components:dateFlags fromDate:otherDate];
    NSDate *otherDateOnly = [gregorianCalendar dateFromComponents:otherCompents];
    return [selfDateOnly compare:otherDateOnly];
}

@end

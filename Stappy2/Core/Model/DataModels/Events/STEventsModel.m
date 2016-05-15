//
//  STEventsModel.m
//  Stappy2
//
//  Created by Cynthia Codrea on 30/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STEventsModel.h"

@implementation STEventsModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"address": @"location.address",
             @"itemId": @"id",
             @"dateToShow": @"startdatum",
             @"image" : @"image",
             @"title" : @"title",
             @"subtitle" : @"subtitle",
             @"mainKey" : @"startdatum",
             @"secondaryKey" : @"kategorie.name",
             @"email":@"email",
             @"phone":@"phone",
             @"contactUrl":@"contactUrl",
             @"latitude":@"lati",
             @"longitude":@"long",
             @"body":@"body",
             @"url":@"url",
             @"type":@"type",
             @"startTimestamp": @"startdatum_timestamp",
             @"endTimestamp": @"enddatum_timestamp",
             @"background":@"background",
             @"startDateString":@"startdatum",
             @"startDateHourString":@"startzeit",
             @"endDateString":@"enddatum",
             @"endDateHourString":@"endzeit"
             };
}

- (NSDate *)startDate {
    return [NSDate dateWithTimeIntervalSince1970:self.startTimestamp];
}

- (NSDate *)endDate {
    return [NSDate dateWithTimeIntervalSince1970:self.endTimestamp];
}

@end

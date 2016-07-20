//
//  STStartModel.m
//  Stappy2
//
//  Created by Cynthia Codrea on 17/12/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STStartModel.h"

@implementation STStartModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"itemId": @"id",
             @"angebotItemID": @"id",
             @"dateToShow": @"startdatum",
             @"image" : @"image",
             @"images" : @"images",
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
             @"address":@"location.address",
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

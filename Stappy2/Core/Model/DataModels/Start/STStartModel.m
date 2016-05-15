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
             @"endTimestamp": @"enddatum_timestamp"
             };
}

@end

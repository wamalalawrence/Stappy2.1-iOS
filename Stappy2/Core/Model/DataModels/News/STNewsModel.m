//
//  STNewsModel.m
//  Stappy2
//
//  Created by Cynthia Codrea on 16/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STNewsModel.h"
#import "NSDate+DKHelper.h"

@implementation STNewsModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"newsItemID": @"id",
             @"dateToShow": @"creationdate",
             @"image" : @"image",
             @"title" : @"title",
             @"subtitle" : @"subtitle",
             @"mainKey" : @"creationdate",
             @"secondaryKey" : @"kategorie.name",
             @"type" : @"type",
             @"url" : @"url",
             @"body" : @"body",
             @"endTimestamp" : @"enddatum_timestamp",
             @"startTimestamp" : @"startdatum_timestamp"
             };
}

@end

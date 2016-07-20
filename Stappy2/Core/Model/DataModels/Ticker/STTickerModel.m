//
//  STTickerModel.m
//  Stappy2
//
//  Created by Cynthia Codrea on 10/12/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STTickerModel.h"

@implementation STTickerModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"tickerItemID": @"id",
             @"dateToShow": @"creationdate",
             @"image" : @"image",
             @"title" : @"title",
             @"subtitle" : @"subtitle",
             @"mainKey" : @"creationdate",
             @"secondaryKey" : @"kategorie.name",
             @"type" : @"type",
             @"url" : @"url",
             @"email":@"email",
             @"phone":@"phone",
             @"contactUrl":@"contactUrl",
             @"latitude":@"lati",
             @"longitude":@"long",
             @"body":@"body"
             };
}

@end

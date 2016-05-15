//
//  STVereinsnewsModel.m
//  Stappy2
//
//  Created by Cynthia Codrea on 10/12/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STVereinsnewsModel.h"

@implementation STVereinsnewsModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"vereinsnewsItemID": @"id",
             @"dateToShow": @"creationdate",
             @"image" : @"image",
             @"title" : @"title",
             @"body" : @"subtitle",
             @"mainKey" : @"creationdate",
             @"secondaryKey" : @"verein.name",
             @"url" : @"url",
             @"email":@"email",
             @"phone":@"phone",
             @"contactUrl":@"contactUrl",
             @"latitude":@"lati",
             @"longitude":@"long",
             @"type":@"type"
             };
}

@end

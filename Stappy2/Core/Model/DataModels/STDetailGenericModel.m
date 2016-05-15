//
//  STDetailGenericModel.m
//  Schwedt
//
//  Created by Cynthia Codrea on 03/02/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STDetailGenericModel.h"

@implementation STDetailGenericModel

+(NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{
             @"image" : @"background",
             @"title" : @"title",
             @"subtitle" : @"subtitle",
             @"url" : @"url",
             @"email":@"email",
             @"phone":@"phone",
             @"contactUrl":@"contactUrl",
             @"latitude":@"lati",
             @"longitude":@"long",
             @"body":@"body",
             @"type":@"type",
             @"background":@"background"
             };
}

@end

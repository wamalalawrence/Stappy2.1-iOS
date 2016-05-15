//
//  STReportType.m
//  Stappy2
//
//  Created by Pavel Nemecek on 10/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STReportType.h"

@implementation STReportType
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"reportTypeId": @"id",
             @"name":@"name"
             };
}

@end

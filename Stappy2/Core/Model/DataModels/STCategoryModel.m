//
//  STCategoryModel.m
//  Stappy2
//
//  Created by Cynthia Codrea on 1/24/16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STCategoryModel.h"

@implementation STCategoryModel


+(NSDictionary*)JSONKeyPathsByPropertyKey {
    
    return @{
             @"title":@"title",
             @"url":@"url",
             @"type":@"type"
             };
}

@end

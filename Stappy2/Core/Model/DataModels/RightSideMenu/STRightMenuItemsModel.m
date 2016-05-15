//
//  STRightMenuItemsModel.m
//  Stappy2
//
//  Created by Cynthia Codrea on 27/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STRightMenuItemsModel.h"

@implementation STRightMenuItemsModel

+(NSDictionary*)JSONKeyPathsByPropertyKey {
    
    return @{
             @"modelId":@"id",
             @"title":@"title",
             @"detailsUrl":@"url",
             @"optionType":@"type",
             @"children":@"children",
             @"icon_name":@"icon_name",
             };
}

@end

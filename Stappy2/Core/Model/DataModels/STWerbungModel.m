//
//  STWerbungModel.m
//  Stappy2
//
//  Created by Cynthia Codrea on 13/04/2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STWerbungModel.h"

@implementation STWerbungModel

+(NSDictionary*)JSONKeyPathsByPropertyKey {
    
    return @{@"url":@"url",
             @"type":@"type",
             @"image":@"image"
             };
}

@end

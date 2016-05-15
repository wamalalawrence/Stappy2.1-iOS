//
//  STLeftObjRequestedModel.m
//  Schwedt
//
//  Created by Cynthia Codrea on 04/02/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STLeftObjRequestedModel.h"

@implementation STLeftObjRequestedModel

+(NSDictionary*)JSONKeyPathsByPropertyKey {
    
    return @{
             @"itemName":@"id",
             @"children":@"children"
             };
}

@end

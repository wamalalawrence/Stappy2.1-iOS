//
//  STAngeboteModel.m
//  Stappy2
//
//  Created by Cynthia Codrea on 09/12/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STAngeboteModel.h"
#import "Defines.h"
#import "NSDictionary+Default.h"
#import "STStadtinfoOverwiewImages.h"

@implementation STAngeboteModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"address": @"location.address",
             @"angebotItemID": @"id",
             @"dateToShow": @"enddatum",
             @"image" : @"image",
             @"title" : @"title",
             @"subtitle" : @"subtitle",
             @"mainKey" : @"kategorie.name",
             @"secondaryKey" : @"owner_bezeichnung",
             @"url" : @"url",
             @"email":@"email",
             @"phone":@"phone",
             @"contactUrl":@"contactUrl",
             @"latitude":@"lati",
             @"longitude":@"long",
             @"body":@"body",
             @"type":@"type",
             @"images":@"images",
             @"background":@"background",
             @"body2":@"body2"
             };
}

+(NSValueTransformer *)imagesJSONTransformer __unused {
    
    return [MTLValueTransformer transformerWithBlock:^id(id images) {
        if ( [images isKindOfClass:[NSArray class]] ) {
            return [[MTLValueTransformer mtl_JSONArrayTransformerWithModelClass:[STStadtinfoOverwiewImages class]] transformedValue:images];
        }
        else if ( [images isKindOfClass:[NSDictionary class]] ) {
            NSMutableArray *images = [[NSMutableArray alloc] init];
            [images addObject:[[MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[STStadtinfoOverwiewImages class]] transformedValue:images]];
            return images;
        }
        return nil;
    }];
    
}
@end

//
//  STNewsModel.m
//  Stappy2
//
//  Created by Cynthia Codrea on 16/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STNewsModel.h"
#import "NSDate+DKHelper.h"
#import "STStadtinfoOverwiewImages.h"
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
             @"startTimestamp" : @"startdatum_timestamp",
             @"background" : @"background",
             @"images" : @"images"

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

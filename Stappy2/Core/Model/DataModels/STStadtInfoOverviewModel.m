//
//  STStadtInfoOverviewModel.m
//  Stappy2
//
//  Created by Cynthia Codrea on 25/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STStadtInfoOverviewModel.h"
#import "STStadtinfoOverwiewImages.h"
#import "OpeningClosingTimesModel.h"

@implementation STStadtInfoOverviewModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"title": @"title",
             @"itemId": @"id",
             @"image": @"image",
             @"images": @"images",
             @"background" : @"background",
             @"url": @"url",
             @"address": @"address",
             @"openinghours": @"openinghours",
             @"itemDescription": @"description",
             @"body": @"body",
             @"contactUrl": @"contactUrl",
             @"phone": @"phone",
             @"email": @"email",
             @"openinghours2": @"openinghours2",
             @"longitude": @"long",
             @"latitude": @"lati",
             @"endDate": @"enddate",
             @"isOpen" : @"isOpen"
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

+ (NSValueTransformer *)openinghours2JSONTransformer __unused
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *value, BOOL *success, NSError **e) {
        if (![value isKindOfClass:NSDictionary.class]) return nil;
        
        NSMutableArray<OpeningClosingTimesModel *> *openingClosingTimesArray = [NSMutableArray arrayWithCapacity:value.allKeys.count];
        [value enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *openingClosingTimeArray, BOOL *stop) {
            OpeningClosingTimesModel *openingClosingTimesModel = [[OpeningClosingTimesModel alloc] init];
            
            NSMutableArray<OpeningClosingTimeModel *> *openingClosingTimes = [NSMutableArray  array];
            for (NSDictionary *dict in openingClosingTimeArray)
            {
                OpeningClosingTimeModel *openingClosingTimeModel = [MTLJSONAdapter modelOfClass:OpeningClosingTimeModel.class
                                                                             fromJSONDictionary:dict
                                                                                          error:nil];
                
             
                
                [openingClosingTimes addObject:openingClosingTimeModel];
            }
            
            openingClosingTimesModel.key = [key copy];
            openingClosingTimesModel.openingHours = openingClosingTimes;
            
            BOOL isEmpty = [OpeningClosingTimesModel isEmpty:@[openingClosingTimesModel]];
            
            if(!isEmpty)
            {
                [openingClosingTimesArray addObject:openingClosingTimesModel];

            }
            
        }];
        return [NSArray arrayWithArray:openingClosingTimesArray];
    }];
}

- (void)setNilValueForKey:(NSString *)key {
    if ([key isEqualToString:@"isOpen"]) {
        self.isOpen = NO;
    }
    else {
        [super setNilValueForKey:key];
    }
}

@end

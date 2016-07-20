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
             @"images" : @"images",
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
             @"background":@"background",
             @"openinghours2": @"openinghours2"
             };
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

@end

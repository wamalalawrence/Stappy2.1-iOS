//
//  STItemDetailsModel.m
//  Stappy2
//
//  Created by Cynthia Codrea on 07/12/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STItemDetailsModel.h"

@implementation STItemDetailsModel

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

- (NSString *)type
{
    if (!_type) return @"Event";
    return _type;
}

+ (NSValueTransformer *)openinghours2JSONTransformer __unused
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *value, BOOL *success, NSError **e) {
        if (![value isKindOfClass:NSDictionary.class]) return nil;
        
        NSMutableArray<OpeningClosingTimesModel *> *openingClosingTimesArray = [NSMutableArray arrayWithCapacity:value.allKeys.count];
        [value enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *openingClosingTimeArray, BOOL *stop) {
            OpeningClosingTimesModel *openingClosingTimesModel = [[OpeningClosingTimesModel alloc] init];
            
            NSMutableArray<OpeningClosingTimeModel *> *openingClosingTimes = [[NSMutableArray alloc] initWithCapacity:value.count];
            for (NSDictionary *dict in openingClosingTimeArray)
            {
                OpeningClosingTimeModel *openingClosingTimeModel = [MTLJSONAdapter modelOfClass:OpeningClosingTimeModel.class
                                                                             fromJSONDictionary:dict
                                                                                          error:nil];
                [openingClosingTimes addObject:openingClosingTimeModel];
            }
            
            openingClosingTimesModel.key = [key copy];
            openingClosingTimesModel.openingHours = openingClosingTimes;
            [openingClosingTimesArray addObject:openingClosingTimesModel];
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

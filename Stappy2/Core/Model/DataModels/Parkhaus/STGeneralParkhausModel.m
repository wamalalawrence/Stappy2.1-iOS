//
//  NSTankModel.m
//  Stappy2
//
//  Created by Pavel Nemecek on 04/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STGeneralParkhausModel.h"
#import "NSDictionary+Default.h"
@implementation STGeneralParkhausModel

+(instancetype)parkhausFromXMLDictionary:(NSDictionary*)dictionary{

    STGeneralParkhausModel*parkHaus = [[STGeneralParkhausModel alloc]init];
    parkHaus.title = [dictionary valueForKey:@"Name" withDefault:@""];
    parkHaus.latitude = [[dictionary valueForKey:@"Latitude"] doubleValue];
    parkHaus.longitude = [[dictionary valueForKey:@"Longitude"] doubleValue];
    
   
    if ([[dictionary valueForKey:@"Status"] isEqualToString:@"Offen"]) {
        parkHaus.isOpen = YES;
    }
    
    parkHaus.capacity =[[dictionary valueForKey:@"Gesamt"]
                        integerValue];

    parkHaus.freePlaces =[[dictionary valueForKey:@"Gesamt"]
                          integerValue]-[[dictionary valueForKey:@"Belegt"]
                                         integerValue];


    
    double percetage = ((double)parkHaus.freePlaces/(double)parkHaus.capacity)*100;
    
    if (percetage<6) {
        parkHaus.availability = 0;
    }
    else if (percetage>5&&percetage<70) {
        parkHaus.availability = 1;
    }
    else {
        parkHaus.availability = 2;
    }

    
    return parkHaus;
}

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
             @"isOpen" : @"isOpen"
             };
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
            
            
            BOOL isEmpty = [OpeningClosingTimesModel isEmpty:@[openingClosingTimesModel]];
            
            if(!isEmpty)
            {
                [openingClosingTimesArray addObject:openingClosingTimesModel];
                
            }

            
        }];
        return [NSArray arrayWithArray:openingClosingTimesArray];
    }];
}

-(CLLocationCoordinate2D)location{

    if (_location.latitude==0.0 && _location.longitude == 0.0) {
   
          _location =  CLLocationCoordinate2DMake(_latitude, _longitude);
    }
 return _location;
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

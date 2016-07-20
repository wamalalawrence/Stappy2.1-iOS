//
//  STMainModel.m
//  Stappy2
//
//  Created by Cynthia Codrea on 27/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STMainModel.h"
#import "STStadtinfoOverwiewImages.h"
@implementation STMainModel

+(NSDictionary*)JSONKeyPathsByPropertyKey {
    NSDictionary * keysAndPaths = @{
                                    @"background":@"background",
                                    @"latitude":@"latitude",
                                    @"longitude":@"longitude",
                                    @"type":@"type",
                                    @"city":@"city",
                                    @"itemId":@"id",
                                    @"startDateString":@"start date",
                                    @"startDateHourString":@"start",
                                    @"endDateString":@"end_date",
                                    @"endDateHourString":@"end-time",
                                    @"images":@"images"

                                    };
    return keysAndPaths;
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


-(void)setNilValueForKey:(NSString *)key
{
    [self setValue:@0 forKey:key];
}

- (NSString *)phone {
    if (_phone.length == 0) return nil;
    return _phone;
}

- (NSString *)url {
    if (_url.length == 0) return nil;
    return [_url stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
}

- (NSString *)email {
    if (_email.length == 0) return nil;
    return _email;
}

- (NSString *)contactUrl {
    if (_contactUrl.length == 0) return nil;
    return _contactUrl;
}

- (NSString *)type {
    if (!_type) return @"Event";
    return _type;
}

@end

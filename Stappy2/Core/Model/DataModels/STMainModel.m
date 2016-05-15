//
//  STMainModel.m
//  Stappy2
//
//  Created by Cynthia Codrea on 27/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STMainModel.h"

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
                                    @"background":@"background"
                                    };
    return keysAndPaths;
}

-(void)setNilValueForKey:(NSString *)key
{
    [self setValue:@0 forKey:key];
}

- (NSString *)phone {
    if (_phone.length == 0) return nil;
    return _phone;
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

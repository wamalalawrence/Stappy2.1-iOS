//
//  STEmergenciesModel.m
//  Stappy2
//
//  Created by Denis Grebennicov on 20/01/16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STEmergenciesModel.h"

@interface STEmergencyDates ()
@property (nonatomic, strong) NSString *x_startDateTime;
@property (nonatomic, strong) NSString *x_endDateTime;
@end

@implementation STEmergencyDates

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"startDate": @"startdatum",
             @"endDate": @"enddatum",
             @"startTime": @"startzeit",
             @"endTime": @"endzeit",
             @"x_startDateTime": @"start",
             @"x_endDateTime": @"ende"
            };
}

- (NSDate *)startDateTime
{
    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
    [outputDateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    return [outputDateFormatter dateFromString:self.x_startDateTime];
}

- (NSDate *)endDateTime
{
    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
    [outputDateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    return [outputDateFormatter dateFromString:self.x_endDateTime];
}

@end

@interface STEmergenciesModel ()
@property (nonatomic, strong) NSString *x_id;
@property (nonatomic, strong) NSString *x_latitude;
@property (nonatomic, strong) NSString *x_longitude;

@property (nonatomic, strong) STItemDetailsModel *forwardObject;
@end

@implementation STEmergenciesModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"x_id": @"id",
             @"name": @"name",
             @"x_latitude": @"latitude",
             @"x_longitude": @"longitude",
             @"street": @"street",
             @"zip": @"zip",
             @"city": @"city",
             @"phone": @"phone",
             @"emergencyDates": @"notdienst"
            };
}

+ (NSValueTransformer *)emergencyDatesJSONTransformer __unused
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSArray *value, BOOL *success, NSError **e) {
        if ([value isEqualToArray:@[]]) return nil;
        
        NSError *error;
        STEmergencyDates *emergencyDate = [MTLJSONAdapter modelOfClass:STEmergencyDates.class
                                                    fromJSONDictionary:value[0]
                                                                 error:&error];
        
        return emergencyDate;
    }];
}

#pragma mark - helper methods

- (NSString *)type { return @"Notdienst"; }

- (NSString *)title { return self.name; }

- (NSString *)address
{
    return [NSString stringWithFormat:@"%@, %@ %@", self.street, self.zip, self.city];
}

- (NSNumber *)itemId
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    return [f numberFromString:self.x_id];
}

- (NSNumber *)latitude
{
    return @([self.x_latitude doubleValue]);
}

- (NSNumber *)longitude
{
    return @([self.x_longitude doubleValue]);
}

- (NSString *)body
{
    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
    [outputDateFormatter setDateFormat:@"d. MMM, HH:mm"];
    
    return [NSString stringWithFormat:@"Notdienst von %@ Uhr bis %@ Uhr", [outputDateFormatter stringFromDate:self.emergencyDates.startDateTime], [outputDateFormatter stringFromDate:self.emergencyDates.endDateTime]];

}

#pragma mark - Forwarding objc_sendMessage

- (STItemDetailsModel *)forwardObject
{
    if (!_forwardObject) _forwardObject = [[STItemDetailsModel alloc] init];
    return _forwardObject;
}

-(void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation invokeWithTarget:self.forwardObject];
}

-(NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    
    if (!signature) signature = [self.forwardObject methodSignatureForSelector:selector];
    
    return signature;
}

@end

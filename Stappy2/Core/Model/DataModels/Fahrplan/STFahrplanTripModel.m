//
//  STFahrplanTripModel.m
//  Stappy2
//
//  Created by Cynthia Codrea on 20/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STFahrplanTripModel.h"
#import "STFahrplanSubTripModel.h"
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>

@implementation STFahrplanTripModel

+(NSDictionary*)JSONKeyPathsByPropertyKey {
    //@"duration":@"duration",
    return @{
             @"duration":@"duration",
             @"tripStations":@"LegList.Leg"
             };
}

+ (NSValueTransformer *)tripStationsJSONTransformer __unused {
    return [MTLValueTransformer transformerWithBlock:^id(id tripStations) {
        if ( [tripStations isKindOfClass:[NSArray class]] ) {
            return [[MTLValueTransformer mtl_JSONArrayTransformerWithModelClass:[STFahrplanSubTripModel class]] transformedValue:tripStations];
        }
        else if ( [tripStations isKindOfClass:[NSDictionary class]] ) {
            NSMutableArray *tripStations = [[NSMutableArray alloc] init];
            [tripStations addObject:[[MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[STFahrplanSubTripModel class]] transformedValue:tripStations]];
            return tripStations;
        }
        return nil;
    }];
}

+ (NSValueTransformer *)durationJSONTransformer __unused
{
        id object = [MTLValueTransformer transformerWithBlock:^id(NSString *duration) {
            //Example duration: PT7H20M
            NSString *durationResult = @"";
            
            @try {
            if (!duration || [duration isEqualToString:@""]) {
                return @"";
            }
            
            NSError *error = NULL;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^P(\\d*)T(\\d*)H(\\d*)M$" options:NSRegularExpressionCaseInsensitive error:&error];
            
            NSArray *result = [regex matchesInString:duration options:0 range:NSMakeRange(0, [duration length])];
                if (result && [result count] > 0) {
                    id firstResult = [result objectAtIndex:0];
                    
                    NSString *durationDays = [duration substringWithRange:[firstResult rangeAtIndex:1]];
                    if (durationDays && ![durationDays isEqualToString:@""]) {
                        durationResult = [NSString stringWithFormat:@"%@d ",durationDays];
                    }
                    
                    NSString *durationHours = [duration substringWithRange:[firstResult rangeAtIndex:2]];
                    if (durationHours && ![durationHours isEqualToString:@""]) {
                        durationResult = [NSString stringWithFormat:@"%@%@h ",durationResult, durationHours];
                    }
                    
                    NSString *durationMinutes = [duration substringWithRange:[firstResult rangeAtIndex:3]];
                    if (durationMinutes && ![durationMinutes isEqualToString:@""]) {
                        durationResult = [NSString stringWithFormat:@"%@%@m ",durationResult, durationMinutes];
                    }
                }
                
                if (!durationResult) {
                    regex = [NSRegularExpression regularExpressionWithPattern:@"^P(\\d*)T(\\d*)M$" options:NSRegularExpressionCaseInsensitive error:&error];
                    
                    result = [regex matchesInString:duration options:0 range:NSMakeRange(0, [duration length])];
                    id firstResult = [result objectAtIndex:0];
                    NSString *durationMinutes = [duration substringWithRange:[firstResult rangeAtIndex:2]];
                    if (durationMinutes && ![durationMinutes isEqualToString:@""]) {
                        durationResult = [NSString stringWithFormat:@"%@m ", durationMinutes];
                    }
                }
            } @catch (NSException *exception) {
                NSLog(@"exception:%@", [exception description]);
                return nil;
            }
            
            return durationResult;
        }];
        
        return object;
}

-(NSUInteger)changeNumber
{
    NSLog(@"changeNumber");
    int changes = 0;
    NSString *lastTransportName = @"";
    for (int i = 0; i < [self.tripStations count];i++) {
        STFahrplanSubTripModel *station = [self.tripStations objectAtIndex:i];
        
        NSLog(@"lastTransportName:%@ station.transportationType:%@ i:%lu changes:%lu", lastTransportName, station.transportationType, (unsigned long)i, (unsigned long)changes);
        
        if (i>1 && station.transportationType != nil &&
            ![station.transportationType isEqualToString:@"(null)"] &&
            ![station.transportationName isEqualToString:lastTransportName]) {
            changes++;
        }
        lastTransportName = station.transportationName;
    }
    return changes;
}

-(NSDate *)departureDatetime
{
    STFahrplanSubTripModel* subtripFirst = self.tripStations[0];
    
    return subtripFirst.startDate;
}

-(NSDate *)arrivalDatetime
{
    if ([self.tripStations count] == 0) {
        return nil;
    }
    
    STFahrplanSubTripModel* subtripLast = self.tripStations[[self.tripStations count]-1];
    
    return subtripLast.endDate;
}

@end

//
//  OpeningClosingTimesModel.m
//  Stappy2
//
//  Created by Denis Grebennicov on 20/01/16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "OpeningClosingTimesModel.h"

@implementation OpeningClosingTimesModel

- (NSArray<OpeningClosingTimeModel *> *)openingHoursForDay:(NSInteger)day
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (OpeningClosingTimeModel *timeModel in _openingHours)
    {
        if (timeModel.dayOfWeek.intValue == day) [result addObject:timeModel];
    }
    
    return result;
}

+ (BOOL)isEmpty:(NSArray<OpeningClosingTimesModel *> *)data
{
    for (OpeningClosingTimesModel *d in data)
    {
        for (OpeningClosingTimeModel *tm in d.openingHours)
        {
            if (![tm.openingTime isEqual:[NSNull null]] || ![tm.closingTime isEqual:[NSNull null]]){
              
                 if (tm.openingTime != nil || tm.closingTime !=nil){
                return NO;
                 }

            }
                
        }
    }
    
    return YES;
}

@end

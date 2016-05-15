//
//  OpeningClosingTimesModel.h
//  Stappy2
//
//  Created by Denis Grebennicov on 20/01/16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "STMainModel.h"
#import "OpeningClosingTimeModel.h"

@interface OpeningClosingTimesModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *key;
@property (nonatomic, strong) NSMutableArray<OpeningClosingTimeModel *> *openingHours;

+ (BOOL)isEmpty:(NSArray<OpeningClosingTimesModel *> *)data;

- (NSArray<OpeningClosingTimeModel *> *)openingHoursForDay:(NSInteger)day;

@end

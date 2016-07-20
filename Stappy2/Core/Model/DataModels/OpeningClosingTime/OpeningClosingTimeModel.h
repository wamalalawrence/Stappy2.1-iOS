//
//  OpeningClosingTimeModel.h
//  Stappy2
//
//  Created by Denis Grebennicov on 20/01/16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface OpeningClosingTimeModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *closingTime;
@property (nonatomic, copy) NSString *openingTime;
@property (nonatomic, strong) NSNumber *dayOfWeek;

@property (nonatomic, assign)NSInteger remainingOpeningTime;

@property (nonatomic, assign)NSInteger remainingOpeningHours;
@property (nonatomic, assign)NSInteger remainingOpeningMinutes;


@end

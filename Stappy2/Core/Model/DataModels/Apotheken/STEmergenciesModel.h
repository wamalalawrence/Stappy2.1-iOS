//
//  STEmergenciesModel.h
//  Stappy2
//
//  Created by Denis Grebennicov on 20/01/16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "STItemDetailsModel.h"

@interface STEmergencyDates : MTLModel <MTLJSONSerializing>
@property (nonatomic, copy) NSString *startDate;
@property (nonatomic, copy) NSString *endDate;
@property (nonatomic, copy) NSString *startTime;
@property (nonatomic, copy) NSString *endTime;
@property (nonatomic, strong) NSDate *startDateTime;
@property (nonatomic, strong) NSDate *endDateTime;
@end

@interface STEmergenciesModel : MTLModel <MTLJSONSerializing>
@property (nonatomic, strong) NSNumber *itemId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *street;
@property (nonatomic, copy) NSString *zip;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *type;

@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) STEmergencyDates *emergencyDates;

@property (nonatomic, strong, readonly) NSString *address;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *body;

@property (nonatomic, strong) STItemDetailsModel *detailDataModel;

@end

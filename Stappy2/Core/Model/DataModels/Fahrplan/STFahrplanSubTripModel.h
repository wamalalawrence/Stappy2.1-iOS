//
//  STFahrplanSubTripModel.h
//  Stappy2
//
//  Created by Cynthia Codrea on 22/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface STFahrplanSubTripModel : MTLModel <MTLJSONSerializing>

@property(nonatomic,copy) NSString *transportationType;
@property(nonatomic,copy) NSString *transportationName;
@property(nonatomic,copy) NSString *direction;

@property(nonatomic,copy) NSString *startPointName;
@property(nonatomic,copy) NSString *startPointTime;
@property(nonatomic,copy) NSString *startPointDate;
@property(nonatomic,copy) NSString *startPointTimeFormatted;
@property(nonatomic,copy) NSString *startPointDateFormatted;
@property(nonatomic,copy) NSNumber *startPointLatitude;
@property(nonatomic,copy) NSNumber *startPointLongitude;
@property(nonatomic,copy) NSString *startTrack;

@property(nonatomic,copy) NSString *endPointName;
@property(nonatomic,copy) NSString *endPointTime;
@property(nonatomic,copy) NSString *endPointDate;
@property(nonatomic,copy) NSString *endPointTimeFormatted;
@property(nonatomic,copy) NSString *endPointDateFormatted;
@property(nonatomic,copy) NSNumber *endPointLatitude;
@property(nonatomic,copy) NSNumber *endPointLongitude;
@property(nonatomic,copy) NSString *endTrack;


@property(nonatomic,strong) NSDate *startDate;
@property(nonatomic,strong) NSDate *endDate;


@end

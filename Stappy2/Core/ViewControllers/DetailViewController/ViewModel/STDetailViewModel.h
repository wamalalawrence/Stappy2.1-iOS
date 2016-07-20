//
//  STDetailViewModel.h
//  Stappy2
//
//  Created by Pavel Nemecek on 22/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OpeningClosingTimesModel;

@interface STDetailViewModel : NSObject

@property (nonatomic,copy) NSString*headline;
@property (nonatomic,copy) NSString*background;
@property (nonatomic,copy) NSURL*coverImageUrl;
@property (nonatomic,copy) NSString*address;
@property (nonatomic,copy) NSString*date;
@property(nonatomic, copy)NSString* startDateString;
@property(nonatomic, copy)NSString* startDateHourString;
@property(nonatomic, copy)NSString* endDateString;
@property(nonatomic, copy)NSString* endDateHourString;
@property (nonatomic,copy) NSString*category;
@property (nonatomic,copy) NSString*content;
@property (nonatomic,copy) NSString*phone;
@property (nonatomic,copy) NSString*contactUrl;
@property (nonatomic,copy) NSString*email;
@property (nonatomic,copy) NSString*couponDescription;
@property (nonatomic,strong) NSArray*images;
@property (nonatomic, strong) NSArray<OpeningClosingTimesModel *> *openingHours;
@property (nonatomic,copy) NSString*openingTimes;
@property (nonatomic,assign) double latitude;
@property (nonatomic,assign) double longitude;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, assign, getter=isFavorite) BOOL favorite;
@property (nonatomic,assign, getter=isFavoritable) BOOL favoritable;
@property (nonatomic,assign, getter=isOffer) BOOL offer;

@property (nonatomic,strong) id model;

-(instancetype)initWithModel:(id)model;
@end

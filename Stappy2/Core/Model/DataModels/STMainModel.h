//
//  STMainModel.h
//  Stappy2
//
//  Created by Cynthia Codrea on 27/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import <Mantle/Mantle.h>

@protocol Favoritable <NSObject>
@property (nonatomic, assign, getter=isFavorite) BOOL favorite;
@end

@interface STMainModel : MTLModel <MTLJSONSerializing>

@property(nonatomic,copy)NSString* mainKey;
@property(nonatomic,copy)NSString* secondaryKey;
@property(nonatomic,assign)BOOL isExpanded;
@property(nonatomic,assign)BOOL requiresCustomerNumber;

//common properties
@property(nonatomic,copy)NSString* type;
@property(nonatomic,copy)NSString* title;
@property(nonatomic,copy)NSString* subtitle;
@property(nonatomic,copy)NSString* image;
@property(nonatomic,copy)NSString* background;
@property(nonatomic,copy)NSString* dateToShow;
@property(nonatomic,copy)NSString* address;
@property(nonatomic,copy)NSString* body;
@property(nonatomic,copy)NSString* email;
@property(nonatomic,copy)NSString* phone;
@property(nonatomic,copy)NSString* contactUrl;
@property(nonatomic,copy)NSString* url;
@property(nonatomic,copy)NSString* city;

@property (nonatomic, strong) NSNumber *itemId;

@property (nonatomic, assign) double startTimestamp;
@property (nonatomic, assign) double endTimestamp;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

@property(nonatomic) NSNumber *latitude;
@property(nonatomic) NSNumber *longitude;

@property(nonatomic,strong)NSArray *images;

@property(nonatomic, assign)BOOL menuOrientationLeft;
@property(nonatomic, copy)NSString* startDateString;
@property(nonatomic, copy)NSString* startDateHourString;
@property(nonatomic, copy)NSString* endDateString;
@property(nonatomic, copy)NSString* endDateHourString;

@end

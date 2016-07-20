//
//  STReport.h
//  Stappy2
//
//  Created by Pavel Nemecek on 10/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "STReportType.h"
#import "STReportCategory.h"
@interface STReport : NSObject

@property(nonatomic,strong) NSString*fullAddress;
@property(nonatomic,strong) NSString*street;
@property(nonatomic,strong) NSString*town;
@property(nonatomic,strong) NSString*fullName;
@property(nonatomic,strong) NSString*firstName;
@property(nonatomic,strong) NSString*lastName;
@property(nonatomic,strong) NSString*email;
@property(nonatomic,strong) NSString*phone;
@property(nonatomic,strong) NSString*categoryName;
@property(nonatomic,strong) NSString*typeName;
@property(nonatomic,strong) NSMutableArray*photos;
@property(nonatomic,strong) NSString*note;
@property(nonatomic,strong) STReportType*type;
@property(nonatomic,strong) STReportCategory*category;
@property(nonatomic,assign) double latitude;
@property(nonatomic,assign) double longitude;
@property (nonatomic,assign) CLLocationCoordinate2D location;

@end

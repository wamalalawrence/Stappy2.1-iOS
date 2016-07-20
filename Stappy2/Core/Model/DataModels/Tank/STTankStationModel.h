//
//  NSTankModel.h
//  Stappy2
//
//  Created by Pavel Nemecek on 04/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpeningClosingTimesModel.h"
#import <MapKit/MapKit.h>

typedef enum {
    STTankStationModelTypeElektro,
    STTankStationModelTypeGas
} STTankStationModelType;

@interface STTankStationModel :MTLModel <MTLJSONSerializing>
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *background;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *itemDescription;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *contactUrl;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *openinghours;
@property(nonatomic, assign) STTankStationModelType stationType;
@property (nonatomic, strong) NSNumber *itemId;
@property (nonatomic, strong) NSArray<NSString *> *images;
@property (nonatomic, strong) NSArray<OpeningClosingTimesModel *> *openinghours2;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property(nonatomic, assign)BOOL isOpen;
@property (nonatomic,assign) CLLocationCoordinate2D location;
@end

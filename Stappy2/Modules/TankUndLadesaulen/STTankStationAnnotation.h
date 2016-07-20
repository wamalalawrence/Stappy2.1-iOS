//
//  STTankStationAnnotation.h
//  Stappy2
//
//  Created by Pavel Nemecek on 06/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "STTankStationModel.h"
#import "STTankStationAnnotationView.h"

@interface STTankStationAnnotation : NSObject<MKAnnotation>
@property (nonatomic,readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy) NSString*title;
@property (nonatomic,strong) STTankStationModel *tankStationModel;

-(instancetype)initWithTankStationModel:(STTankStationModel*)model;
-(STTankStationAnnotationView*)annotationViewWithIndetifier:(NSString*)identifier;
@end

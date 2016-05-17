//
//  STTankStationAnnotation.h
//  Stappy2
//
//  Created by Pavel Nemecek on 06/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "STGeneralParkhausModel.h"
#import "STParkhausAnnotationView.h"

@interface STParkhausAnnotation : NSObject<MKAnnotation>
@property (nonatomic,readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy) NSString*title;
@property (nonatomic,copy) NSString*subtitle;
@property (nonatomic,strong) STGeneralParkhausModel *parkHausModel;

-(instancetype)initWithParkHausModel:(STGeneralParkhausModel*)model;
-(STParkhausAnnotationView*)annotationViewWithIndetifier:(NSString*)identifier;
@end

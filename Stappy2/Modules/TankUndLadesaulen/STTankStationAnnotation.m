//
//  STTankStationAnnotation.m
//  Stappy2
//
//  Created by Pavel Nemecek on 06/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STTankStationAnnotation.h"

#define kSTTankStationAnnotationGasPinImage @"icon_content_pin_erdgas"
#define kSTTankStationAnnotationElektroPinImage @"icon_content_pin_ladesaule"

@implementation STTankStationAnnotation

-(instancetype)initWithTankStationModel:(STTankStationModel*)model{
    self = [super init];
    if (self) {
        _title = model.title;
        _coordinate = model.location;
        _tankStationModel = model;
    }
    return self;
}

-(STTankStationAnnotationView*)annotationViewWithIndetifier:(NSString*)identifier{
    STTankStationAnnotationView*annnotationView = [[STTankStationAnnotationView alloc] initWithAnnotation:self reuseIdentifier:identifier];
    annnotationView.canShowCallout = YES;
    annnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annnotationView.annotation = self;
    return annnotationView;
}

@end

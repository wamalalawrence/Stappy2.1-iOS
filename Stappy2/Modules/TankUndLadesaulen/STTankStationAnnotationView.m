//
//  STTankStationAnnotationView.m
//  Stappy2
//
//  Created by Pavel Nemecek on 06/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STTankStationAnnotationView.h"
#import "STTankStationAnnotation.h"

#define kSTTankStationAnnotationGasPinImage @"icon_content_pin_erdgas"
#define kSTTankStationAnnotationElektroPinImage @"icon_content_pin_ladesaule"

@implementation STTankStationAnnotationView

-(void)setAnnotation:(id<MKAnnotation>)annotation{
    [super setAnnotation:annotation];
    
    STTankStationAnnotation*annot = (STTankStationAnnotation*)annotation;

    UIImage* pinImage;
    if (annot.tankStationModel.stationType == STTankStationModelTypeElektro) {
        pinImage =[UIImage imageNamed:kSTTankStationAnnotationElektroPinImage];
    }
    else{
        pinImage =[UIImage imageNamed:kSTTankStationAnnotationGasPinImage];
    }
    self.image = pinImage;
}

@end

//
//  STTankStationAnnotation.m
//  Stappy2
//
//  Created by Pavel Nemecek on 06/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STParkhausAnnotation.h"
#import "UIColor+STColor.h"
#import "UIImage+tintImage.h"

@implementation STParkhausAnnotation

-(instancetype)initWithParkHausModel:(STGeneralParkhausModel*)model{
    self = [super init];
    if (self) {
        _title = model.title;
        _coordinate = model.location;
        _parkHausModel = model;
    }
    return self;
}

-(STParkhausAnnotationView*)annotationViewWithIndetifier:(NSString*)identifier{
    STParkhausAnnotationView*annnotationView = [[STParkhausAnnotationView alloc] initWithAnnotation:self reuseIdentifier:identifier];
    annnotationView.canShowCallout = YES;
    annnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annnotationView.annotation = self;
        return annnotationView;
}

@end

//
//  STTankStationAnnotationView.m
//  Stappy2
//
//  Created by Pavel Nemecek on 06/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STParkhausAnnotationView.h"
#import "STParkhausAnnotation.h"
#import "UIImage+tintImage.h"
#import "UIColor+STColor.h"
#define kSTParkHuasAnnotationPin @"pin"

@implementation STParkhausAnnotationView

-(void)setAnnotation:(id<MKAnnotation>)annotation{
    [super setAnnotation:annotation];
    
    STParkhausAnnotation*annot = (STParkhausAnnotation*)annotation;

    UIImage* pinImage  =[UIImage imageNamed:kSTParkHuasAnnotationPin];
    

   
    if (annot.parkHausModel.availability == 0) {
      self.image =  [pinImage imageTintedWithColor:[UIColor colorWithRed:202/255.0 green:33/255.0 blue:33/255.0 alpha:1.0]];
    }
   else if (annot.parkHausModel.availability == 1) {
       self.image =  [pinImage imageTintedWithColor:[UIColor colorWithRed:250/255.0 green:183/255.0 blue:32/255.0 alpha:1.0]];

    }
    else{
        self.image =  [pinImage imageTintedWithColor:[UIColor colorWithRed:81/255.0 green:154/255.0 blue:22/255.0 alpha:1.0]];

    }
}

@end

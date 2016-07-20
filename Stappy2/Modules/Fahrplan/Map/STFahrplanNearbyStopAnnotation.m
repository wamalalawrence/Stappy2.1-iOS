//
//  NearbyStopAnnotation.m
//  Stappy2
//
//  Created by Andrej Albrecht on 21.01.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STFahrplanNearbyStopAnnotation.h"
#import "UIColor+STColor.h"
#import "STFahrplanNearbyStopLocation.h"
#import "UIImage+tintImage.h"

@implementation STFahrplanNearbyStopAnnotation

-(id)initWithLocation:(STFahrplanNearbyStopLocation*)location
{
    self = [super init];
    if (self) {
        _location = location;
        _title = location.locationName;
        _coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);;
    }
    return self;
}

-(id)initWithTitle:(NSString*)newTitle location:(CLLocationCoordinate2D)location
{
    self = [super init];
    if (self) {
        _title = newTitle;
        _coordinate = location;
    }
    return self;
}

- (MKAnnotationView *)annotationView
{
    CGFloat scale = [[UIScreen mainScreen] scale] * 2;//*2
    
    UIImage *annotationImage = [UIImage imageNamed:@"icon_content_oepnv_pin_card"];
    annotationImage = [annotationImage imageTintedWithColor:[UIColor partnerColor]];
    UIImage *annotationImageScaled = [UIImage imageWithCGImage:annotationImage.CGImage
                               scale:scale
                                             orientation:annotationImage.imageOrientation];
    
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"STFahrplanNearbyStopAnnotation"];
    annotationView.enabled = YES;
    annotationView.alpha = 0.7;
    annotationView.canShowCallout = YES;
    annotationView.image = annotationImageScaled;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    //[annotationView setTintColor:[UIColor partnerColor]];
    [annotationView setTintColor:[UIColor partnerColor]];
    
    // set offset to the pin - position
    //annotationView.centerOffset = CGPointMake(annotationView.image.size.width * 0.5, annotationView.image.size.height * 0.5);//middle bottom of the image
    
    return annotationView;
}

@end

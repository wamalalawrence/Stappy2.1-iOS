//
//  STReport.m
//  Stappy2
//
//  Created by Pavel Nemecek on 10/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STReport.h"

@implementation STReport
-(CLLocationCoordinate2D)location{
    
    if (_location.latitude==0.0 && _location.longitude == 0.0) {
        
        _location =  CLLocationCoordinate2DMake(_latitude, _longitude);
    }
    return _location;
}

@end

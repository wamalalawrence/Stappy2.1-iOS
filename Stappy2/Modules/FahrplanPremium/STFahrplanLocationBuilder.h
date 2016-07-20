//
//  STFahrplanLocationBuilder.h
//  Stappy2
//
//  Created by Andrej Albrecht on 16.03.16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STFahrplanLocation;

@interface STFahrplanLocationBuilder : NSObject

+(STFahrplanLocation *) buildWithLocationId:(NSString*)locationId locationName:(NSString*)locationName latitude:(double)latitude longitude:(double)longitude;

@end

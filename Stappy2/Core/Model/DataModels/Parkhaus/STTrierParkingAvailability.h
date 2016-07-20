//
//  STTrierParkingAvailability.h
//  Stappy2
//
//  Created by Pavel Nemecek on 11/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STTrierParkingAvailability : NSObject

@property(nonatomic,strong) NSString*name ;
@property(nonatomic,assign) NSInteger shortFree;
@property(nonatomic,assign) NSInteger shortMax;
+(instancetype)availabilityFromDictionary:(NSDictionary*)dictionary;
@end

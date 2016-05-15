//
//  STFahrplanTransportationTypeHelper.h
//  Schwedt
//
//  Created by Andrej Albrecht on 16.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STFahrplanTransportationTypeHelper : NSObject

+(BOOL)isPedestrian:(NSString *)transportationType;
+(BOOL)isTrain:(NSString *)transportationType;
+(BOOL)isBus:(NSString *)transportationType;

@end

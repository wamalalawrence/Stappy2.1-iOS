//
//  STFahrplanTransportationTypeStrategy.h
//  Stappy2
//
//  Created by Andrej Albrecht on 24.03.16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STFahrplanTransportationTypeStrategy : NSObject

-(BOOL)isPedestrian:(NSString *)transportationType;
-(BOOL)isTrain:(NSString *)transportationType;
-(BOOL)isBus:(NSString *)transportationType;

@end

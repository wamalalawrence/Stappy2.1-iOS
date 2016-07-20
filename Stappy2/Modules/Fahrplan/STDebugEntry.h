//
//  STDebugEntry.h
//  Schwedt
//
//  Created by Andrej Albrecht on 03.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STDebugEntry : NSObject

@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic, readonly) NSNumber *coutner;

-(void)incrementCounter;

@end

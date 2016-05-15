//
//  STDebugEntry.m
//  Schwedt
//
//  Created by Andrej Albrecht on 03.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STDebugEntry.h"

@interface STDebugEntry ()

@end

@implementation STDebugEntry

- (instancetype)init
{
    self = [super init];
    if (self) {
        _coutner = [[NSNumber alloc] initWithInt:0];
    }
    return self;
}

-(void)incrementCounter
{
    int value = [self.coutner intValue];
    _coutner = [NSNumber numberWithInt:value + 1];
}

@end

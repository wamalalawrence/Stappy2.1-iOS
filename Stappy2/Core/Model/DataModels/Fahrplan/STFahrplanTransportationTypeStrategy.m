//
//  STFahrplanTransportationTypeStrategy.m
//  Stappy2
//
//  Created by Andrej Albrecht on 24.03.16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STFahrplanTransportationTypeStrategy.h"

@implementation STFahrplanTransportationTypeStrategy

-(BOOL)isPedestrian:(NSString *)transportationType
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

-(BOOL)isTrain:(NSString *)transportationType
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

-(BOOL)isBus:(NSString *)transportationType
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

@end

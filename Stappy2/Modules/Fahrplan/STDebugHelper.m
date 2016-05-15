//
//  STDebugHelper.m
//  Schwedt
//
//  Created by Andrej Albrecht on 03.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STDebugHelper.h"
#import "STDebugEntry.h"

@interface STDebugHelper ()
@property (strong, nonatomic) NSMutableArray *listeners;

@end

@implementation STDebugHelper


#pragma mark - Lifecycle

+ (id)sharedInstance
{
    static STDebugHelper *sharedInstance = nil;
    @synchronized(self) {
        if (sharedInstance == nil){
            sharedInstance = [[self alloc] init];
            sharedInstance.listeners = [NSMutableArray array];
            sharedInstance.debugDict = [NSMutableDictionary dictionary];
        }
    }
    return sharedInstance;
}

-(void)addObserver:(id<STDebugHelperDelegate>)observer
{
    [self.listeners addObject:observer];
}

-(void)removeObserver:(id<STDebugHelperDelegate>)observer
{
    [self.listeners removeObject:observer];
}


#pragma mark - Logic

-(void)reset
{
    self.debugDict = [NSMutableDictionary dictionary];
    
    [self.listeners makeObjectsPerformSelector:@selector(debugHelperDataChanged)];
}

-(void)incrementCounterOfKey:(NSString*)key
{
    NSEnumerator *enumerator = [self.debugDict keyEnumerator];
    NSString *enumKey;
    for(int i=0; enumKey = [enumerator nextObject]; i++){
        if ([enumKey isEqualToString:key]) {
            STDebugEntry *entry = [self.debugDict objectForKey:enumKey];
            [entry incrementCounter];
            [self.listeners makeObjectsPerformSelector:@selector(debugHelperDataChanged)];
            return;
        }
    }

    STDebugEntry *newEntry = [[STDebugEntry alloc] init];
    newEntry.key = key;
    [newEntry incrementCounter];
    [self.debugDict setObject:newEntry forKey:key];
    
    [self.listeners makeObjectsPerformSelector:@selector(debugHelperDataChanged)];
}

-(int)countOfKey:(NSString*)key
{
    STDebugEntry *newEntry = [self.debugDict objectForKey:key];
    return [newEntry.coutner intValue];
}

-(STDebugEntry *)entryAtIndex:(NSInteger)index
{
    NSEnumerator *enumerator = [self.debugDict keyEnumerator];
    NSString *key;
    for(int i=0; key = [enumerator nextObject]; i++){
        if (index == i) {
            return [self.debugDict objectForKey:key];
        }
    }
    
    return nil;
}

-(int)countAllValues
{
    int sum = 0;
    NSEnumerator *enumerator = [self.debugDict keyEnumerator];
    NSString *enumKey;
    for(int i=0; enumKey = [enumerator nextObject]; i++){
        STDebugEntry *entry = [self.debugDict objectForKey:enumKey];
        sum += [entry.coutner intValue];
    }
    return sum;
}

@end

//
//  STDebugHelper.h
//  Schwedt
//
//  Created by Andrej Albrecht on 03.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STDebugEntry;

@protocol STDebugHelperDelegate <NSObject>
-(void)debugHelperDataChanged;
@end


@interface STDebugHelper : NSObject

@property (strong, nonatomic) NSMutableDictionary *debugDict;

#pragma mark - Lifecycle
+ (id)sharedInstance;
-(void)addObserver:(id<STDebugHelperDelegate>)observer;
-(void)removeObserver:(id<STDebugHelperDelegate>)observer;

#pragma mark - Logic
-(void)reset;
-(void)incrementCounterOfKey:(NSString*)key;
-(int)countOfKey:(NSString*)key;
-(STDebugEntry *)entryAtIndex:(NSInteger)index;
-(int)countAllValues;

@end

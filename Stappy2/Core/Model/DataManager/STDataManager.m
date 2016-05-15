//
//  STDataManager.m
//  Stappy2
//
//  Created by Cynthia Codrea on 23/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STDataManager.h"
#import "NSDate+DKHelper.h"
#import "STMainModel.h"
#import "STTableMainKeyObject.h"
#import "STTableSecondaryKeyObject.h"

@implementation STDataManager

+(NSMutableArray *)nameDitionaryAlreadyExist:(NSString *)name inArray:(NSMutableArray*)tableArray forKey:(NSString*)key{ //todo send also the key to make methis more abstract
    
    for(NSMutableArray *array in tableArray){
    
        for(STMainModel* model in array) {
            
            NSString *stringToGroup = [self stringFromKey:[model valueForKey:key]];

            if([stringToGroup isEqualToString:name])
                //return the existing array refrence to add
                return array;
        }
    }
    
    // if if wasn't found then we come here and return nil
    return nil;
}

//use this method to group the data by a key
//returns an array of arrays of models each array with different keyType

+(NSArray *)groupArrayOfDictionaries:(NSArray*)dataPackage ByKey:(NSString *)key{
    
    NSMutableArray* tableArray = [[NSMutableArray alloc] init];
    
    for(STMainModel* model in dataPackage) {

        NSString *stringToGroup = [self stringFromKey:[model valueForKey:key]];
        
        NSMutableArray* existingNameArray=[self nameDitionaryAlreadyExist:stringToGroup inArray:tableArray forKey:key];
        if(existingNameArray!=nil) {
            //if name exist add in existing array....
            [existingNameArray addObject:model];
        }
        else {
            // create new name array
            NSMutableArray* newNameArray=[[NSMutableArray alloc] init];
            // Add name dictionary in it
            [newNameArray addObject:model];
            
            // add this newly created nameArray in globalNameArray
            [tableArray addObject:newNameArray];
        }
    }
    
    NSLog(@"Table array %@", tableArray);
    return tableArray;
}

+(NSArray*)groupArrayOfModels:(NSArray*)modelsArray {
    
    NSArray *modelsGroupedByMainKey            = [self groupArrayOfDictionaries:modelsArray ByKey:@"mainKey"];
    NSMutableArray *mainKeyArray               = [NSMutableArray array];
    for (NSArray* arr in modelsGroupedByMainKey) {

    NSMutableArray *modelsGrouped              = [[NSMutableArray alloc] init];
    STTableMainKeyObject *mainKeyObject        = [[STTableMainKeyObject alloc] init];
    
    NSArray *modelsGroupedBySecondaryKey       = [self groupArrayOfDictionaries:arr ByKey:@"secondaryKey"];
        for (NSArray* array in modelsGroupedBySecondaryKey) {
    STTableSecondaryKeyObject *secondaryObject = [[STTableSecondaryKeyObject alloc] init];
    secondaryObject.secondaryKeyArray          = array;
            [modelsGrouped addObject:secondaryObject];
        }
    mainKeyObject.mainKeyArray                 = modelsGrouped;
        [mainKeyArray addObject:mainKeyObject];
    }
    return mainKeyArray;
}

+(NSString *)stringFromKey:(NSString*)key {
    
    NSDate *date = [NSDate dateFromString:key format:@"dd.MM.yyyy HH:mm"];
    if (date == nil) {
        return key;
    }
    return [date displayableString];
}

@end

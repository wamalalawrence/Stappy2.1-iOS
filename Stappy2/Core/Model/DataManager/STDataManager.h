//
//  STDataManager.h
//  Stappy2
//
//  Created by Cynthia Codrea on 23/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STTableMainKeyObject;

@interface STDataManager : NSObject

/**
 *  @brief Groups array into an array of dictionaries based on one common key (ex. items with the same date)
 *
 *  @param dataPackage array of items to group
 *  @param key         the common key to group by
 *
 *  @return array of dictionaries with each dictionary containing items with the same key sent as param
 */
+(NSArray *)groupArrayOfDictionaries:(NSArray*)dataPackage ByKey:(NSString *)key;

/**
 *  @brief checks if we already have a dictionary with item containing the same key
 *
 *  @param name       the string for the key by which we group
 *  @param tableArray the array to check in
 *  @param key        the key to group by
 *
 *  @return return the existing array refrence to add the item
 */
+(NSMutableArray *)nameDitionaryAlreadyExist:(NSString *)name inArray:(NSMutableArray*)tableArray forKey:(NSString*)key;

/**
 *  @brief generic method for grouping array of items by one main key and the subitems by secondary key
 *
 *  @param modelsArray array to be grouped
 *
 *  @return grouped array
 */
+(NSArray *)groupArrayOfModels:(NSArray*)modelsArray;

@end

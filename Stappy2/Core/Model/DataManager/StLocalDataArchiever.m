//
//  StLocalDataArchiever.m
//  Schwedt
//
//  Created by Cynthia Codrea on 10/02/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "StLocalDataArchiever.h"
#import "STAngeboteModel.h"
#import "STEventsModel.h"
#import "STStadtInfoOverviewModel.h"
#import "STMainModel.h"
#import "Defines.h"
#import "Utils.h"
#import "STDetailGenericModel.h"

#define SEARCH_ARRAY_CAPACITY 2000

@implementation StLocalDataArchiever

+(StLocalDataArchiever*)sharedArchieverManager {
    static StLocalDataArchiever* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        
        instance.savedAngebote = [NSKeyedUnarchiver unarchiveObjectWithFile:[Utils filePathForPlist:kFavoriteAngeboteListName]];
        if (!instance.savedAngebote) {
            instance.savedAngebote = [NSMutableArray array];
        }
        
        instance.savedEvents = [NSKeyedUnarchiver unarchiveObjectWithFile:[Utils filePathForPlist:kFavoriteEventsListName]];
        if (!instance.savedEvents) {
            instance.savedEvents = [NSMutableArray array];
        }
        
        instance.savedStadtInfos = [NSKeyedUnarchiver unarchiveObjectWithFile:[Utils filePathForPlist:kFavoriteStadtInfosListName]];
        if (!instance.savedStadtInfos) {
            instance.savedStadtInfos = [NSMutableArray array];
        }
        
        instance.searchItems = [NSKeyedUnarchiver unarchiveObjectWithFile:[Utils filePathForPlist:kSearchListName]];
        if (!instance.searchItems) {
            instance.searchItems = [NSMutableArray arrayWithCapacity:SEARCH_ARRAY_CAPACITY];
        }
    });
    return instance;
}

#pragma mark -

- (BOOL)isFavorite:(STMainModel<Favoritable> *)model {
    NSArray *arrayToSearch;
    
    if ([model isKindOfClass:[STAngeboteModel class]])    arrayToSearch = self.savedAngebote;
    else if ([model isKindOfClass:[STEventsModel class]]) arrayToSearch = self.savedEvents;
    else if ([model isKindOfClass:[STStadtInfoOverviewModel class]]) arrayToSearch = self.savedStadtInfos;
    
    return [self isModel:model storedInFavoritesArray:arrayToSearch];
}

- (BOOL)isModel:(STMainModel<Favoritable> *)model storedInFavoritesArray:(NSArray *)array {
    for (STMainModel *m in array) {
        if ([m.title isEqualToString:model.title]) {
            model.favorite = YES;
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - save methods

- (void)saveFavoriteStatusForModel:(STMainModel<Favoritable> *)model {
    NSMutableArray *arrayToStoreData;
    
    if ([model isKindOfClass:[STAngeboteModel class]] || [model isKindOfClass:[STDetailGenericModel class]])
        arrayToStoreData = self.savedAngebote;
    else if ([model isKindOfClass:[STEventsModel class]])            arrayToStoreData = self.savedEvents;
    else if ([model isKindOfClass:[STStadtInfoOverviewModel class]]) arrayToStoreData = self.savedStadtInfos;
    
    if (model.favorite) {
        [arrayToStoreData removeObject:model];
    } else {
        [arrayToStoreData addObject:model];
    }
    
    model.favorite = !model.favorite;
    [self saveAllFavorites];
}

- (void)saveFavoriteEvents {
    NSString *filePath = [Utils filePathForPlist:kFavoriteEventsListName];
    [NSKeyedArchiver archiveRootObject:self.savedEvents toFile:filePath];
}

- (void)saveFavoriteAngebote {
    NSString *filePath = [Utils filePathForPlist:kFavoriteAngeboteListName];
    [NSKeyedArchiver archiveRootObject:self.savedAngebote toFile:filePath];
}

- (void)saveFavoriteStadtInfos {
    NSString *filePath = [Utils filePathForPlist:kFavoriteStadtInfosListName];
    [NSKeyedArchiver archiveRootObject:self.savedStadtInfos toFile:filePath];
}

- (void)saveAllFavorites {
    [self saveFavoriteEvents];
    [self saveFavoriteAngebote];
    [self saveFavoriteStadtInfos];
}

- (void)saveSearchItems {
    NSString *filePath = [Utils filePathForPlist:kSearchListName];
    [NSKeyedArchiver archiveRootObject:self.searchItems toFile:filePath];
}

- (void)saveObjectInSearchArray:(STMainModel*)searctItem {
    STMainModel *modelFound = [Utils searchForMainModel:searctItem inModelsArray:self.searchItems];
    if (!modelFound && self.searchItems.count < SEARCH_ARRAY_CAPACITY) {
        [self.searchItems addObject:searctItem];
    }
}

- (void)saveObjectsInSearchArray:(NSArray *)items {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (STMainModel *m in items) {
            [self saveObjectInSearchArray:m];
        }
        [self saveSearchItems];
    });
}

#pragma searchMethods

- (void)searchForString:(NSString *)searchString completionHandler:(void (^)(NSArray *))handler {
    NSMutableArray *searchResults = [NSMutableArray array];
    if (searchString.length == 0) {
        handler(searchResults);
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (STMainModel * searchItem in self.searchItems) {
            if (([searchItem.title.lowercaseString rangeOfString:searchString.lowercaseString].location != NSNotFound) /*||
                ([searchItem.body rangeOfString:searchString].location != NSNotFound)*/ ) {
                [searchResults addObject:searchItem];
            }
        }
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(searchResults);
            });
    });
}

@end

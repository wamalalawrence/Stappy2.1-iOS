//
//  StLocalDataArchiever.h
//  Schwedt
//
//  Created by Cynthia Codrea on 10/02/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STEventsModel.h"
#import "STAngeboteModel.h"

@interface StLocalDataArchiever : NSObject
@property(nonatomic, strong)NSMutableArray *savedEvents;
@property(nonatomic, strong)NSMutableArray *savedAngebote;
@property(nonatomic, strong)NSMutableArray *savedStadtInfos;
@property(nonatomic, strong)NSMutableArray *searchItems;

+ (StLocalDataArchiever*)sharedArchieverManager;

- (BOOL)isFavorite:(STMainModel<Favoritable> *)model;

- (void)saveFavoriteStatusForModel:(STMainModel<Favoritable> *)model;
- (void)saveFavoriteAngebote;
- (void)saveFavoriteEvents;
- (void)saveAllFavorites;

- (void)saveSearchItems;
- (void)saveObjectInSearchArray:(STMainModel*)searctItem;
- (void)saveObjectsInSearchArray:(NSArray *)items;

- (void)searchForString:(NSString *)searchString completionHandler:(void (^)(NSArray *))handler;

@end

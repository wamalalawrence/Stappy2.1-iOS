//
//  STLeftSideSubSettingsModel.m
//  Stappy2
//
//  Created by Cynthia Codrea on 26/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STLeftSideSubSettingsModel.h"
#import "Defines.h"
#import "NSDictionary+Default.h"
#import "STAppSettingsManager.h"

typedef NS_ENUM(NSInteger, ModelIdsState)
{
    ModelIdsStateEnabled,
    ModelIdsStateAll
};

@interface STLeftSideSubSettingsModel()
- (SettingsSelectionsState)selectionStateOfItem:(STLeftSideSubSettingsModel *)item;

- (NSArray *)modelIdsForState:(ModelIdsState)state;

- (void)addKeyValueObservation;
- (void)removeKeyValueObservation;
@end

@implementation STLeftSideSubSettingsModel

+(NSDictionary*)JSONKeyPathsByPropertyKey {
    
    return @{
             @"title":@"caption",
             @"url":@"url",
             @"itemType":@"type",
             @"subItems":@"sub_items"
             };
}

- (instancetype)initWithDictionary:(NSDictionary *)dict filterType:(NSString *)filterType
{
    if (self = [super init])
    {
        // Load values from dictionary
        self.modelId = [dict valueForKey:kIdStringKey withDefault:@""];
        self.title = [dict valueForKey:kTitleStringKey withDefault:@""];
        self.itemType = [dict valueForKey:@"type" withDefault:@""];
        self.url = [dict valueForKey:@"url" withDefault:@""];

        if (self.title.length == 0) self.title = [dict valueForKey:kNameString withDefault:@""];

        id childrenObject = [dict valueForKey:kChildrenStringKey withDefault:nil];
        if (childrenObject) [self loadSubItemsFromObject:childrenObject forFilterType:filterType];
        else
        {
            _filterType = filterType;
            _selectionState = [self resolveUnknownSelectionState];
        }

        [self addKeyValueObservation];
    }
    
    return self;
}

#pragma - Public methods

- (void)loadSubItemsFromObject:(id)subitems forFilterType:(NSString *)filterType
{
    NSMutableArray *childrenArray = [NSMutableArray array];
    if ([subitems isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *subitemsDict = (NSDictionary *)subitems;
        for (NSString *key in [subitemsDict allKeys])
        {
            NSDictionary *childDict = [subitemsDict objectForKey:key];
            STLeftSideSubSettingsModel *child = [[STLeftSideSubSettingsModel alloc] initWithDictionary:childDict filterType:filterType];
            child.filterType = filterType;
            child.selectionState = [child resolveUnknownSelectionState];
            child.title = key;
            [childrenArray addObject:child];
        }
    }
    else if ([subitems isKindOfClass:[NSArray class]])
    {
        NSArray *subitemsArray = (NSArray *)subitems;
        for (NSDictionary *childDict in subitemsArray)
        {
            STLeftSideSubSettingsModel *child = [[STLeftSideSubSettingsModel alloc] initWithDictionary:childDict filterType:filterType];
            child.filterType = filterType;
            child.selectionState = [child resolveUnknownSelectionState];
            [childrenArray addObject:child];
        }
    }

    self.subItems = childrenArray;
}

#pragma mark - selectionState methods

- (SettingsSelectionsState)resolveUnknownSelectionState
{
    if (_selectionState != SettingsSelectionsStateUnknown) return _selectionState;

    NSError *error;
    NSArray *defaultFilters = [[Filters sharedInstance] filtersForType:_filterType error:&error];
    NSArray *allIdsAreOnPerDefaultInViewControllers = [[STAppSettingsManager sharedSettingsManager] allIdsAreOnPerDefaultInViewControllers];
    
    if (error)
    {
        NSLog(@"Could not find filters for filterType:%@\nError:%@", _filterType, error);
        return SettingsSelectionsStateNone;
    }
    
    if (_subItems.count == 0 )
    {
        BOOL filtersWereAlreadyLoadedForFilterType = [[Filters sharedInstance] areFiltersAlreadyLoadedFromServerForStringFilterType:_filterType];
        
        if ([defaultFilters containsObject:@([_modelId integerValue])]) return SettingsSelectionsStateAll;
        else if ([allIdsAreOnPerDefaultInViewControllers containsObject:_filterType] && !filtersWereAlreadyLoadedForFilterType)
        {
            NSError *error = nil;
            [[Filters sharedInstance] saveFilterWithFilterIds:self.allModelIds forStringFilterType:_filterType notification:NO error:&error];
            
            return SettingsSelectionsStateAll;
        }
        else return SettingsSelectionsStateNone;
    }
    else return [self selectionState];
}

/**
 * in filters we store only IDs of leafs. So what we can do is to call the selectionState function recursively on
 * every element of the subItems, if subItems is not empty. And then verify the
 */
- (SettingsSelectionsState)selectionState { return [self selectionStateOfItem:self]; }

- (SettingsSelectionsState)selectionStateOfItem:(STLeftSideSubSettingsModel *)item
{
    NSArray *enabledIds = [self enabledModelIds];

    if (enabledIds.count == 0) return SettingsSelectionsStateNone;

    if (item.subItems.count == 0)
    {
        if ([enabledIds containsObject:@([item.modelId integerValue])]) return SettingsSelectionsStateAll;
        else                                                            return SettingsSelectionsStateNone;
    }
    else
    {
        NSArray *allIds = [self allModelIds];

        if ([enabledIds isEqualToArray:allIds]) return SettingsSelectionsStateAll;
        else if (enabledIds.count > 0)          return SettingsSelectionsStateSome;
        else                                    return SettingsSelectionsStateNone;
    }
}

- (void)setAllSubitemsToState:(SettingsSelectionsState)selectionState
{
    self.selectionState = selectionState;
    for(STLeftSideSubSettingsModel *childModel in _subItems) childModel.selectionState = selectionState;
}

#pragma mark - modelIds methods

- (NSArray *)modelIdsForState:(ModelIdsState)state
{
    NSArray *modelIds = [NSArray array];

    if (_subItems.count > 0)
    {
        for (STLeftSideSubSettingsModel *subItem in _subItems)
        {
            NSArray *itemModelIds = [subItem modelIdsForState:state];
            modelIds = [modelIds arrayByAddingObjectsFromArray:itemModelIds];
        }
    }
    else
    {
        switch (state)
        {
            case ModelIdsStateEnabled:
                if (_selectionState == SettingsSelectionsStateAll) return @[@([_modelId integerValue])];
                else                                               return @[];
                break;
                
            case ModelIdsStateAll: return @[@([_modelId integerValue])]; break;
        }
    }

    return modelIds;
}

- (NSArray *)enabledModelIds { return [self modelIdsForState:ModelIdsStateEnabled]; }

- (NSArray *)allModelIds { return [self modelIdsForState:ModelIdsStateAll];  }

#pragma mark - KVO for selectionState change

- (void)addKeyValueObservation
{
    for (STLeftSideSubSettingsModel *model in _subItems)
    {
        [model addKeyValueObservation];
        [model addObserver:self forKeyPath:@"selectionState" options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"selectionState"])
    {
        self.selectionState = [self selectionStateOfItem:self];
    }
}

- (void)removeKeyValueObservation
{
    for (STLeftSideSubSettingsModel *model in _subItems)
    {
        [model removeKeyValueObservation];
        [model removeObserver:self forKeyPath:@"selectionState"];
    }
}

- (void)dealloc { [self removeKeyValueObservation]; }

@end

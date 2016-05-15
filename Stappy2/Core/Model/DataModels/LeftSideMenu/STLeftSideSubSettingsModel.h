//
//  STLeftSideSubSettingsModel.h
//  Stappy2
//
//  Created by Cynthia Codrea on 26/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "SettingsSelectionsTableViewCell.h"
#import "Stappy2-Swift.h"

@interface STLeftSideSubSettingsModel : MTLModel<MTLJSONSerializing>
{
    SettingsSelectionsState _selectionState;
}

@property(nonatomic,copy)NSString *title;
@property(nonatomic, strong)NSString *modelId;
@property(nonatomic, copy)NSString *itemType;
@property(nonatomic, strong)NSString *url;

@property(nonatomic,strong)NSArray *subItems;
@property(nonatomic, assign, getter = isSelected)BOOL selected;

@property(nonatomic, assign) SettingsSelectionsState selectionState;
@property(nonatomic, weak) NSString *filterType;
@property(nonatomic, strong, readonly) NSArray *enabledModelIds;
@property(nonatomic, strong, readonly) NSArray *allModelIds;

- (instancetype)initWithDictionary:(NSDictionary *)dict filterType:(NSString *)filterType;

- (void)loadSubItemsFromObject:(id)subitems forFilterType:(NSString *)filterType;

- (void)setAllSubitemsToState:(SettingsSelectionsState)selectionsState;
@end

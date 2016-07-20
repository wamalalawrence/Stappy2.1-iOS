//
//  STLeftMenuSettingsModel.h
//  Stappy2
//
//  Created by Cynthia Codrea on 26/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface STLeftMenuSettingsModel : MTLModel <MTLJSONSerializing>

@property(nonatomic, copy)NSString* title;
@property(nonatomic, copy)NSString* iconName;
@property(nonatomic, strong)NSArray* subItems;
@property(nonatomic, assign, getter = isSelected)BOOL selected;
@property(nonatomic, strong)NSString *type;
@property(nonatomic, strong)NSString *type_api;
@property(nonatomic, strong)NSString *url;
@property(nonatomic, assign)float defaultLatitude;
@property(nonatomic, assign)float defaultLongitude;
@property(nonatomic,assign, getter=areAllSubitemsSeleted)BOOL allSubitemsSelected;
@property(nonatomic, strong)NSString *modelId;
@property (nonatomic, strong) NSArray * children;

-(id)initWithDictionary:(NSDictionary*)dict;

- (void)loadSubItemsFromObject:(id)subitems forFilterType:(NSString *)filterType;

@end

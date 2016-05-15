//
//  STLeftMenuSettingsModel.m
//  Stappy2
//
//  Created by Cynthia Codrea on 26/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STLeftMenuSettingsModel.h"
#import "STLeftSideSubSettingsModel.h"
#import "Defines.h"
#import "NSDictionary+Default.h"

@implementation STLeftMenuSettingsModel

-(id)initWithDictionary:(NSDictionary*)dict {
    self = [super init];
    if (self) {
        // Load values from dictionary
        self.modelId = [dict valueForKey:kIdStringKey withDefault:@""];
        self.title = [dict valueForKey: kNameString withDefault:@""];
        if (self.title.length == 0) {
            self.title = [dict valueForKey: kTitleStringKey withDefault:@""];
        }
    }
    
    return self;
}

#pragma - Public methods

- (void)loadSubItemsFromObject:(id)subitems forFilterType:(NSString *)filterType
{
    NSMutableArray *childrenArray = [NSMutableArray array];
    if ([subitems isKindOfClass:[NSDictionary class]]) {
        NSDictionary *subitemsDict = (NSDictionary *)subitems;
        for (NSString *key in [subitemsDict allKeys]) {
            NSDictionary *childDict = [subitemsDict objectForKey:key];
            STLeftSideSubSettingsModel *child = [[STLeftSideSubSettingsModel alloc] initWithDictionary:childDict filterType:filterType];
            child.title = key;
            [childrenArray addObject:child];
        }
    } else if ([subitems isKindOfClass:[NSArray class]]) {
        NSArray *subitemsArray = (NSArray *)subitems;
        for (NSDictionary *childDict in subitemsArray) {
            STLeftSideSubSettingsModel *child = [[STLeftSideSubSettingsModel alloc] initWithDictionary:childDict filterType:filterType];
            [childrenArray addObject:child];
        }
    }
    self.subItems = childrenArray;
}


#pragma - NSCoding methods
- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (self.title) {
        [aCoder encodeObject:self.title forKey:kTitleStringKey];
    }
    if (self.iconName) {
        [aCoder encodeObject:self.iconName forKey:kIconNameStringKey];
    }
    if (self.subItems) {
        [aCoder encodeObject:self.subItems forKey:kSubitemsStringKey];
    }
    if (self.type) {
        [aCoder encodeObject:self.type forKey:kTypeStringKey];
    }
    [aCoder encodeBool:self.selected forKey:kElementSelectedString];
    [aCoder encodeBool:self.allSubitemsSelected forKey:kAllChildrenSelectedStringKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self.title = [aDecoder decodeObjectForKey:kTitleStringKey];
    self.iconName = [aDecoder decodeObjectForKey:kIconNameStringKey];
    self.subItems = [aDecoder decodeObjectForKey:kSubitemsStringKey];
    self.selected = [aDecoder decodeBoolForKey:kElementSelectedString];
    self.type = [aDecoder decodeObjectForKey:kTypeStringKey];
    self.allSubitemsSelected = [aDecoder decodeBoolForKey:kAllChildrenSelectedStringKey];
    
    return self;
}

+(NSDictionary*)JSONKeyPathsByPropertyKey {
    
    return @{
             @"title":@"caption",
             @"iconName":@"icon_name",
             @"type":@"type",
             @"subItems":@"sub_items"
             };
}

+(NSValueTransformer *)subItemsJSONTransformer __unused {
    
    return [MTLValueTransformer transformerWithBlock:^id(id subItems) {
        if ( [subItems isKindOfClass:[NSArray class]] ) {
            return [[MTLValueTransformer mtl_JSONArrayTransformerWithModelClass:[STLeftSideSubSettingsModel class]] transformedValue:subItems];
        }
        else if ( [subItems isKindOfClass:[NSDictionary class]] ) {
            NSMutableArray *subItems = [[NSMutableArray alloc] init];
            [subItems addObject:[[MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[STLeftSideSubSettingsModel class]] transformedValue:subItems]];
            return subItems;
        }
        return nil;
    }];
    
}

@end

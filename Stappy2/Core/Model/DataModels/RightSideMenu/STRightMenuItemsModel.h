//
//  STRightMenuItemsModel.h
//  Stappy2
//
//  Created by Cynthia Codrea on 27/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "STLeftMenuSettingsModel.h"

@interface STRightMenuItemsModel : STLeftMenuSettingsModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber *modelId;
@property(nonatomic,copy)NSString* detailsUrl;
@property(nonatomic,copy)NSString* optionType;
@property(nonatomic,strong)NSArray* children;
@property(nonatomic,copy)NSString* icon_name;

@end

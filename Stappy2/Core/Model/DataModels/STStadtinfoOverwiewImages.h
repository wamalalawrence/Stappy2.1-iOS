//
//  STStadtinfoOverwiewImages.h
//  Stappy2
//
//  Created by Cynthia Codrea on 17/03/2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface STStadtinfoOverwiewImages : MTLModel <MTLJSONSerializing>

@property(nonatomic,copy)NSString* location;
@property(nonatomic,copy)NSString* previewIconName;
@property(nonatomic,copy)NSString* type;

@end

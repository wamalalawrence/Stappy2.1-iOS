//
//  STStadtinfoOverwiewImages.m
//  Stappy2
//
//  Created by Cynthia Codrea on 17/03/2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STStadtinfoOverwiewImages.h"

@implementation STStadtinfoOverwiewImages

+(NSDictionary*)JSONKeyPathsByPropertyKey {
    
    return @{
             @"location":@"full",
             @"previewIconName":@"preview",
             @"type":@"type"
             };
}
@end

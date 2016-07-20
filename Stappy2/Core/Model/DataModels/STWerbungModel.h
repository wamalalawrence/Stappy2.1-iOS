//
//  STWerbungModel.h
//  Stappy2
//
//  Created by Cynthia Codrea on 13/04/2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface STWerbungModel : MTLModel <MTLJSONSerializing>

@property(nonatomic,copy)NSString* url;
@property(nonatomic, copy)NSString* image;
@property(nonatomic, copy)NSString* type;

@end

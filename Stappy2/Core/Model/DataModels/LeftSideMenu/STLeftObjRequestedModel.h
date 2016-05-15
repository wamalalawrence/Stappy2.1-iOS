//
//  STLeftObjRequestedModel.h
//  Schwedt
//
//  Created by Cynthia Codrea on 04/02/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface STLeftObjRequestedModel : MTLModel <MTLJSONSerializing>

@property(nonatomic,copy)NSString* itemName;
@property(nonatomic,strong)NSArray* children;

@end

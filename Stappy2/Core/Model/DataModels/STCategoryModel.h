//
//  STCategoryModel.h
//  Stappy2
//
//  Created by Cynthia Codrea on 1/24/16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface STCategoryModel : MTLModel <MTLJSONSerializing>

@property(nonatomic,copy)NSString* title;
@property(nonatomic,copy)NSString* url;
@property(nonatomic,copy)NSString* type;

@end

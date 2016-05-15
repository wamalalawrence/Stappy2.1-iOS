//
//  STNewsModel.h
//  Stappy2
//
//  Created by Cynthia Codrea on 16/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "MTLJSONAdapter.h"
#import "STMainModel.h"

@interface STNewsModel : STMainModel <MTLJSONSerializing>

@property(nonatomic, assign)NSInteger newsItemID;

@end

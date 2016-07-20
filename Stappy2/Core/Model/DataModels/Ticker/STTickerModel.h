//
//  STTickerModel.h
//  Stappy2
//
//  Created by Cynthia Codrea on 10/12/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STMainModel.h"

@interface STTickerModel : STMainModel <MTLJSONSerializing>

@property(nonatomic, copy)NSString *tickerItemID;

@end

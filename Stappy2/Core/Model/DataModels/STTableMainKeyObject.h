//
//  STTableMainKeyObjects.h
//  Stappy2
//
//  Created by Cynthia Codrea on 30/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OpeningClosingTimeModel.h"
#import "OpeningClosingTimesModel.h"

@interface STTableMainKeyObject : NSObject

@property(nonatomic, strong)NSArray *mainKeyArray;
@property(nonatomic, assign)BOOL isSectionExpanded;
@property(nonatomic, strong)NSMutableArray *expandableSectionItems;

@end

//
//  STExpandedTableBottomObject.h
//  Schwedt
//
//  Created by Andrei Neag on 03.02.2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STExpandedTableBottomObject : NSObject
// This should hold all the objects inserted when the table was expanded, in order to easy collapse back the table.
@property(nonatomic, retain)NSArray *expandedObjects;
@property(nonatomic, retain)NSArray *expandedCellIndexes;

@end

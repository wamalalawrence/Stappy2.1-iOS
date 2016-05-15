//
//  STTableSecondaryKeyObjects.m
//  Stappy2
//
//  Created by Cynthia Codrea on 30/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STTableSecondaryKeyObject.h"
#import "STExpandedTableBottomObject.h"
#import "STExpandedTableTopObject.h"

@implementation STTableSecondaryKeyObject

-(void)setIsRowExpanded:(BOOL)isRowExpanded {
    _isRowExpanded = isRowExpanded;
    if (isRowExpanded) {
        STExpandedTableTopObject *top = [[STExpandedTableTopObject alloc] init];
        STExpandedTableBottomObject *bottom = [[STExpandedTableBottomObject alloc] init];
        NSMutableArray *expandedArray = [NSMutableArray arrayWithArray:self.secondaryKeyArray];
        [expandedArray addObject:bottom];
        [expandedArray insertObject:top atIndex:0];
        self.expandedObjectsArray = expandedArray;
    } else {
        self.expandedObjectsArray = [NSArray array];
    }
}

@end

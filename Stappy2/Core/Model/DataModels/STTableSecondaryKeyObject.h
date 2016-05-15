//
//  STTableSecondaryKeyObjects.h
//  Stappy2
//
//  Created by Cynthia Codrea on 30/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STTableSecondaryKeyObject : NSObject

@property(nonatomic,strong)NSArray *secondaryKeyArray;
@property(nonatomic, strong)NSArray *expandedObjectsArray;
@property(nonatomic,assign)BOOL isRowExpanded;

-(void)setIsRowExpanded:(BOOL)isRowExpanded;

@end

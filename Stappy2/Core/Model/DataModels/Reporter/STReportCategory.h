//
//  STReportCategory.h
//  Stappy2
//
//  Created by Pavel Nemecek on 10/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "STReportType.h"
@interface STReportCategory:MTLModel <MTLJSONSerializing>
@property (nonatomic,assign) NSInteger reportCategoryId;
@property (nonatomic,strong) NSString* name;
@property (nonatomic,strong) NSArray<STReportType*>*types;
+(NSArray*)allCategories;
@end

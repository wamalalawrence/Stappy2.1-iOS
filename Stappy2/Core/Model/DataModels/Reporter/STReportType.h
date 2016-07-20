//
//  STReportType.h
//  Stappy2
//
//  Created by Pavel Nemecek on 10/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
@interface STReportType :MTLModel <MTLJSONSerializing>
@property (nonatomic,assign) NSInteger reportTypeId;
@property (nonatomic,strong) NSString* name;

@end

//
//  STReportListModel.h
//  Stappy2
//
//  Created by Pavel Nemecek on 03/06/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STReportListModel : NSObject

@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *descriptionString;
@property(nonatomic,strong) NSDate *publishDate;
+(instancetype)reportListModelFromDictionary:(NSDictionary*)dictionary;

@end

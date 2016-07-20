//
//  STReportListModel.m
//  Stappy2
//
//  Created by Pavel Nemecek on 03/06/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STReportListModel.h"

@implementation STReportListModel

+(instancetype)reportListModelFromDictionary:(NSDictionary*)dictionary{
    
    STReportListModel *model = [[STReportListModel alloc] init];
    model.descriptionString = [dictionary objectForKey:@"subtitle"];
    model.title = [dictionary objectForKey:@"title"];
    NSString*dateString =[dictionary valueForKey:@"creationdate"];
    NSDateFormatter*dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy HH:mm";
    model.publishDate = [dateFormatter dateFromString:dateString];
    return model;
}


@end

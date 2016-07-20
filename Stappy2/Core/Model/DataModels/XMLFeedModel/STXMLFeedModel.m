//
//  STTrierVerkehrsmeldungen.m
//  Stappy2
//
//  Created by Cynthia Codrea on 26/05/2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STXMLFeedModel.h"

@implementation STXMLFeedModel

+(instancetype)feedModelFromDictionary:(NSDictionary*)dictionary{
    
    STXMLFeedModel *model = [[STXMLFeedModel alloc] init];
    model.descriptionString = [dictionary objectForKey:@"description"];
    model.title = [dictionary objectForKey:@"title"];
    model.url = [dictionary objectForKey:@"link"];
    NSString*dateString =[dictionary valueForKey:@"pubDate"];
    dateString= [dateString stringByReplacingOccurrencesOfString:@" +0200" withString:@""];
    NSDateFormatter*dateFormatter = [[NSDateFormatter alloc] init];
       NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier: @"en_US"];
    dateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss";
    [dateFormatter setLocale:locale];
    model.publishDate = [dateFormatter dateFromString:dateString];
    return model;
}

@end

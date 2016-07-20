//
//  STTrierVerkehrsmeldungen.h
//  Stappy2
//
//  Created by Cynthia Codrea on 26/05/2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STXMLFeedModel: NSObject

@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *descriptionString;
@property(nonatomic,strong) NSDate *publishDate;
@property(nonatomic,strong) NSString *url;
+(instancetype)feedModelFromDictionary:(NSDictionary*)dictionary;

@end

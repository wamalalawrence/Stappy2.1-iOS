//
//  STApiConfigObject.h
//  Schwedt
//
//  Created by Andrei Neag on 31.01.2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STApiConfigObject : NSObject <NSCoding>

@property(nonatomic, strong)NSString *baseUrlString;
@property(nonatomic, strong)NSString *departureTimeUrl;
@property(nonatomic, strong)NSDictionary *autorizationHeader;

@end

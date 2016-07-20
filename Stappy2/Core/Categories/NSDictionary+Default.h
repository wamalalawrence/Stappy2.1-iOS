//
//  NSDictionary+Default.h
//  Stappy2
//
//  Created by Denis Grebennicov on 11/01/16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Default)

- (id)valueForKey:(NSString *)key withDefault:(id)defaultValue;

@end
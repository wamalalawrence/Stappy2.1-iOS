//
//  NSDictionary+Default.m
//  Stappy2
//
//  Created by Denis Grebennicov on 11/01/16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "NSDictionary+Default.h"

@implementation NSDictionary (Default)

- (id)valueForKey:(NSString *)key withDefault:(id)defaultValue
{
    id value = [self valueForKey:key];
    if (value && ![value isKindOfClass:[NSNull class]]) return value;
    else                                                return defaultValue;
}

@end

//
//  NSString+Utils.m
//  Stappy2
//
//  Created by Cynthia Codrea on 29/02/2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

- (NSString *) capitalizedFirstLetter {
    NSString *retVal = self;
    if (self.length <= 1) {
        retVal = self.capitalizedString;
    } else {
        retVal = [NSString stringWithFormat:@"%@%@",[[self substringToIndex:1] uppercaseString],[[self substringFromIndex:1] lowercaseString]];
    }
    return retVal;
}

-(NSString *)splitString:(NSString *)inputString {
    
    NSRegularExpression *regexp = [NSRegularExpression
                                   regularExpressionWithPattern:@"([a-z])([A-Z])"
                                   options:0
                                   error:NULL];
    NSString *newString = [regexp
                           stringByReplacingMatchesInString:inputString
                           options:0 
                           range:NSMakeRange(0, inputString.length)
                           withTemplate:@"$1 $2"];
    return newString;
}

@end

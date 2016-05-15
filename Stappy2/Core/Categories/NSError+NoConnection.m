//
//  NSError+NoConnection.m
//  Schwedt
//
//  Created by Andrej Albrecht on 08.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "NSError+NoConnection.h"

@implementation NSError (NoConnection)

- (BOOL)isNoInternetConnectionError
{
    return ([self.domain isEqualToString:NSURLErrorDomain] || (self.code == NSURLErrorNotConnectedToInternet));
}

@end

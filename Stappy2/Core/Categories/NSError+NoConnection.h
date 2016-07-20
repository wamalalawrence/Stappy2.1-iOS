//
//  NSError+NoConnection.h
//  Schwedt
//
//  Created by Andrej Albrecht on 08.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (NoConnection)

- (BOOL)isNoInternetConnectionError;

@end

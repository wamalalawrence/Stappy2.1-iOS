//
//  STHTTPRequestOperationManager.m
//  Stappy2
//
//  Created by Andrei Neag on 12/6/15.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STHTTPRequestOperationManager.h"

@implementation STHTTPRequestOperationManager

- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)request
                                                    success:(void (^)(AFHTTPRequestOperation *operation,
                                                                      id responseObject))success
                                                    failure:(void (^)(AFHTTPRequestOperation *operation,
                                                                      NSError *error))failure
{
    NSMutableURLRequest *modifiedRequest = request.mutableCopy;
    AFNetworkReachabilityManager *reachability = self.reachabilityManager;
    if (!reachability.isReachable)
    {
        modifiedRequest.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    }
    return [super HTTPRequestOperationWithRequest:modifiedRequest
                                          success:success
                                          failure:failure];
}

@end

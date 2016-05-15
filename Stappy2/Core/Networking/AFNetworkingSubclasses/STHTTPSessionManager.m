//
//  STHTTPSessionManager.m
//  Stappy2
//
//  Created by Andrei Neag on 12/6/15.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STHTTPSessionManager.h"

@implementation STHTTPSessionManager

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSURLResponse *response,
                                                        id responseObject,
                                                        NSError *error))completionHandler
{
    NSMutableURLRequest *modifiedRequest = request.mutableCopy;
    AFNetworkReachabilityManager *reachability = self.reachabilityManager;
    if (!reachability.isReachable)
    {
        modifiedRequest.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    }
    return [super dataTaskWithRequest:modifiedRequest
                    completionHandler:completionHandler];
}

@end

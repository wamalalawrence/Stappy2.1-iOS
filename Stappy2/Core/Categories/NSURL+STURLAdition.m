//
//  NSURL+STURLAdition.m
//  Stappy2
//
//  Created by Cynthia Codrea on 19/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "NSURL+STURLAdition.h"

@implementation NSURL (STURLAdition)

-(NSString*)concatenateQuery:(NSDictionary*)parameters {
    if([parameters count]==0) return nil;
    NSMutableString* query = [NSMutableString string];
    for(NSString* parameter in [parameters allKeys])
        [query appendFormat:@"&%@=%@",[parameter stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet],[[parameters objectForKey:parameter] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
    return [[query substringFromIndex:1] copy];
}
-(NSDictionary*)splitQuery:(NSString*)query {
    if([query length]==0) return nil;
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    for(NSString* parameter in [query componentsSeparatedByString:@"&"]) {
        NSRange range = [parameter rangeOfString:@"="];
        if(range.location!=NSNotFound)
            [parameters setObject:[[parameter substringFromIndex:range.location+range.length] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:[[parameter substringToIndex:range.location] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        else [parameters setObject:[[NSString alloc] init] forKey:[parameter stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    return [parameters copy];
}

@end

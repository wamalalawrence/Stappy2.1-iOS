//
//  NSURL+STURLAdition.h
//  Stappy2
//
//  Created by Cynthia Codrea on 19/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (STURLAdition)

-(NSString*)concatenateQuery:(NSDictionary*)parameters;
-(NSDictionary*)splitQuery:(NSString*)query;

@end

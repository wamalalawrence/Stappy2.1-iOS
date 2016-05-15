//
//	STPeriod.m
//
//	Create by Pavel Nemecek on 11/5/2016
//	Copyright © 2016. All rights reserved.
//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "STPeriod.h"

NSString *const kSTPeriodClose = @"close";
NSString *const kSTPeriodOpen = @"open";

@interface STPeriod ()
@end
@implementation STPeriod




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kSTPeriodClose] isKindOfClass:[NSNull class]]){
		self.close = [[STClose alloc] initWithDictionary:dictionary[kSTPeriodClose]];
	}

	if(![dictionary[kSTPeriodOpen] isKindOfClass:[NSNull class]]){
		self.open = [[STClose alloc] initWithDictionary:dictionary[kSTPeriodOpen]];
	}

	return self;
}
@end
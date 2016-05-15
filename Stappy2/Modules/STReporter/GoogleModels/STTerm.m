//
//	STTerm.m
//
//	Create by Pavel Nemecek on 10/5/2016
//	Copyright © 2016. All rights reserved.
//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "STTerm.h"

NSString *const kSTTermOffset = @"offset";
NSString *const kSTTermValue = @"value";

@interface STTerm ()
@end
@implementation STTerm




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kSTTermOffset] isKindOfClass:[NSNull class]]){
		self.offset = [dictionary[kSTTermOffset] integerValue];
	}

	if(![dictionary[kSTTermValue] isKindOfClass:[NSNull class]]){
		self.value = dictionary[kSTTermValue];
	}	
	return self;
}
@end
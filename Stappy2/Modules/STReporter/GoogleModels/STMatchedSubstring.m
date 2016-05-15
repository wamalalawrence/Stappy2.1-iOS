//
//	STMatchedSubstring.m
//
//	Create by Pavel Nemecek on 10/5/2016
//	Copyright © 2016. All rights reserved.
//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "STMatchedSubstring.h"

NSString *const kSTMatchedSubstringLength = @"length";
NSString *const kSTMatchedSubstringOffset = @"offset";

@interface STMatchedSubstring ()
@end
@implementation STMatchedSubstring




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kSTMatchedSubstringLength] isKindOfClass:[NSNull class]]){
		self.length = [dictionary[kSTMatchedSubstringLength] integerValue];
	}

	if(![dictionary[kSTMatchedSubstringOffset] isKindOfClass:[NSNull class]]){
		self.offset = [dictionary[kSTMatchedSubstringOffset] integerValue];
	}

	return self;
}
@end
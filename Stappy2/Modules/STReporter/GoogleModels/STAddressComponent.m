//
//	STAddressComponent.m
//
//	Create by Pavel Nemecek on 11/5/2016
//	Copyright © 2016. All rights reserved.
//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "STAddressComponent.h"

NSString *const kSTAddressComponentLongName = @"long_name";
NSString *const kSTAddressComponentShortName = @"short_name";
NSString *const kSTAddressComponentTypes = @"types";

@interface STAddressComponent ()
@end
@implementation STAddressComponent




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kSTAddressComponentLongName] isKindOfClass:[NSNull class]]){
		self.longName = dictionary[kSTAddressComponentLongName];
	}	
	if(![dictionary[kSTAddressComponentShortName] isKindOfClass:[NSNull class]]){
		self.shortName = dictionary[kSTAddressComponentShortName];
	}	
	if(![dictionary[kSTAddressComponentTypes] isKindOfClass:[NSNull class]]){
		self.types = dictionary[kSTAddressComponentTypes];
	}	
	return self;
}
@end
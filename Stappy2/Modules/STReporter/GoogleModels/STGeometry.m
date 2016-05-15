//
//	STGeometry.m
//
//	Create by Pavel Nemecek on 11/5/2016
//	Copyright © 2016. All rights reserved.
//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "STGeometry.h"

NSString *const kSTGeometryLocation = @"location";

@interface STGeometry ()
@end
@implementation STGeometry




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kSTGeometryLocation] isKindOfClass:[NSNull class]]){
		self.location = [[STLocation alloc] initWithDictionary:dictionary[kSTGeometryLocation]];
	}

	return self;
}
@end
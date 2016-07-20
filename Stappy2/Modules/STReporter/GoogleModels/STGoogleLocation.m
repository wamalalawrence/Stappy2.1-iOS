//
//	STLocation.m
//
//	Create by Pavel Nemecek on 11/5/2016
//	Copyright © 2016. All rights reserved.
//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "STGoogleLocation.h"

NSString *const kSTLocationLat = @"lat";
NSString *const kSTLocationLng = @"lng";

@interface STGoogleLocation ()
@end
@implementation STGoogleLocation




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kSTLocationLat] isKindOfClass:[NSNull class]]){
		self.lat = [dictionary[kSTLocationLat] floatValue];
	}

	if(![dictionary[kSTLocationLng] isKindOfClass:[NSNull class]]){
		self.lng = [dictionary[kSTLocationLng] floatValue];
	}

	return self;
}
@end
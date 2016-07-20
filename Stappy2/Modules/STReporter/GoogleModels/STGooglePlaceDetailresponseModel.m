//
//	STGooglePlaceDetailresponseModel.m
//
//	Create by Pavel Nemecek on 11/5/2016
//	Copyright © 2016. All rights reserved.
//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "STGooglePlaceDetailresponseModel.h"

NSString *const kSTGooglePlaceDetailresponseModelHtmlAttributions = @"html_attributions";
NSString *const kSTGooglePlaceDetailresponseModelResult = @"result";
NSString *const kSTGooglePlaceDetailresponseModelStatus = @"status";

@interface STGooglePlaceDetailresponseModel ()
@end
@implementation STGooglePlaceDetailresponseModel




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];

	if(![dictionary[kSTGooglePlaceDetailresponseModelHtmlAttributions] isKindOfClass:[NSNull class]]){
		self.htmlAttributions = dictionary[kSTGooglePlaceDetailresponseModelHtmlAttributions];
	}	
	if(![dictionary[kSTGooglePlaceDetailresponseModelResult] isKindOfClass:[NSNull class]]){
		self.result = [[STResult alloc] initWithDictionary:dictionary[kSTGooglePlaceDetailresponseModelResult]];
	}

	if(![dictionary[kSTGooglePlaceDetailresponseModelStatus] isKindOfClass:[NSNull class]]){
		self.status = dictionary[kSTGooglePlaceDetailresponseModelStatus];
	}	
	return self;
}
@end
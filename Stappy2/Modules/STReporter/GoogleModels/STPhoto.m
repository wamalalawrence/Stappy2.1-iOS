//
//	STPhoto.m
//
//	Create by Pavel Nemecek on 11/5/2016
//	Copyright © 2016. All rights reserved.
//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "STPhoto.h"

NSString *const kSTPhotoHeight = @"height";
NSString *const kSTPhotoHtmlAttributions = @"html_attributions";
NSString *const kSTPhotoPhotoReference = @"photo_reference";
NSString *const kSTPhotoWidth = @"width";

@interface STPhoto ()
@end
@implementation STPhoto




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kSTPhotoHeight] isKindOfClass:[NSNull class]]){
		self.height = [dictionary[kSTPhotoHeight] integerValue];
	}

	if(![dictionary[kSTPhotoHtmlAttributions] isKindOfClass:[NSNull class]]){
		self.htmlAttributions = dictionary[kSTPhotoHtmlAttributions];
	}	
	if(![dictionary[kSTPhotoPhotoReference] isKindOfClass:[NSNull class]]){
		self.photoReference = dictionary[kSTPhotoPhotoReference];
	}	
	if(![dictionary[kSTPhotoWidth] isKindOfClass:[NSNull class]]){
		self.width = [dictionary[kSTPhotoWidth] integerValue];
	}

	return self;
}
@end
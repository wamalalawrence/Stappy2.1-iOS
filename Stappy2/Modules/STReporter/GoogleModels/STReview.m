//
//	STReview.m
//
//	Create by Pavel Nemecek on 11/5/2016
//	Copyright © 2016. All rights reserved.
//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "STReview.h"

NSString *const kSTReviewAspects = @"aspects";
NSString *const kSTReviewAuthorName = @"author_name";
NSString *const kSTReviewAuthorUrl = @"author_url";
NSString *const kSTReviewLanguage = @"language";
NSString *const kSTReviewRating = @"rating";
NSString *const kSTReviewText = @"text";
NSString *const kSTReviewTime = @"time";

@interface STReview ()
@end
@implementation STReview




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(dictionary[kSTReviewAspects] != nil && [dictionary[kSTReviewAspects] isKindOfClass:[NSArray class]]){
		NSArray * aspectsDictionaries = dictionary[kSTReviewAspects];
		NSMutableArray * aspectsItems = [NSMutableArray array];
		for(NSDictionary * aspectsDictionary in aspectsDictionaries){
			STAspect * aspectsItem = [[STAspect alloc] initWithDictionary:aspectsDictionary];
			[aspectsItems addObject:aspectsItem];
		}
		self.aspects = aspectsItems;
	}
	if(![dictionary[kSTReviewAuthorName] isKindOfClass:[NSNull class]]){
		self.authorName = dictionary[kSTReviewAuthorName];
	}	
	if(![dictionary[kSTReviewAuthorUrl] isKindOfClass:[NSNull class]]){
		self.authorUrl = dictionary[kSTReviewAuthorUrl];
	}	
	if(![dictionary[kSTReviewLanguage] isKindOfClass:[NSNull class]]){
		self.language = dictionary[kSTReviewLanguage];
	}	
	if(![dictionary[kSTReviewRating] isKindOfClass:[NSNull class]]){
		self.rating = [dictionary[kSTReviewRating] integerValue];
	}

	if(![dictionary[kSTReviewText] isKindOfClass:[NSNull class]]){
		self.text = dictionary[kSTReviewText];
	}	
	if(![dictionary[kSTReviewTime] isKindOfClass:[NSNull class]]){
		self.time = [dictionary[kSTReviewTime] integerValue];
	}

	return self;
}
@end
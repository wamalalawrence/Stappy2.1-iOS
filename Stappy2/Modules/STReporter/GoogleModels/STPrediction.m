//
//	STPrediction.m
//
//	Create by Pavel Nemecek on 10/5/2016
//	Copyright © 2016. All rights reserved.
//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "STPrediction.h"

NSString *const kSTPredictionDescriptionField = @"description";
NSString *const kSTPredictionIdField = @"id";
NSString *const kSTPredictionMatchedSubstrings = @"matched_substrings";
NSString *const kSTPredictionPlaceId = @"place_id";
NSString *const kSTPredictionReference = @"reference";
NSString *const kSTPredictionTerms = @"terms";
NSString *const kSTPredictionTypes = @"types";

@interface STPrediction ()
@end
@implementation STPrediction




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kSTPredictionDescriptionField] isKindOfClass:[NSNull class]]){
		self.descriptionField = dictionary[kSTPredictionDescriptionField];
	}	
	if(![dictionary[kSTPredictionIdField] isKindOfClass:[NSNull class]]){
		self.idField = dictionary[kSTPredictionIdField];
	}	
	if(dictionary[kSTPredictionMatchedSubstrings] != nil && [dictionary[kSTPredictionMatchedSubstrings] isKindOfClass:[NSArray class]]){
		NSArray * matchedSubstringsDictionaries = dictionary[kSTPredictionMatchedSubstrings];
		NSMutableArray * matchedSubstringsItems = [NSMutableArray array];
		for(NSDictionary * matchedSubstringsDictionary in matchedSubstringsDictionaries){
			STMatchedSubstring * matchedSubstringsItem = [[STMatchedSubstring alloc] initWithDictionary:matchedSubstringsDictionary];
			[matchedSubstringsItems addObject:matchedSubstringsItem];
		}
		self.matchedSubstrings = matchedSubstringsItems;
	}
	if(![dictionary[kSTPredictionPlaceId] isKindOfClass:[NSNull class]]){
		self.placeId = dictionary[kSTPredictionPlaceId];
	}	
	if(![dictionary[kSTPredictionReference] isKindOfClass:[NSNull class]]){
		self.reference = dictionary[kSTPredictionReference];
	}	
	if(dictionary[kSTPredictionTerms] != nil && [dictionary[kSTPredictionTerms] isKindOfClass:[NSArray class]]){
		NSArray * termsDictionaries = dictionary[kSTPredictionTerms];
		NSMutableArray * termsItems = [NSMutableArray array];
		for(NSDictionary * termsDictionary in termsDictionaries){
			STTerm * termsItem = [[STTerm alloc] initWithDictionary:termsDictionary];
			[termsItems addObject:termsItem];
		}
		self.terms = termsItems;
	}
	if(![dictionary[kSTPredictionTypes] isKindOfClass:[NSNull class]]){
		self.types = dictionary[kSTPredictionTypes];
	}	
	return self;
}
@end
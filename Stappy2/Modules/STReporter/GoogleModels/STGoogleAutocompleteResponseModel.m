//
//	STGoogleAutocompleteResponseModel.m
//
//	Create by Pavel Nemecek on 10/5/2016
//	Copyright © 2016. All rights reserved.
//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "STGoogleAutocompleteResponseModel.h"

NSString *const kSTGoogleAutocompleteResponseModelPredictions = @"predictions";
NSString *const kSTGoogleAutocompleteResponseModelStatus = @"status";

@interface STGoogleAutocompleteResponseModel ()
@end
@implementation STGoogleAutocompleteResponseModel




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(dictionary[kSTGoogleAutocompleteResponseModelPredictions] != nil && [dictionary[kSTGoogleAutocompleteResponseModelPredictions] isKindOfClass:[NSArray class]]){
		NSArray * predictionsDictionaries = dictionary[kSTGoogleAutocompleteResponseModelPredictions];
		NSMutableArray * predictionsItems = [NSMutableArray array];
		for(NSDictionary * predictionsDictionary in predictionsDictionaries){
			STPrediction * predictionsItem = [[STPrediction alloc] initWithDictionary:predictionsDictionary];
			[predictionsItems addObject:predictionsItem];
		}
		self.predictions = predictionsItems;
	}
	if(![dictionary[kSTGoogleAutocompleteResponseModelStatus] isKindOfClass:[NSNull class]]){
		self.status = dictionary[kSTGoogleAutocompleteResponseModelStatus];
	}	
	return self;
}
@end
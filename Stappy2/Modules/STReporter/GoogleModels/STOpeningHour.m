//
//	STOpeningHour.m
//
//	Create by Pavel Nemecek on 11/5/2016
//	Copyright © 2016. All rights reserved.
//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "STOpeningHour.h"

NSString *const kSTOpeningHourOpenNow = @"open_now";
NSString *const kSTOpeningHourPeriods = @"periods";
NSString *const kSTOpeningHourWeekdayText = @"weekday_text";

@interface STOpeningHour ()
@end
@implementation STOpeningHour




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kSTOpeningHourOpenNow] isKindOfClass:[NSNull class]]){
		self.openNow = [dictionary[kSTOpeningHourOpenNow] boolValue];
	}

	if(dictionary[kSTOpeningHourPeriods] != nil && [dictionary[kSTOpeningHourPeriods] isKindOfClass:[NSArray class]]){
		NSArray * periodsDictionaries = dictionary[kSTOpeningHourPeriods];
		NSMutableArray * periodsItems = [NSMutableArray array];
		for(NSDictionary * periodsDictionary in periodsDictionaries){
			STPeriod * periodsItem = [[STPeriod alloc] initWithDictionary:periodsDictionary];
			[periodsItems addObject:periodsItem];
		}
		self.periods = periodsItems;
	}
	if(![dictionary[kSTOpeningHourWeekdayText] isKindOfClass:[NSNull class]]){
		self.weekdayText = dictionary[kSTOpeningHourWeekdayText];
	}	
	return self;
}
@end
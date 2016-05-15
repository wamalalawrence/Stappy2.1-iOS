//
//	STOpeningHour.h
//
//	Create by Pavel Nemecek on 11/5/2016
//	Copyright © 2016. All rights reserved.
//

//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

#import <UIKit/UIKit.h>
#import "STPeriod.h"

@interface STOpeningHour : NSObject

@property (nonatomic, assign) BOOL openNow;
@property (nonatomic, strong) NSArray * periods;
@property (nonatomic, strong) NSArray * weekdayText;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
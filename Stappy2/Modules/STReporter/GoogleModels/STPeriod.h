//
//	STPeriod.h
//
//	Create by Pavel Nemecek on 11/5/2016
//	Copyright © 2016. All rights reserved.
//

//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

#import <UIKit/UIKit.h>
#import "STClose.h"

@interface STPeriod : NSObject

@property (nonatomic, strong) STClose * close;
@property (nonatomic, strong) STClose * open;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
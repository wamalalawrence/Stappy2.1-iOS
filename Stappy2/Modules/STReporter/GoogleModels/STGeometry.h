//
//	STGeometry.h
//
//	Create by Pavel Nemecek on 11/5/2016
//	Copyright © 2016. All rights reserved.
//

//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

#import <UIKit/UIKit.h>
#import "STLocation.h"

@interface STGeometry : NSObject

@property (nonatomic, strong) STLocation * location;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
//
//	STGoogleAutocompleteResponseModel.h
//
//	Create by Pavel Nemecek on 10/5/2016
//	Copyright © 2016. All rights reserved.
//

//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

#import <UIKit/UIKit.h>
#import "STPrediction.h"

@interface STGoogleAutocompleteResponseModel : NSObject

@property (nonatomic, strong) NSArray * predictions;
@property (nonatomic, strong) NSString * status;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
//
//	STGooglePlaceDetailresponseModel.h
//
//	Create by Pavel Nemecek on 11/5/2016
//	Copyright © 2016. All rights reserved.
//

//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

#import <UIKit/UIKit.h>
#import "STResult.h"

@interface STGooglePlaceDetailresponseModel : NSObject

@property (nonatomic, strong) NSArray * htmlAttributions;
@property (nonatomic, strong) STResult * result;
@property (nonatomic, strong) NSString * status;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
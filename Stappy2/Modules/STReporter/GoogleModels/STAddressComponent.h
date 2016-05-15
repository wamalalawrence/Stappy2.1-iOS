//
//	STAddressComponent.h
//
//	Create by Pavel Nemecek on 11/5/2016
//	Copyright © 2016. All rights reserved.
//

//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

#import <UIKit/UIKit.h>

@interface STAddressComponent : NSObject

@property (nonatomic, strong) NSString * longName;
@property (nonatomic, strong) NSString * shortName;
@property (nonatomic, strong) NSArray * types;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
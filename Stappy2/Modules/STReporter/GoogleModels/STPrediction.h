//
//	STPrediction.h
//
//	Create by Pavel Nemecek on 10/5/2016
//	Copyright © 2016. All rights reserved.
//

//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

#import <UIKit/UIKit.h>
#import "STMatchedSubstring.h"
#import "STTerm.h"

@interface STPrediction : NSObject

@property (nonatomic, strong) NSString * descriptionField;
@property (nonatomic, strong) NSString * idField;
@property (nonatomic, strong) NSArray * matchedSubstrings;
@property (nonatomic, strong) NSString * placeId;
@property (nonatomic, strong) NSString * reference;
@property (nonatomic, strong) NSArray * terms;
@property (nonatomic, strong) NSArray * types;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
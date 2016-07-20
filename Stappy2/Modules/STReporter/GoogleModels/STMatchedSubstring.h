//
//	STMatchedSubstring.h
//
//	Create by Pavel Nemecek on 10/5/2016
//	Copyright © 2016. All rights reserved.
//

//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

#import <UIKit/UIKit.h>

@interface STMatchedSubstring : NSObject

@property (nonatomic, assign) NSInteger length;
@property (nonatomic, assign) NSInteger offset;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
//
//	STPhoto.h
//
//	Create by Pavel Nemecek on 11/5/2016
//	Copyright © 2016. All rights reserved.
//

//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

#import <UIKit/UIKit.h>

@interface STPhoto : NSObject

@property (nonatomic, assign) NSInteger height;
@property (nonatomic, strong) NSArray * htmlAttributions;
@property (nonatomic, strong) NSString * photoReference;
@property (nonatomic, assign) NSInteger width;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
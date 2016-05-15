//
//	STReview.h
//
//	Create by Pavel Nemecek on 11/5/2016
//	Copyright © 2016. All rights reserved.
//

//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

#import <UIKit/UIKit.h>
#import "STAspect.h"

@interface STReview : NSObject

@property (nonatomic, strong) NSArray * aspects;
@property (nonatomic, strong) NSString * authorName;
@property (nonatomic, strong) NSString * authorUrl;
@property (nonatomic, strong) NSString * language;
@property (nonatomic, assign) NSInteger rating;
@property (nonatomic, strong) NSString * text;
@property (nonatomic, assign) NSInteger time;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
//
//	STLocation.h
//
//	Create by Pavel Nemecek on 11/5/2016
//	Copyright © 2016. All rights reserved.
//

//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

#import <UIKit/UIKit.h>

@interface STGoogleLocation : NSObject

@property (nonatomic, assign) CGFloat lat;
@property (nonatomic, assign) CGFloat lng;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
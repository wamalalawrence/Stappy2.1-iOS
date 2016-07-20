//
//	STRightMenuItemsModel.h
//
//	Create by Pavel Nemecek on 9/6/2016
//	Copyright © 2016. All rights reserved.
//

//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

#import <UIKit/UIKit.h>
#import <Mantle/Mantle.h>

@interface STRightMenuItemsModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSArray * children;
@property (nonatomic, strong) NSString *creationdate;
@property (nonatomic, assign) NSInteger modelId;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSString * detailsUrl;
@property (nonatomic, assign) NSInteger stadtInfosId;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
//
//	STRightMenuItemsModel.m
//
//	Create by Pavel Nemecek on 9/6/2016
//	Copyright © 2016. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "STRightMenuItemsModel.h"

NSString *const kSTRightMenuItemsModelChildren = @"children";
NSString *const kSTRightMenuItemsModelCreationdate = @"creationdate";
NSString *const kSTRightMenuItemsModelIdField = @"id";
NSString *const kSTRightMenuItemsModelTitle = @"title";
NSString *const kSTRightMenuItemsModelType = @"type";
NSString *const kSTRightMenuItemsModelUrl = @"url";
NSString *const kSTRightMenuItemsModelStadtInfosId= @"stadtInfosId";

@interface STRightMenuItemsModel ()
@end
@implementation STRightMenuItemsModel


+(NSDictionary*)JSONKeyPathsByPropertyKey {
    
    return @{
             @"title":@"title",
             @"children":@"children",
             @"type":@"type",
             @"detailsUrl":@"url",
             @"modelId":@"id",
             @"type":@"type",
             @"modelId":@"id"
             };
}


/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![[dictionary objectForKey:kSTRightMenuItemsModelChildren] isKindOfClass:[NSNull class]]){
		self.children = dictionary[kSTRightMenuItemsModelChildren];
	}	
	if(![dictionary[kSTRightMenuItemsModelCreationdate] isKindOfClass:[NSNull class]]){
		self.creationdate = dictionary[kSTRightMenuItemsModelCreationdate];
	}	
	if(![dictionary[kSTRightMenuItemsModelIdField] isKindOfClass:[NSNull class]]){
		self.modelId = [dictionary[kSTRightMenuItemsModelIdField] integerValue];
	}

	if(![dictionary[kSTRightMenuItemsModelTitle] isKindOfClass:[NSNull class]]){
		self.title = dictionary[kSTRightMenuItemsModelTitle];
	}	
	if(![dictionary[kSTRightMenuItemsModelType] isKindOfClass:[NSNull class]]){
		self.type = dictionary[kSTRightMenuItemsModelType];
	}	
	if(![dictionary[kSTRightMenuItemsModelUrl] isKindOfClass:[NSNull class]]){
		self.detailsUrl = dictionary[kSTRightMenuItemsModelUrl];
	}
    if(![dictionary[kSTRightMenuItemsModelStadtInfosId] isKindOfClass:[NSNull class]]){
        self.stadtInfosId = [dictionary[kSTRightMenuItemsModelStadtInfosId] integerValue];
    }
	return self;
}
@end
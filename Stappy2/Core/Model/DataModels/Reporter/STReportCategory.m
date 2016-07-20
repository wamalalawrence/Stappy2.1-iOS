//
//  STReportCategory.m
//  Stappy2
//
//  Created by Pavel Nemecek on 10/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STReportCategory.h"
#import "STAppSettingsManager.h"
@implementation STReportCategory

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"reportCategoryId": @"id",
              @"types": @"types",
              @"name": @"name"
                      };
}

+(NSValueTransformer *)typesJSONTransformer __unused {
    
    return [MTLValueTransformer transformerWithBlock:^id(id types) {
        if ( [types isKindOfClass:[NSArray class]] ) {
            return [[MTLValueTransformer mtl_JSONArrayTransformerWithModelClass:[STReportType class]] transformedValue:types];
        }
          return nil;
    }];
    
}

+(NSArray*)allCategories{

    NSError *mtlError = nil;
    NSArray *categories = [MTLJSONAdapter modelsOfClass:[STReportCategory class]
                                        fromJSONArray:[STAppSettingsManager sharedSettingsManager].reportCategories
                                                error:&mtlError];

    if (!mtlError) {
        return categories;
    }
    else{
        return nil;
    }

}

@end

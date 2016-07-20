//
//  STViewControllerItem.h
//  Schwedt
//
//  Created by Andrej Albrecht on 10.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STViewControllerNavigationBarStyle;

@interface STViewControllerItem : NSObject

@property(nonatomic,strong) NSString *key;
@property(nonatomic,strong) NSString *storyboard_id;
@property(nonatomic,strong) NSString *nibname;
@property(nonatomic,strong) NSString *url;
@property(nonatomic,strong) STViewControllerNavigationBarStyle *navigationBarStyle;

/*
//Example:
"key": "Events",
"storyboard_id": "events",
"nibname":"",
"navigationbar":{
    "barTintColor": "clearColor",
    "tintColor": "whiteColor",
    "translucent": true,
    "barStyle": "UIBarStyleBlackTranslucent"
}
*/
@end

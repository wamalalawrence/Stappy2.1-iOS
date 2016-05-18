//
//  STAppSettingsManager.h
//  Stappy2
//
//  Created by Cynthia Codrea on 19/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import CoreLocation;

@interface STAppSettingsManager : NSObject

@property(nonatomic,strong)NSString* baseUrl;
@property(nonatomic,strong)NSString* userName;
@property(nonatomic,strong)NSString* password;
@property(nonatomic,strong)NSString* zahlerstandEmail;
@property(nonatomic,strong)NSString* reportingEmail;
@property(nonatomic,strong)NSString* basePartnerUrl;
@property(nonatomic,strong)NSString* baseSettingsUrl;
@property(nonatomic,strong)NSString* rightItemsUrl;
@property(nonatomic,strong)NSString* homeScreenTitle;
@property(nonatomic,strong)NSString* rightMenuTitle;


@property(nonatomic,strong)NSDictionary* configurationDictionary;
@property(nonatomic,strong)NSDictionary* startScreenOtherNamings;
@property(nonatomic,strong)NSDictionary* leftMenuItemsDictionary;
@property(nonatomic,strong)NSArray* leftMenuItems;
@property(nonatomic,strong)NSArray* settingsMenuItems;
@property(nonatomic,strong)NSArray* rightMenuItems;
@property(nonatomic,strong)NSArray* werbungItems;
@property(nonatomic,strong)NSDictionary* startScreenScrollActions;
@property(nonatomic,strong)NSArray* startScreenIgnoreActions;
@property(nonatomic,strong)NSDictionary* startScreenBottomActions;
@property(nonatomic,strong)NSDictionary* customizationsDict;
@property(nonatomic,strong)NSDictionary* detailScreenSharingOptions;
@property(nonatomic,strong)NSDictionary* viewControllerItems;
@property (nonatomic, strong, readonly) NSDictionary *defaultFilters;
@property (nonatomic, strong, readonly) NSArray *allIdsAreOnPerDefaultInViewControllers;
@property (nonatomic, strong, readonly) NSDictionary *overlayScreens;
@property (nonatomic, readonly) CLLocationCoordinate2D cityLocation;
@property (nonatomic, strong, readonly) NSNumber *rightMenuItemsId;
@property (nonatomic, strong)NSString* pushUrl;
@property(nonatomic,strong)NSString* rightMenuHeaderImage;
@property(nonatomic,strong)NSString* rightMenuBackgroundColor;
@property(nonatomic,strong)NSArray* reportCategories;

+ (STAppSettingsManager*)sharedSettingsManager;

- (UIColor*)customColorForKey:(NSString*)key;
- (UIFont *)customFontForKey:(NSString*)key;
- (void)setCustomFontForKey:(NSString*)key toView:(UIView *)view;
- (NSString*)backendValueForKey:(NSString*)keyPath;
- (BOOL)shouldHideNameAndAddressInDetailsScreen;
- (BOOL)shouldUseUserPositionInApotheken;

- (BOOL)shouldDisplayRegionPicker;
- (BOOL)showCoupons;
- (NSString*)activeCoupon;

- (NSString*)parkingKeyForId:(NSString*)Id;
- (NSString*)couponsSettingsTitle;

@end

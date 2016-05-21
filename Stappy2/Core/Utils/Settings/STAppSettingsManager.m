//
//  STAppSettingsManager.m
//  Stappy2
//
//  Created by Cynthia Codrea on 19/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STAppSettingsManager.h"
#import "STLeftMenuSettingsModel.h"
#import "STRightMenuItemsModel.h"
#import <Mantle/Mantle.h>
#import "STViewControllerItem.h"
#import "STViewControllerNavigationBarStyle.h"
#import "UIColor+Hexadecimal.h"
#import "Defines.h"

@interface STAppSettingsManager()
@property (nonatomic, strong) NSDictionary *defaultFilters;
@property (nonatomic, strong) NSArray *allIdsAreOnPerDefaultInViewControllers;
@property (nonatomic, strong) NSDictionary *overlayScreens;
@end

@implementation STAppSettingsManager

+(STAppSettingsManager*)sharedSettingsManager {
    static STAppSettingsManager* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(NSString *)userName {
    if (_userName == nil) {
        //get base url from configuration file
        _userName = [self.configurationDictionary objectForKey:@"backend"][@"userName"];
    }
    return _userName;
}

-(NSString *)password {
    if (_password == nil) {
        //get base url from configuration file
        _password = [self.configurationDictionary objectForKey:@"backend"][@"password"];
    }
    return _password;
}

-(NSString *)pushUrl {
    if (_pushUrl == nil) {
        //get base url from configuration file
        _pushUrl = [self.configurationDictionary objectForKey:@"backend"][@"pushUrl"];
    }
    return _pushUrl;
}

-(NSString *)zahlerstandEmail {
    if (_zahlerstandEmail == nil) {
        //get base _zahlerstandEmail from configuration file
        _zahlerstandEmail = [self.configurationDictionary objectForKey:@"backend"][@"zahlerstandEmail"];
    }
    return _zahlerstandEmail;
}

-(NSString *)reportingEmail {
    if (_reportingEmail == nil) {
        //get base _zahlerstandEmail from configuration file
        _reportingEmail = [self.configurationDictionary objectForKey:@"backend"][@"reportingEmail"];
    }
    return _reportingEmail;
}

-(NSString *)baseUrl {
    if (_baseUrl == nil) {
        //get base url from configuration file
        _baseUrl = [self.configurationDictionary objectForKey:@"backend"][@"baseUrl"];
    }
    return _baseUrl;
}

-(NSString *)rightMenuHeaderImage {
    if (_rightMenuHeaderImage == nil) {
        //get base url from configuration file
        _rightMenuHeaderImage = [[self.configurationDictionary objectForKey:@"backend"] objectForKey:@"rightMenuHeaderImage"];
    }
    return _rightMenuHeaderImage;
}


-(NSString *)rightMenuBackgroundColor {
    if (_rightMenuBackgroundColor == nil) {
        //get base url from configuration file
        _rightMenuBackgroundColor = [[self.configurationDictionary objectForKey:@"backend"] objectForKey:@"rightMenuBackgroundColor"];

    }
    return _rightMenuBackgroundColor;
}



-(NSString *)basePartnerUrl {
    if (_basePartnerUrl == nil) {
        //get basePartnerUrl from configuration file
        _basePartnerUrl = [self.configurationDictionary objectForKey:@"backend"][@"basePartnerUrl"];
    }
    return _basePartnerUrl;
}

-(NSString *)baseSettingsUrl {
    if (_baseSettingsUrl == nil) {
        //get baseSettingsUrl from configuration file
        _baseSettingsUrl = [self.configurationDictionary objectForKey:@"backend"][@"settingsUrlString"];
    }
    return _baseSettingsUrl;
}

-(NSString*)rightItemsUrl {
    if (_rightItemsUrl == nil) {
        // get right menu items url from configuration file
        _rightItemsUrl = [self.configurationDictionary objectForKey:@"backend"][@"rightMenuItemsUrl"];
    }
    return _rightItemsUrl;
}

-(NSString*)rightMenuTitle {
    if (_rightMenuTitle == nil) {
        // get right menu items url from configuration file
        _rightMenuTitle = [self.configurationDictionary objectForKey:@"backend"][@"rightMenuTitle"];
    }
    return _rightMenuTitle;
}

-(NSString*)homeScreenTitle {
    if (_homeScreenTitle == nil) {
        // get home screen title from configuration file
        _homeScreenTitle = [self.configurationDictionary objectForKey:@"backend"][kFirstPageTitleStringKey];
    }
    return _homeScreenTitle;
}

-(NSArray *)settingsMenuItems {
    if (_settingsMenuItems == nil) {
        NSError* mtlError = nil;
        _settingsMenuItems =  [MTLJSONAdapter modelsOfClass:[STLeftMenuSettingsModel class]
                                    fromJSONArray:[self.configurationDictionary objectForKey:@"menu_settings"]
                                                  error:&mtlError];
    }
    return _settingsMenuItems;
}

-(NSArray *)leftMenuItems {
    if (_leftMenuItems == nil) {
        NSError* mtlError = nil;
        _leftMenuItems =  [MTLJSONAdapter modelsOfClass:[STLeftMenuSettingsModel class]
                                          fromJSONArray:[self.configurationDictionary objectForKey:@"menu_left"]
                                                  error:&mtlError];
    }
    return _leftMenuItems;
}

-(NSArray *)startScreenIgnoreActions {
    if (_startScreenIgnoreActions == nil) {
        _startScreenIgnoreActions = [self.configurationDictionary objectForKey:@"startScreenIgnoredItems"];
    }
    return _startScreenIgnoreActions;
}

-(NSDictionary *)startScreenOtherNamings {
    if (_startScreenOtherNamings == nil) {
        _startScreenOtherNamings = [self.configurationDictionary objectForKey:@"startScreenOtherNamings"];
    }
    return _startScreenOtherNamings;
}

-(NSDictionary *)startScreenScrollActions {
    if (_startScreenScrollActions == nil) {
        _startScreenScrollActions = [self.configurationDictionary objectForKey:@"startScreenScrollActions"];
    }
    return _startScreenScrollActions;
}

-(NSDictionary *)startScreenBottomActions {
    if (_startScreenBottomActions == nil) {
        _startScreenBottomActions = [self.configurationDictionary objectForKey:@"startScreenBottomActions"];
    }
    return _startScreenBottomActions;
}

- (NSArray *)allIdsAreOnPerDefaultInViewControllers
{
    if (_allIdsAreOnPerDefaultInViewControllers == nil)
        _allIdsAreOnPerDefaultInViewControllers = [self.configurationDictionary objectForKey:@"allIdsAreOnPerDefaultInViewControllers"];
    
    return _allIdsAreOnPerDefaultInViewControllers;
}


- (NSArray *)reportCategories
{
    if (_reportCategories == nil)
        _reportCategories = [self.configurationDictionary objectForKey:@"reportCategories"];
    
    return _reportCategories;
}


- (NSDictionary *)defaultFilters {
    if (_defaultFilters == nil) {
        _defaultFilters = [self.configurationDictionary objectForKey:@"default_ids"];
    }
    return _defaultFilters;
}

- (NSDictionary *)overlayScreens
{
    if (_overlayScreens == nil)
        _overlayScreens = [self.configurationDictionary objectForKey:@"overlayScreens"];

    return _overlayScreens;
}



-(NSDictionary*)customizationsDict {
    if (_customizationsDict == nil) {
        _customizationsDict = [self.configurationDictionary objectForKey:@"customizations"];
    }
    return _customizationsDict;
}

-(NSDictionary*)detailScreenSharingOptions {
    if (_detailScreenSharingOptions == nil) {
        _detailScreenSharingOptions = [self.configurationDictionary objectForKey:@"detail_sharing_options"];
    }
    return _detailScreenSharingOptions;
}

- (CLLocationCoordinate2D)cityLocation
{
    CLLocationDegrees latitude  = [[self.configurationDictionary valueForKeyPath:@"cityLocation.latitude"] doubleValue];
    CLLocationDegrees longitude = [[self.configurationDictionary valueForKeyPath:@"cityLocation.longitude"] doubleValue];
    return CLLocationCoordinate2DMake(latitude, longitude);
}

-(NSDictionary *)viewControllerItems {
    if (_viewControllerItems == nil) {
        NSError* mtlError = nil;
        NSString* path = [[NSBundle mainBundle] pathForResource:@"storyboard_ids" ofType:@"json"];
        NSData* data = [NSData dataWithContentsOfFile:path];
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&mtlError];
        NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
        if (mtlError == nil) {
            NSArray *array = [dict objectForKey:@"content"];
            for (int i=0; i < [array count];i++) {
                NSDictionary *itemDict = [array objectAtIndex:i];
                NSString *key = [itemDict objectForKey:@"key"];
                NSString *storyboard_id = [itemDict objectForKey:@"storyboard_id"];
                NSString *nibname = [itemDict objectForKey:@"nibname"];
                NSDictionary *navigationbar = [itemDict objectForKey:@"navigationbar"];
                NSString *webUrl = [itemDict objectForKey:@"website"];
                
                STViewControllerNavigationBarStyle *navBarStyle = [[STViewControllerNavigationBarStyle alloc] init];
                navBarStyle.barTintColor = [UIColor clearColor];
                navBarStyle.tintColor = [UIColor whiteColor];
                navBarStyle.translucent = YES;
                navBarStyle.barStyle = UIBarStyleBlackTranslucent;
                
                NSString *barTintColorString = [navigationbar objectForKey:@"barTintColor"];
                float barTintColorAlpha = [[navigationbar objectForKey:@"barTintColor_alpha"] floatValue];
                NSString *tintColorString = [navigationbar objectForKey:@"tintColor"];
                float tintColorAlpha = [[navigationbar objectForKey:@"tintColor_alpha"] floatValue];
                
                BOOL translucentBool = [[navigationbar objectForKey:@"translucent"] boolValue];
                int barStyleInt = [[navigationbar objectForKey:@"barStyle"] intValue];
                
                if (barTintColorString && ![barTintColorString isEqualToString:@""]) {
                    navBarStyle.barTintColor = [UIColor colorWithHexString:barTintColorString andAlpha:barTintColorAlpha];
                }
                if (tintColorString && ![tintColorString isEqualToString:@""]) {
                    navBarStyle.tintColor = [UIColor colorWithHexString:tintColorString andAlpha:tintColorAlpha];
                }
                
                navBarStyle.translucent = translucentBool;
                
                if (barStyleInt) {
                    navBarStyle.barStyle = barStyleInt;
                }
                
                STViewControllerItem *item = [[STViewControllerItem alloc] init];
                item.key = key;
                item.storyboard_id = storyboard_id;
                item.nibname = nibname;
                item.navigationBarStyle = navBarStyle;
                item.url = webUrl;
                
                [mutableDict setObject:item forKey:key];
            }
            
            
            _viewControllerItems = mutableDict;
        }
    }
    return _viewControllerItems;
}

-(UIColor*)customColorForKey:(NSString*)key
{
    NSString *colorValue = [self.customizationsDict valueForKeyPath:[NSString stringWithFormat:@"%@.value", key]];
    float colorAlpha = [[self.customizationsDict  valueForKeyPath:[NSString stringWithFormat:@"%@.alpha", key]] floatValue];
    
    return [UIColor colorWithHexString:colorValue andAlpha:colorAlpha];
}

- (void)setCustomFontForKey:(NSString*)key toView:(UIView *)view
{
    UIFont *font = [self customFontForKey:key];
    if (font)
    {
        if ([view respondsToSelector:@selector(setFont:)])
            [((id)view) setFont:font];
    }
}

-(UIFont *)customFontForKey:(NSString*)key
{
    NSString *fontNameValue = [self.customizationsDict valueForKeyPath:[NSString stringWithFormat:@"%@.name", key]];
    NSString *fontSizeValue = [self.customizationsDict valueForKeyPath:[NSString stringWithFormat:@"%@.size", key]];
    
    if (!fontNameValue || !fontSizeValue || [fontNameValue isEqualToString:@""] || [fontSizeValue isEqualToString:@""]) {
        return nil;
    }
    
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterNoStyle];
    NSNumber *fontSizeNumber = [nf numberFromString:fontSizeValue];
    CGFloat fontSizeFloat = [fontSizeNumber floatValue];
    
    if (fontSizeFloat==0) {
        return nil;
    }
    UIFont *font = [UIFont fontWithName:fontNameValue size:fontSizeFloat];
    return font;
}

- (BOOL)shouldDisplayRegionPicker {
    NSString * shouldShow = [self.configurationDictionary objectForKey:kShouldShowDisplayRegionPicker];
    return [shouldShow isEqualToString:@"YES"];
}

- (NSDictionary *)regionPickerSettingsItem { return [self.configurationDictionary objectForKey:@"regionPickerSettingsItem"]; }

- (BOOL)shouldUseUserPositionInApotheken{
    
    if ([self.configurationDictionary objectForKey:@"shouldUseUserPositionInApotheken"]) {
        int shouldShow = [[self.configurationDictionary objectForKey:@"shouldUseUserPositionInApotheken"] intValue];
        return shouldShow == 1;
    }
    
    else{
        return NO;
    }
}


#pragma mark - Coupons

-(NSString*)backendValueForKey:(NSString*)keyPath
{
    return [[self.configurationDictionary objectForKey:@"backend"] valueForKeyPath:keyPath];
}

- (NSString*)parkingKeyForId:(NSString*)Id{
    NSDictionary*dict = [[self.configurationDictionary objectForKey:@"backend"] objectForKey:@"parkingMap"];
    return [dict valueForKey:Id];

}

- (NSNumber *)rightMenuItemsId { return [self.configurationDictionary valueForKeyPath:@"backend.rightMenuItemsId"]; };

- (BOOL)shouldHideNameAndAddressInDetailsScreen {
    NSString * shouldShow = [self.configurationDictionary objectForKey:kShouldShowAddressAndNameFields];
    return [shouldShow isEqualToString:@"NO"];
}


- (BOOL)showCoupons {
    NSString * showCoupons = [self.configurationDictionary objectForKey:kShowCoupons];
    return [showCoupons isEqualToString:@"YES"];
}

- (BOOL)showCityName {
    NSString * showCityName = [self.configurationDictionary objectForKey:@"shouldShowCityName"];
    
    BOOL returnBool = YES;
    if (showCityName && [showCityName isEqualToString:@"NO"]) {
        returnBool= NO;
    }
    
    return returnBool;
}

- (NSString*)couponsSettingsTitle {
    NSString * settingsCouponsTitle = [self.configurationDictionary objectForKey:kSettingsCouponTitle];
    return settingsCouponsTitle;
}

- (NSString*)activeCoupon {
    NSString * couponCode = [[NSUserDefaults standardUserDefaults] objectForKey:kActiveCouponCode];
    return couponCode;
}

@end

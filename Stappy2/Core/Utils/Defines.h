//
//  Defines.h
//  Schwedt
//
//  Created by Andrei Neag on 31.01.2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Defines : NSObject

extern NSString *const kEmptyString;

//Settings Constants
extern NSString *const kApiStringKey;
extern NSString *const kCaptionStringKey;
extern NSString *const kIdStringKey;
extern NSString *const kIconNameStringKey;
extern NSString *const kTypeStringKey;
extern NSString *const kTitleStringKey;
extern NSString *const kTypeApiStringKey;
extern NSString *const kUrlStringKey;
extern NSString *const kBaseUrlStringKey;
extern NSString *const kDepartureTimeUrlStringKey;
extern NSString *const kAutorizationHeaderStringKey;
extern NSString *const kBackendStringKey;
extern NSString *const kDefaulLocationStringKey;
extern NSString *const kApoUrlStringKey;
extern NSString *const kSub_ItemsStringKey;
extern NSString *const kElementSelectedString;
extern NSString *const kNameString;
extern NSString *const kSubitemsStringKey;
extern NSString *const kChildrenStringKey;
extern NSString *const kSelectedStringKey;
extern NSString *const kAllChildrenSelectedStringKey;
extern NSString *const kBackStringKey;
extern NSString *const kFirstPageTitleStringKey;
extern NSString *const kShouldShowAddressAndNameFields;
extern NSString *const kShowCoupons;
extern NSString *const kActiveCouponCode;
extern NSString *const kCouponScreenShown;
extern NSString *const kShouldShowDisplayRegionPicker;
extern NSString *const kSettingsCouponTitle;

// CellIdentifier Constants
extern NSString *const kActionOptionsCellIdentifier;
extern NSString *const kSettingsSelectionsTableViewCellIdentifier;
extern NSString *const kSettingsSelectionsTopTableViewCellIdentifier;
extern NSString *const kSearchAndFavoritesTableViewCell;
extern NSString *const kSearchTopTableViewCell;

// Local Data storage constants
extern NSString *const kFavoriteAngeboteListName;
extern NSString *const kFavoriteEventsListName;
extern NSString *const kSavedSettingsListName;
extern NSString *const kFavoriteStadtInfosListName;
extern NSString *const kSearchListName;

extern NSString *const kIndexDetailsDictionaryData;
extern NSString *const kVornameKey;
extern NSString *const kNachNameKey;
extern NSString *const kStrasseKey;
extern NSString *const kNrKey;
extern NSString *const kPlzKey;
extern NSString *const kOrtKey;
extern NSString *const kZahlernummerKey;


// NotificationCenter Keys
extern NSString *const kFiltersUpdateNotificationKey;
extern NSString *const kRightMenuNotificationKey;
extern NSString *const kWerbungMenuNotificationKey;
extern NSString *const kRegionChagedNotification;

// Enums for left side conrollers
typedef enum {
    firstSideTable = 1001,
    secondSideTable = 1002,
    thirdSideTable = 1003
} LeftSideTableTags;

typedef enum {
    leftMenuState = 0,
    settingsState = 1,
    searchState = 2,
    favoritesState = 3,
} LeftMenuState;

typedef enum {
    leftSideMenuOpened = 0,
    noSideMenuOpened = 1,
    rightSideMenuOpened = 2,
} StartScreenState;

extern const NSInteger kSideMenuOverlapValue;
extern const double kSideMenuAnimationDuration;

@end

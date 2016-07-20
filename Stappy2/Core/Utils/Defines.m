//
//  Defines.m
//  Schwedt
//
//  Created by Andrei Neag on 31.01.2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "Defines.h"

@implementation Defines

NSString *const kEmptyString = @"";

//Settings Constants
NSString *const kApiStringKey = @"api";
NSString *const kCaptionStringKey = @"caption";
NSString *const kIconNameStringKey = @"caption";
NSString *const kIdStringKey = @"id";
NSString *const kTypeStringKey = @"type";
NSString *const kTitleStringKey = @"title";
NSString *const kTypeApiStringKey = @"type_api";
NSString *const kUrlStringKey = @"url";
NSString *const kBaseUrlStringKey = @"bahnauskunftBaseUrl";
NSString *const kDepartureTimeUrlStringKey = @"busRealTimeDepartureTimeUrl";
NSString *const kAutorizationHeaderStringKey = @"authorizationHttpHeaderForRealTimeBussesDepartureTime";
NSString *const kBackendStringKey = @"backend";
NSString *const kDefaulLocationStringKey = @"defaultLocation";
NSString *const kApoUrlStringKey = @"apoUrl";
NSString *const kSub_ItemsStringKey = @"sub_items";
NSString *const kSettingsElements = @"SettingsElements";
NSString *const kElementSelectedString = @"elementSelected";
NSString *const kNameString = @"name";
NSString *const kSubitemsStringKey = @"subitems";
NSString *const kChildrenStringKey = @"children";
NSString *const kSelectedStringKey = @"selected";
NSString *const kAllChildrenSelectedStringKey = @"alChildrenSelected";
NSString *const kBackStringKey = @"Zürück";
NSString *const kFirstPageTitleStringKey = @"first_page_title";
NSString *const kShouldShowAddressAndNameFields = @"shouldShowAddressAndNameFields";
NSString *const kShouldShowDisplayRegionPicker = @"shouldDisplayRegionPicker";
NSString *const kShowCoupons = @"shouldShowCouponsFunctionality";
NSString *const kActiveCouponCode = @"activeCoupon";
NSString *const kCouponScreenShown = @"couponScreenShown";
NSString *const kSettingsCouponTitle = @"settingsCouponsTitle";

// CellIdentifier Constants
NSString *const kActionOptionsCellIdentifier = @"actionOptionsCell";
NSString *const kSettingsSelectionsTableViewCellIdentifier = @"SettingsSelectionsTableViewCell";
NSString *const kSettingsSelectionsTopTableViewCellIdentifier = @"SettingsSelectionsTopTableViewCell";
NSString *const kSearchAndFavoritesTableViewCell = @"SearchAndFavoritesTableViewCell";
NSString *const kSearchTopTableViewCell = @"SearchTopTableViewCell";

// Local Data storage constants
NSString *const kFavoriteAngeboteListName = @"favoriteAngebots.plist";
NSString *const kSearchListName = @"search.plist";
NSString *const kFavoriteEventsListName = @"favoriteEvents.plist";
NSString *const kSavedSettingsListName = @"settings.plist";
NSString *const kFavoriteStadtInfosListName = @"favoriteStadtInfos.plist";

NSString *const kIndexDetailsDictionaryData = @"IndexDetailsDictionaryData";
NSString *const kVornameKey = @"Vorname";
NSString *const kNachNameKey = @"NachName";
NSString *const kStrasseKey = @"Strasse";
NSString *const kNrKey = @"Nr";
NSString *const kPlzKey = @"PLZ";
NSString *const kOrtKey = @"Ort";
NSString *const kZahlernummerKey = @"Zahlernummer";

// NotificationCenter Keys
NSString *const kFiltersUpdateNotificationKey = @"filtersUpdate";
NSString *const kRightMenuNotificationKey = @"rightMenuDataLoaded";
NSString *const kWerbungMenuNotificationKey = @"werbungDataLoaded";
NSString *const kRegionChagedNotification = @"regionChangedNotification";

const NSInteger kSideMenuOverlapValue = 50;
const double kSideMenuAnimationDuration = 0.15;
@end

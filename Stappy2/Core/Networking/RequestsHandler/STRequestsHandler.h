//
//  STRequestsHandler.h
//  Stappy2
//
//  Created by Cynthia Codrea on 18/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import <Foundation/Foundation.h>

//Models
#import "STDrugstoresModel.h"
#import "STEmergenciesModel.h"
@class AFHTTPRequestOperation;

@class STTableMainKeyObject;
@class STMainModel;
@class STDetailGenericModel;
@class STFahrplanJourneyDetail;
@class STWeatherCurrentObservation;
@class STParkHausModel;
@class STGoogleLocation;

typedef NS_ENUM(NSInteger , STErrorCode)
{
    STNoNews = 0,
    STNoEvents,
    STNoAngebote
};

@interface STRequestsHandler : NSObject

@property (nonatomic, copy) NSString *emergenciesUrl;

+ (STRequestsHandler *)sharedInstance;

-(NSString *)buildPartnerUrl:(NSString *)inputUrl;

-(NSString *)buildAuthenticationValue;

//table data controller requests
- (void)werbungItemsWithCompletion:(void (^)(NSArray *, NSError *))completion;

-(void)startScreenDataWithUrl:(NSString *)url completion:(void (^)(NSArray *, NSArray *, NSError *))completion failure:(void (^)(NSError *))failure;

- (void)allLokalnewsWithUrl:(NSString *)url params:(NSMutableDictionary *)params type:(NSString *)type andCompletion:(void (^)(NSArray *, NSArray *, NSUInteger pageCount, NSError *))completion;

- (void)allAngetboteWithUrl:(NSString*)url params:(NSMutableDictionary *)params type:(NSString*)type andCompletion:(void (^)(NSArray *news, NSArray *originalNews, NSUInteger pageCount, NSError *error))completion;

- (void)allEventsWithUrl:(NSString*)url params:(NSMutableDictionary *)params type:(NSString*)type andCompletion:(void (^)(NSArray *news, NSArray *originalNews, NSUInteger pageCount, NSError *error))completion;

- (void)allVereinsnewsWithUrl:(NSString*)url params:(NSMutableDictionary *)params type:(NSString*)type andCompletion:(void (^)(NSArray *news, NSArray *originalNews, NSUInteger pageCount, NSError *error))completion;

- (void)allTickerNewsWithUrl:(NSString*)url params:(NSMutableDictionary *)params type:(NSString*)type andCompletion:(void (^)(NSArray *news, NSArray *originalNews, NSUInteger pageCount, NSError *error))completion;

-(void)weatherForCurrentDayAndForecastWithCompletion:(void(^)(NSArray*, NSArray*, id, NSError*, NSError*))completion;
- (void)weatherForStartScreenWithCompletion:(void(^)(STWeatherCurrentObservation *, NSError *))completion;

-(void)itemDetailsForURL:(NSString *)url completion:(void (^)(STDetailGenericModel *, NSDictionary *, NSError *))completion;

- (AFHTTPRequestOperation *)drugstoresWithSuccess:(void (^)(NSArray <STDrugstoresModel *>*))success failure:(void (^)(NSError *error))failure;
- (AFHTTPRequestOperation *)emergenciesWithSuccess:(void (^)(NSArray <STEmergenciesModel *>*))success failure:(void (^)(NSError *error))failure;

-(void)loadParkHousesWithCompletion:(void(^)(NSArray *, NSError *))completion failure:(void (^)(NSError *error))failure;
- (void)parkHausDetailsForUrl:(NSString*)url withCompletion:(void(^)(STParkHausModel *, NSError *))completion;

-(void)sideMenuOptionsWithUrl:(NSString *)url andCompletion:(void (^)(NSArray *, NSError *))completion;

-(void)allStadtInfoOverviewItemsWithUrl:(NSString *)url andCompletion:(void(^)(NSArray*, NSError *))completion;
- (void)stadtInfoItemForUrl:(NSString *)url mappingClass:(Class)mappingClass withCompletion:(void (^)(NSArray *, NSError *))completion;

-(void)allTankStationsWithCompletion:(void(^)(NSArray *stations, NSError *error))completion;
-(void)allElektroTankStationWithCompletion:(void(^)(NSArray *stations, NSError *error))completion;
-(void)allGeneralParkHausesWithCompletion:(void(^)(NSArray *parkHauses, NSError *error))completion;
// Settings page
-(void)settingsOptionsFromUrl:(NSString *)url andCompletion:(void (^)(NSArray *predictions, NSError *error))completion;

-(void)searchForAddress:(NSString*)address completion:(void(^)(NSArray *, NSError *))completion;
-(void)placeLocationForId:(NSString*)placeId completion:(void(^)(STGoogleLocation*location, NSError *error))completion;
// Right menu
- (void)rightMenuItemsWithCompletion:(void (^)(NSArray *, NSError *))completion;

- (NSURL *)buildImageUrl:(NSString *)inputUrl;
- (NSString *)buildUrl:(NSString *)inputUrl;
- (NSString *)buildUrl:(NSString *)inputUrl withParameters:(NSMutableDictionary *)parameters forPage:(NSUInteger)page;

@end


//
//  STRequestsHandler.m
//  Stappy2
//
//  Created by Cynthia Codrea on 18/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STRequestsHandler.h"
#import "NSBundle+DKHelper.h"
#import "STHTTPSessionManager.h"
#import "STDataManager.h"
#import "STTableMainKeyObject.h"
#import "STAppSettingsManager.h"
#import "AFNetworkReachabilityManager.h"
#import "NSError+NoConnection.h"
#import "Utils.h"
#import "Defines.h"
#import "StLocalDataArchiever.h"

//Models
#import "STStartModel.h"
#import "STNewsModel.h"
#import "STTickerModel.h"
#import "STAngeboteModel.h"
#import "STEventsModel.h"
#import "STVereinsnewsModel.h"
#import "STParkHausModel.h"
#import "STGeneralParkhausModel.h"
#import "STWeatherHourlyModel.h"
#import "STWeatherModel.h"
#import "STWeatherCurrentObservation.h"
#import "STDrugstoresModel.h"
#import "STCategoryModel.h"
#import "STStadtInfoOverviewModel.h"
#import "STDetailGenericModel.h"
#import "STLeftMenuSettingsModel.h"
#import "STLeftSideSubSettingsModel.h"
#import "STAppSettingsManager.h"
#import "STRightMenuItemsModel.h"
#import "STWerbungModel.h"
#import "STTankStationModel.h"
#import "Stappy2-Swift.h"
#import "STGoogleAutocompleteResponseModel.h"
#import "STGoogleLocation.h"
#import "AFXMLDictionaryResponseSerializer.h"
#import "STTrierParkingAvailability.h"
#import "STXMLFeedModel.h"
#import "XMLDictionary.h"
#import "STRegionManager.h"
#import "STReportListModel.h"
static NSString *STOpenAPIErrorDomain = @"STOpenAPIErrorDomain";

@interface STRequestsHandler ()

@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong) NSString *basePartnerUrl;

@end

@implementation STRequestsHandler

+ (STRequestsHandler *)sharedInstance
{
    static STRequestsHandler *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      instance = [[self alloc] init];
                      instance.baseUrl = [STAppSettingsManager sharedSettingsManager].baseUrl;
                      instance.basePartnerUrl = [STAppSettingsManager sharedSettingsManager].basePartnerUrl;
                  });

    return instance;
}

#pragma mark - Private methods

-(NSString*)buildAuthenticationValue {
    
    //get user name and pass from config file
    NSString* userName = [STAppSettingsManager sharedSettingsManager].userName;
    NSString* password = [STAppSettingsManager sharedSettingsManager].password;
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", userName, password];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"%@", [authData base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength]];
    
    return authValue;
}

-(NSDictionary*)prepareParameters {
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    //apply build and version number
    [parameters setValue:[NSBundle entryInPListForKey:@"CFBundleShortVersionString"] forKey:@"stappyVersion"];
    [parameters setValue:[NSBundle entryInPListForKey:@"CFBundleVersion"] forKey:@"stappyBuild"];
    [parameters setValue:@"ios" forKey:@"stappyOS"];
    
    NSDictionary* requestParameters = [NSDictionary dictionaryWithDictionary:parameters];
    return requestParameters;
}

-(NSString *)buildPartnerUrl:(NSString *)inputUrl {
    NSString *identifier = [NSBundle entryInPListForKey:@"CFBundleIdentifier"];
    return [NSString stringWithFormat:@"%@/data/%@%@", self.basePartnerUrl, identifier, inputUrl];
}

- (void)prepareParameters:(NSMutableDictionary *)parameters {
    [parameters setValue:@"desc" forKey:@"sort"];
}

-(NSMutableDictionary *)buildParamsForUrl:(NSString*)type __attribute__((deprecated)) {

    NSMutableDictionary* params;
    NSMutableArray* prepareParams = [NSMutableArray array];
    //array of STLeftMenuSettingsModels
    NSArray* settings = [NSKeyedUnarchiver unarchiveObjectWithFile:[Utils filePathForPlist:kSavedSettingsListName]];
    for (STLeftMenuSettingsModel* leftMenuModel in settings) {
        if ([leftMenuModel.title isEqualToString:type]) {
            for (STLeftSideSubSettingsModel* subSettingsModel in leftMenuModel.subItems) {
                if (subSettingsModel.isSelected) {
                    //Option was selected; save name into parameters
                    [prepareParams addObject:subSettingsModel.modelId];
                }
            }
        }
    }
    params = [NSMutableDictionary dictionaryWithDictionary:@{@"filter":[prepareParams componentsJoinedByString:@","]}];
    params[@"sort"] = @"DESC";

    return params;
}

- (NSMutableDictionary *)buildParamsForType:(FilterType)type withRegionFilters:(BOOL)shouldUseRegionFilters {
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    NSArray *enabledFilters = [[Filters sharedInstance] filtersForType:type];
    params[@"filter"] = [enabledFilters componentsJoinedByString:@","];

    if (shouldUseRegionFilters)
    {
        NSArray *selectedRegions = [[Filters sharedInstance] filtersForType:FilterTypeRegionen];
        params[@"regions"] = [selectedRegions componentsJoinedByString:@","];
    }

    params[@"sort"] = @"DESC";
    
    return params;
}

- (NSString *)buildUrl:(NSString *)inputUrl { return [self buildUrl:inputUrl withParameters:nil forPage:0]; }

- (NSString *)buildUrl:(NSString *)inputUrl withParameters:(NSMutableDictionary *)parameters forPage:(NSUInteger)page {
    NSURL *url = [NSURL URLWithString:inputUrl];
    
    NSRange range = [inputUrl rangeOfString:@"?"];
    if (range.location != NSNotFound) {
//        inputUrl = [inputUrl substringWithRange:NSMakeRange(0, range.location)];
    }
    
    // Extract the parameters
    if ([inputUrl hasPrefix:@"http"])
        return [url absoluteString];
    else if ([inputUrl hasPrefix:@"/"]) {
        NSString *identifier = [NSBundle entryInPListForKey:@"CFBundleIdentifier"];
        if ([inputUrl hasPrefix:@"/data"])
            return [self.baseUrl stringByAppendingString:inputUrl];
        return [NSString stringWithFormat:@"%@/data/%@%@", self.baseUrl, identifier, inputUrl];
    } else {
        // Local url
        return inputUrl;
    }
}

- (NSURL *)buildImageUrl:(NSString *)inputUrl {
    if ([inputUrl isKindOfClass:[NSNull class]])
        return nil;
    
    NSString *url;
    if ([inputUrl hasPrefix:@"/"])
        url = [self.baseUrl stringByAppendingString:inputUrl];
    else
        url = [inputUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return [NSURL URLWithString:url];
}


#pragma mark - Public methods

//afnetworking requests

-(void)startScreenDataWithUrl:(NSString *)url completion:(void (^)(NSArray *, NSArray *, NSError *))completion failure:(void (^)(NSError *error))failure {
    
    NSString* requestUrl = [self buildUrl:url withParameters:nil forPage:0];
    
    [[STHTTPSessionManager manager] GET:requestUrl
                             parameters:nil
                                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                    if (completion) {
                                        NSError* mtlError = nil;
                                        NSMutableArray* startDataObjectsArray = [NSMutableArray array];
                                        NSMutableArray* startDataKeysArray = [NSMutableArray array];
                                        NSArray * ignoredItems= [STAppSettingsManager sharedSettingsManager].startScreenIgnoreActions;
                                        for (NSDictionary*item in responseObject[@"content"]) {
                                            //remove items to ignore
                                            BOOL isIgnored = NO;
                                            NSString* idString = item[@"id"];
                                            if (idString.length == 0) {
                                                continue;
                                            }
                                            NSArray *keyArray = nil;
                                            for (NSString* key in ignoredItems){

                                                NSArray *jsonArray = [item objectForKey:@"items"];
                                                if ([key isEqualToString:idString] || !jsonArray) {
                                                    isIgnored = YES;
                                                    break;
                                                }
                                                keyArray = [MTLJSONAdapter modelsOfClass:[STStartModel class]
                                                                                    fromJSONArray:jsonArray
                                                                                            error:&mtlError];
                                            }
                                            NSString* key = item[@"id"];
                                            if (!isIgnored) {
                                                [startDataObjectsArray addObject:keyArray];
                                                [startDataKeysArray addObject:key];
                                            }

                                        }
                                        if (!mtlError) {
                                            completion(startDataObjectsArray, startDataKeysArray, nil);
                                        }
                                        else {
                                            NSError *error = [NSError errorWithDomain:STOpenAPIErrorDomain
                                                                                 code:0
                                                                             userInfo:nil];
                                            completion(nil, nil, error);
                                        }
                                    }
                                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                    if (failure) {
                                        failure(error);
                                    }
                                    //TODO
                                }];
}

-(void)allAngetboteWithUrl:(NSString *)url params:(NSMutableDictionary *)params type:(NSString *)type andCompletion:(void (^)(NSArray *, NSArray *, NSUInteger, NSError *))completion {

    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        completion(nil, nil, 0, [NSError errorWithDomain:@"Error: NSURLErrorNotConnectedToInternet" code:NSURLErrorNotConnectedToInternet userInfo:nil]);
        return;
    }
    
    NSString* requestUrl = [self buildUrl:url withParameters:nil forPage:0];
    NSMutableDictionary* parameters = [self buildParamsForType:FilterTypeAngebote withRegionFilters:YES];
    [parameters addEntriesFromDictionary:params];
    
    //build the url with param here to test pagination
    STHTTPSessionManager *manager = [STHTTPSessionManager manager];
    NSString* serializedUrl = [manager.requestSerializer requestWithMethod:@"GET" URLString:requestUrl parameters:parameters error:nil].URL.absoluteString;
    //the above section should be later moved to buildUrl method
    
    [[STHTTPSessionManager manager] GET:serializedUrl
                             parameters:parameters
                                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                    if (completion) {
                                        NSError *mtlError = nil;
                                        NSArray *angebote = [MTLJSONAdapter modelsOfClass:[STAngeboteModel class]
                                                                        fromJSONArray:responseObject[@"content"]
                                                                                error:&mtlError];
                                        
                                        [[StLocalDataArchiever sharedArchieverManager] saveObjectsInSearchArray:angebote];
                                        
                                        NSUInteger pageCount = [responseObject[@"pages"][@"pageCount"] integerValue];
                                        if (!mtlError) {
                                            //first group the data
                                            NSArray* groupedNews = [STDataManager groupArrayOfModels:angebote];
                                            completion(groupedNews, angebote, pageCount ,nil);
                                        }

                                        else {
                                            NSError *error = [NSError errorWithDomain:STOpenAPIErrorDomain
                                                                                 code:0
                                                                             userInfo:nil];
                                            completion(nil, nil, 0, error);
                                        }
                                    }
                                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                                    @throw [NSException exceptionWithName:@"NotHandledException" reason:@"Please add error handling." userInfo:nil];
                                    
                                    //TODO
                                }];
}

-(void)allEventsWithUrl:(NSString *)url params:(NSMutableDictionary *)params type:(NSString *)type andCompletion:(void (^)(NSArray *, NSArray *, NSUInteger, NSError *))completion {
    
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        completion(nil, nil, 0, [NSError errorWithDomain:@"Error: NSURLErrorNotConnectedToInternet" code:NSURLErrorNotConnectedToInternet userInfo:nil]);
        return;
    }
    
    NSString* requestUrl = [self buildUrl:url withParameters:nil forPage:0];
    NSMutableDictionary* parameters = [self buildParamsForType:FilterTypeEvents withRegionFilters:YES];
    [parameters addEntriesFromDictionary:params];
    [parameters removeObjectForKey:@"sort"]; // FIXME: temporary solution. In the future all the parameters
    // for the requests should be store in configuration file
    
    //build the url with param here to test pagination
    STHTTPSessionManager *manager = [STHTTPSessionManager manager];
    NSString* serializedUrl = [manager.requestSerializer requestWithMethod:@"GET" URLString:requestUrl parameters:params error:nil].URL.absoluteString;
    //the above section should be later moved to buildUrl method
    
    [[STHTTPSessionManager manager] GET:serializedUrl
                             parameters:parameters
                                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                    if (completion) {
                                        NSError *mtlError = nil;
                                        NSArray *events = [MTLJSONAdapter modelsOfClass:[STEventsModel class]
                                                                            fromJSONArray:responseObject[@"content"]
                                                                                    error:&mtlError];
                                        
                                        [[StLocalDataArchiever sharedArchieverManager] saveObjectsInSearchArray:events];
                                        NSUInteger pageCount = 0;

                                        if (responseObject[@"pages"] != [NSNull null]) {
                                            pageCount  = [responseObject[@"pages"][@"pageCount"] integerValue];
                                        }
                                        
                                        if (!mtlError) {
                                            //first group the data
                                            NSArray* groupedNews = [STDataManager groupArrayOfModels:events];
                                            completion(groupedNews, events, pageCount ,nil);
                                        }
                                        else {
                                            NSError *error = [NSError errorWithDomain:STOpenAPIErrorDomain
                                                                                 code:0
                                                                             userInfo:nil];
                                            completion(nil,nil, 0, error);
                                        }
                                    }
                                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                                    @throw [NSException exceptionWithName:@"NotHandledException" reason:@"Please add error handling." userInfo:nil];
                                    
                                    //TODO
                                }];
}

-(void)allVereinsnewsWithUrl:(NSString *)url params:(NSMutableDictionary *)params type:(NSString *)type andCompletion:(void (^)(NSArray *, NSArray *, NSUInteger, NSError *))completion {
    
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        completion(nil, nil, 0, [NSError errorWithDomain:@"Error: NSURLErrorNotConnectedToInternet" code:NSURLErrorNotConnectedToInternet userInfo:nil]);
        return;
    }
    
    NSString* requestUrl = [self buildUrl:url withParameters:nil forPage:0];
    NSMutableDictionary* parameters = [self buildParamsForType:FilterTypeVereinsnews withRegionFilters:YES];
//    [parameters addEntriesFromDictionary:params];
    
    [params addEntriesFromDictionary:@{@"sort":@"DESC"}];
    
    //build the url with param here to test pagination
    STHTTPSessionManager *manager = [STHTTPSessionManager manager];
    NSString* serializedUrl = [manager.requestSerializer requestWithMethod:@"GET" URLString:requestUrl parameters:nil error:nil].URL.absoluteString;
    //the above section should be later moved to buildUrl method
    
    [[STHTTPSessionManager manager] GET:serializedUrl
                             parameters:parameters
                                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                    if (completion) {
                                        NSError *mtlError = nil;
                                        NSArray *vereinnews = [MTLJSONAdapter modelsOfClass:[STVereinsnewsModel class]
                                                                          fromJSONArray:responseObject[@"content"]
                                                                                  error:&mtlError];
                                        
                                        [[StLocalDataArchiever sharedArchieverManager] saveObjectsInSearchArray:vereinnews];
                                        
                                        NSUInteger pageCount = [responseObject[@"pages"][@"pageCount"] integerValue];
                                        if (!mtlError) {
                                            //first group the data
                                            NSArray* groupedNews = [STDataManager groupArrayOfModels:vereinnews];
                                            completion(groupedNews, vereinnews, pageCount ,nil);
                                        }

                                        else {
                                            NSError *error = [NSError errorWithDomain:STOpenAPIErrorDomain
                                                                                 code:0
                                                                             userInfo:nil];
                                            completion(nil, nil, 0, error);
                                        }
                                    }
                                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                                    @throw [NSException exceptionWithName:@"NotHandledException" reason:@"Please add error handling." userInfo:nil];
                                    
                                    //TODO
                                }];
}

-(void)allLokalnewsWithUrl:(NSString *)url params:(NSMutableDictionary *)params type:(NSString *)type andCompletion:(void (^)(NSArray *, NSArray *, NSUInteger pageCount ,NSError *))completion {
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        completion(nil, nil, 0, [NSError errorWithDomain:@"Error: NSURLErrorNotConnectedToInternet" code:NSURLErrorNotConnectedToInternet userInfo:nil]);
        return;
    }
    
    NSString* requestUrl = [self buildUrl:url withParameters:nil forPage:0];
    NSMutableDictionary* parameters = [self buildParamsForType:FilterTypeLokalnews withRegionFilters:YES];
    [parameters addEntriesFromDictionary:params];
    
    //build the url with param here to test pagination
    STHTTPSessionManager *manager = [STHTTPSessionManager manager];
    NSString* serializedUrl = [manager.requestSerializer requestWithMethod:@"GET" URLString:requestUrl parameters:params error:nil].URL.absoluteString;
    //the above section should be later moved to buildUrl method
    
    [[STHTTPSessionManager manager] GET:serializedUrl
                             parameters:parameters
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                         if (completion) {
                             NSError *mtlError = nil;
                             NSArray *news = [MTLJSONAdapter modelsOfClass:[STNewsModel class]
                                                             fromJSONArray:responseObject[@"content"]
                                                                     error:&mtlError];
                             
                             [[StLocalDataArchiever sharedArchieverManager] saveObjectsInSearchArray:news];
                             
                             NSUInteger pageCount = [responseObject[@"pages"][@"pageCount"] integerValue];
                             if (!mtlError) {
                                 //first group the data
                                 NSArray* groupedNews = [STDataManager groupArrayOfModels:news];
                                 completion(groupedNews, news, pageCount ,nil);
                             }
                             else {
                                 NSError *error = [NSError errorWithDomain:STOpenAPIErrorDomain
                                                                      code:0
                                                                  userInfo:nil];
                                 completion(nil, nil, 0, error);
                             }
                         }
                     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                         @throw [NSException exceptionWithName:@"NotHandledException" reason:@"Please add error handling." userInfo:nil];
                         
                         //TODO
                     }];
}

-(void)allTickerNewsWithUrl:(NSString *)url params:(NSMutableDictionary *)params type:(NSString *)type andCompletion:(void (^)(NSArray *, NSArray *, NSUInteger, NSError *))completion {
    
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        completion(nil, nil, 0, [NSError errorWithDomain:@"Error: NSURLErrorNotConnectedToInternet" code:NSURLErrorNotConnectedToInternet userInfo:nil]);
        return;
    }
    
    NSString* requestUrl = [self buildUrl:url withParameters:nil forPage:0];
    NSMutableDictionary* parameters = [self buildParamsForType:FilterTypeTicker withRegionFilters:NO];
    [parameters addEntriesFromDictionary:params];
    
    //build the url with param here to test pagination
    STHTTPSessionManager *manager = [STHTTPSessionManager manager];
    NSString* serializedUrl = [manager.requestSerializer requestWithMethod:@"GET" URLString:requestUrl parameters:params error:nil].URL.absoluteString;
    //the above section should be later moved to buildUrl method
    
    [[STHTTPSessionManager manager] GET:requestUrl
                             parameters:parameters
                                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                    if (completion) {
                                        NSError *mtlError = nil;
                                        NSArray *tickerNews = [MTLJSONAdapter modelsOfClass:[STTickerModel class]
                                                                        fromJSONArray:responseObject[@"content"]
                                                                                error:&mtlError];
                                        
                                        [[StLocalDataArchiever sharedArchieverManager] saveObjectsInSearchArray:tickerNews];
                                        NSUInteger pageCount = [responseObject[@"pages"][@"pageCount"] integerValue];
                                        
                                        if (!mtlError) {
                                            //first group the data
                                            NSArray* groupedNews = [STDataManager groupArrayOfModels:tickerNews];
                                            completion(groupedNews, tickerNews, pageCount ,nil);
                                        }
                                        else {
                                            NSError *error = [NSError errorWithDomain:STOpenAPIErrorDomain
                                                                                 code:0
                                                                             userInfo:nil];
                                            completion(nil, nil, 0, error);
                                        }
                                    }
                                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                                    @throw [NSException exceptionWithName:@"NotHandledException" reason:@"Please add error handling." userInfo:nil];
                                    
                                    //TODO
                                }];
}

-(void)itemDetailsForURL:(NSString *)url completion:(void (^)(STDetailGenericModel *, NSDictionary *, NSError *))completion {
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        completion(nil, nil,[NSError errorWithDomain:@"Error: NSURLErrorNotConnectedToInternet" code:NSURLErrorNotConnectedToInternet userInfo:nil]);
        return;
    }
    
    NSString* requestUrl = url;
    if (![requestUrl hasPrefix:@"http"]) {
        requestUrl = [NSString stringWithFormat:@"%@%@", self.baseUrl, url];
    }
    
    [[STHTTPSessionManager manager] GET:requestUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        if (completion) {
            NSError *mtlError = nil;
            
            id data = responseObject[@"content"];
            if ([data isKindOfClass:[NSArray class]])
            {
                if ([(NSArray*)data count]>0) {
                    data = data[0];
                    
                }
                
            }
            
            STDetailGenericModel *detailsData = [MTLJSONAdapter modelOfClass:[STDetailGenericModel class]
                                                          fromJSONDictionary:data
                                                                       error:&mtlError];
            
            [[StLocalDataArchiever sharedArchieverManager] saveObjectInSearchArray:detailsData];
            
            if (!mtlError) {
                completion(detailsData, data,nil);
            }
            else {
                NSError *error = [NSError errorWithDomain:STOpenAPIErrorDomain
                                                     code:1
                                                 userInfo:nil];
                completion(nil,nil,error);
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
   
}




#pragma mark - Drugstores/Emergencies


- (void)drugstoresWithCompletion:(void(^)(NSArray *array, NSError *error))completion {
    
    NSString *url = [self buildUrl:@"/apotheken" withParameters:nil forPage:0];
    
  
    STHTTPSessionManager *manager = [STHTTPSessionManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer alloc]];
    
    
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError*error;
        NSArray *drugstoresArray = [MTLJSONAdapter modelsOfClass:STDrugstoresModel.class
                                                   fromJSONArray:responseObject[@"content"]
                                                           error:&error];
        
        completion(drugstoresArray, error);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);

        
    }];
    
    
}

- (void)emergenciesWithCompletion:(void(^)(NSArray *array, NSError *error))completion {
    
    
    STHTTPSessionManager *manager = [STHTTPSessionManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer alloc]];
    
    
    [manager GET:self.emergenciesUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError*error;
        NSArray *emergenciesArray = [MTLJSONAdapter modelsOfClass:STEmergenciesModel.class
                                                    fromJSONArray:responseObject[@"apotheken"]
                                                            error:&error];
        
        completion(emergenciesArray, error);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
        
        
    }];
    
    
}

#pragma mark - Park houses

-(void)loadParkHousesWithCompletion:(void(^)(NSArray *, NSError *))completion failure:(void (^)(NSError *error))failure{

    NSString *parkingUrl = [[STAppSettingsManager sharedSettingsManager] backendValueForKey:@"parkHaus.url"];
  
    NSString* userName = [STAppSettingsManager sharedSettingsManager].userName;
    NSString* password = [STAppSettingsManager sharedSettingsManager].password;
    STHTTPSessionManager *manager = [STHTTPSessionManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer alloc]];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:userName password:password];
    
    
    [manager GET:parkingUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSMutableArray *parkingLocations = [NSMutableArray array];
        for (NSDictionary * locationDict in responseObject) {
            NSError *mtlError = nil;
            NSDictionary * objectDict = [locationDict objectForKey:@"parking_unit"];
            STParkHausModel * locationObject = [[STParkHausModel alloc] initWithDictionary:objectDict];
            if (!mtlError) {
                [parkingLocations addObject:locationObject];
            }
        }
        completion(parkingLocations,nil);

        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Failure: %@", error.description);
        NSLog(@"Failure: %@", error.description);

    }];

    
    
 
}

- (void)parkHausDetailsForUrl:(NSString*)url withCompletion:(void(^)(STParkHausModel *, NSError *))completion {
    
    NSString *encodedUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSString* userName = [STAppSettingsManager sharedSettingsManager].userName;
    NSString* password = [STAppSettingsManager sharedSettingsManager].password;
    STHTTPSessionManager *manager = [STHTTPSessionManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer alloc]];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:userName password:password];
  
    
    [manager GET:encodedUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary * objectDict = [responseObject objectForKey:@"parking_unit"];
        STParkHausModel* locationObject = [[STParkHausModel alloc] initWithDictionary:objectDict];
        completion(locationObject,nil);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Failure: %@", error.description);

    }];
    
   
}


-(void)allElektroTankStationWithCompletion:(void(^)(NSArray *, NSError *))completion{
    
    NSString *url = [self buildUrl:@"/data/de.endios.stappy.trier/sinfo?id=80796&apiVersion=2" withParameters:nil forPage:0];;
    NSString* userName = [STAppSettingsManager sharedSettingsManager].userName;
    NSString* password = [STAppSettingsManager sharedSettingsManager].password;
    STHTTPSessionManager *manager = [STHTTPSessionManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer alloc]];

    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *mtlError = nil;
        NSMutableArray *items = [[MTLJSONAdapter modelsOfClass:[STTankStationModel class]
                                                 fromJSONArray:responseObject[@"content"]
                                                         error:&mtlError] mutableCopy];
        if (!mtlError) {
            
            for (STTankStationModel*tankStationModel in items) {
                tankStationModel.stationType = STTankStationModelTypeElektro;
            }
            
            
            completion([items copy],nil);
        }
        else {
            NSError *error = [NSError errorWithDomain:STOpenAPIErrorDomain
                                                 code:0
                                             userInfo:nil];
            completion(nil,error);
        }
        
        completion(nil,nil);

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Failure: %@", error.description);
        completion(nil,error);
    }];
 

}



-(void)getXMLFeed:(NSString*)xmlFeed completion:(void(^)(NSArray *, NSError *))completion{
    
    NSString *url = xmlFeed;
    STHTTPSessionManager *manager = [STHTTPSessionManager manager];
    
    [manager setResponseSerializer:[AFXMLDictionaryResponseSerializer serializer]];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/rss+xml"];

    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSMutableArray*array = [NSMutableArray array];
        
        for (NSDictionary*dict in [[responseObject objectForKey:@"channel"] objectForKey:@"item"]) {
            [array addObject:[STXMLFeedModel feedModelFromDictionary:dict]];
        }
        
        NSSortDescriptor* sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"publishDate" ascending:NO];
        NSArray*results =  [array sortedArrayUsingDescriptors:@[sortByDate]];
        
        completion(results,nil);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil,error);

    }];
    

}

-(void)getReportListWithcompletion:(void(^)(NSArray *results, NSError *error))completion{
   
    NSString* requestUrl = [self buildUrl:@"/oepnv" withParameters:nil forPage:0];
    NSMutableDictionary* parameters = [self buildParamsForType:FilterTypeRegionen withRegionFilters:YES];
    
    //build the url with param here to test pagination
    STHTTPSessionManager *manager = [STHTTPSessionManager manager];
    NSString* serializedUrl = [manager.requestSerializer requestWithMethod:@"GET" URLString:requestUrl parameters:nil error:nil].URL.absoluteString;

    
    [[STHTTPSessionManager manager] GET:serializedUrl parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        NSMutableArray*array = [NSMutableArray array];
        
        for (NSDictionary*dict in [responseObject objectForKey:@"content"]) {
            [array addObject:[STReportListModel reportListModelFromDictionary:dict]];
        }
        
        NSSortDescriptor* sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"publishDate" ascending:NO];
        NSArray*results =  [array sortedArrayUsingDescriptors:@[sortByDate]];
        
        completion(results,nil);

        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil,error);

    }];
}

-(void)allTankStationsWithId:(NSString*)stationId andCompletion:(void(^)(NSArray *, NSError *))completion{
    NSString* url = [self buildUrl:stationId withParameters:nil forPage:0];
    
    STHTTPSessionManager *manager = [STHTTPSessionManager manager];
    NSString* serializedUrl = [manager.requestSerializer requestWithMethod:@"GET" URLString:url parameters:nil error:nil].URL.absoluteString;
    
    [[STHTTPSessionManager manager] GET:serializedUrl parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSError *mtlError = nil;
        NSMutableArray *items = [[MTLJSONAdapter modelsOfClass:[STTankStationModel class]
                                                 fromJSONArray:responseObject[@"content"]
                                                         error:&mtlError] mutableCopy];
        
        for (STTankStationModel*model in items) {
            if ([[model.title lowercaseString] containsString:@"erd"]) {
                model.stationType = STTankStationModelTypeGas;
            }
            else{
                model.stationType = STTankStationModelTypeElektro;

            }
        }
        
        if (!mtlError) {
            completion([items copy],nil);
        }
        else {
            NSError *error = [NSError errorWithDomain:STOpenAPIErrorDomain
                                                 code:0
                                             userInfo:nil];
            completion(nil,error);
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Failure: %@", error.description);
        completion(nil,error);
    }];
}

-(void)allTankStationsWithCompletion:(void(^)(NSArray *, NSError *))completion{
    
    NSString *url = [self buildUrl:@"/data/de.endios.stappy.trier/sinfo?id=80797&apiVersion=2" withParameters:nil forPage:0];;
    NSString* userName = [STAppSettingsManager sharedSettingsManager].userName;
    NSString* password = [STAppSettingsManager sharedSettingsManager].password;
    STHTTPSessionManager *manager = [STHTTPSessionManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer alloc]];
    
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *mtlError = nil;
        NSMutableArray *items = [[MTLJSONAdapter modelsOfClass:[STTankStationModel class]
                                                 fromJSONArray:responseObject[@"content"]
                                                         error:&mtlError] mutableCopy];
        if (!mtlError) {
            
            for (STTankStationModel*tankStationModel in items) {
                tankStationModel.stationType = STTankStationModelTypeGas;
            }
            
            completion([items copy],nil);
        }
        else {
            NSError *error = [NSError errorWithDomain:STOpenAPIErrorDomain
                                                 code:0
                                             userInfo:nil];
            completion(nil,error);
        }
        
        completion(nil,nil);

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Failure: %@", error.description);
        completion(nil,error);

    }];
    

}


-(void)searchForAddress:(NSString*)address completion:(void(^)(NSArray *, NSError *))completion{
    
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?key=%@&input=%@&types=geocode&language=de",[[STAppSettingsManager sharedSettingsManager] backendValueForKey:@"fahrplan.fahrplan_api---GOOGLE.access_id"],address ];
    
    
    STHTTPSessionManager *manager = [STHTTPSessionManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        STGoogleAutocompleteResponseModel*model = [[STGoogleAutocompleteResponseModel alloc]
                                                   initWithDictionary:responseObject];
        
        completion(model.predictions,nil);
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Failure: %@", error.description);
        completion(nil,error); }];


}

-(void)placeLocationForId:(NSString*)placeId completion:(void(^)(STGoogleLocation*, NSError *error))completion{
    
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?key=%@&placeid=%@&language=de",[[STAppSettingsManager sharedSettingsManager] backendValueForKey:@"fahrplan.fahrplan_api---GOOGLE.access_id"],placeId ];
    
    
    STHTTPSessionManager *manager = [STHTTPSessionManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        STGoogleLocation*location = [[STGoogleLocation alloc] initWithDictionary:[[[responseObject objectForKey:@"result"] objectForKey:@"geometry"] objectForKey:@"location"]];
        
        completion(location,nil);

        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Failure: %@", error.description);
        completion(nil,error);    }];

}

-(void)parkenAvailabilityTrier:(void(^)(NSArray *, NSError *))completion{
    
    NSString *url = @"http://www.swt.de/parken.xml";
    
    STHTTPSessionManager *manager = [STHTTPSessionManager manager];
    [manager setResponseSerializer:[AFXMLDictionaryResponseSerializer serializer]];

    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSMutableArray*array = [NSMutableArray array];
        
        for (NSDictionary*dict in [responseObject objectForKey:@"parkhaus"]) {
            [array addObject:[STTrierParkingAvailability availabilityFromDictionary:dict]];
        }
        
        completion([array copy],nil);

        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil,error);
    }];
    
    
 
}



-(void)allGeneralParkHausesWithCompletion:(void(^)(NSArray *, NSError *))completion{
    
    NSString *url = [self buildUrl:@"/data/de.endios.stappy.trier/sinfo?id=81236&apiVersion=2" withParameters:nil forPage:0];
    
    if ([[STAppSettingsManager sharedSettingsManager] backendValueForKey:@"generalParkhausUrl"]) {
        url = [[STAppSettingsManager sharedSettingsManager] backendValueForKey:@"generalParkhausUrl"];
    }
    
    STHTTPSessionManager *manager = [STHTTPSessionManager manager];
 

    if ([url containsString:@"sinfo"]) {
        [manager setResponseSerializer:[AFJSONResponseSerializer alloc]];

        [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [self parkenAvailabilityTrier:^(NSArray *responseArray, NSError *error) {
                
                if (responseArray) {
                    
                    NSError *mtlError = nil;
                    NSMutableArray *items = [[MTLJSONAdapter modelsOfClass:[STGeneralParkhausModel class]
                                                             fromJSONArray:responseObject[@"content"]
                                                                     error:&mtlError] mutableCopy];
                    if (!mtlError) {
                        
                        for (STGeneralParkhausModel*model in items) {
                            NSString*key = [[STAppSettingsManager sharedSettingsManager] parkingKeyForId:[model.itemId stringValue]];
                            
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE[cd] %@", key];
                            NSArray *filtered = [responseArray filteredArrayUsingPredicate:predicate];
                            
                            STTrierParkingAvailability*av;
                            
                            if (filtered.count>0) {
                                av =  filtered[0];
                                
                            }
                            
                            if (av) {
                                
                                double percetage = ((double)av.shortFree/(double)av.shortMax)*100;
                                
                                if (percetage<6) {
                                    model.availability = 0;
                                }
                                else if (percetage>5&&percetage<70) {
                                    model.availability = 1;
                                }
                                else {
                                    model.availability = 2;
                                }
                                model.freePlaces = av.shortFree;
                                model.capacity = av.shortMax;
                                
                            }
                            
                            
                        }
                        
                        
                        completion(items,nil);
                    }
                    else {
                        NSError *error = [NSError errorWithDomain:STOpenAPIErrorDomain
                                                             code:0
                                                         userInfo:nil];
                        completion(nil,error);
                    }
                    
                }
                
                
            }];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            completion(nil,error);
        }];
        
        
    }
    else{
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
        [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            if (responseObject) {
                
                XMLDictionaryParser *parser = [[XMLDictionaryParser alloc] init];
                NSDictionary*dict = [parser dictionaryWithData:responseObject];
                
                NSMutableArray *items = [NSMutableArray array];
                
                for (NSDictionary*haus in [dict objectForKey:@"Parkhaus"]) {
                    [items addObject:[STGeneralParkhausModel parkhausFromXMLDictionary:haus]];
                }
                
                
                completion(items,nil);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            completion(nil, error);
        }];
        
   
        

    }
    
   
}



#pragma mark - Side menu suboption calls

-(void)sideMenuOptionsWithUrl:(NSString *)url andCompletion:(void (^)(NSArray *, NSError *))completion {
    
    NSString* requestUrl = [self buildUrl:url withParameters:nil forPage:0];
    [[STHTTPSessionManager manager] GET:requestUrl
                             parameters:nil
                                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                    if (completion) {
                                        NSError *mtlError = nil;
                                        NSArray *secondMenuItemsArr = [MTLJSONAdapter modelsOfClass:[STCategoryModel class]
                                                                               fromJSONArray:responseObject[@"content"]
                                                                                       error:&mtlError];
                                        completion(secondMenuItemsArr,nil);
                                        
                                    }
                                    else {
                                        NSError *error = [NSError errorWithDomain:STOpenAPIErrorDomain
                                                                             code:0
                                                                         userInfo:nil];
                                        completion(nil, error);
                                    }
  
                                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                                    @throw [NSException exceptionWithName:@"NotHandledException" reason:@"Please add error handling." userInfo:nil];
                                    //TODO
                                }];
}

#pragma mark - StadtInfo calls

-(void)allStadtInfoOverviewItemsWithUrl:(NSString *)url andCompletion:(void (^)(NSArray *, NSError *))completion {
    [self stadtInfoItemForUrl:url mappingClass:[STStadtInfoOverviewModel class] withCompletion:completion];
}

- (void)stadtInfoItemForUrl:(NSString *)url mappingClass:(Class)mappingClass withCompletion:(void (^)(NSArray *, NSError *))completion {
    NSString* requestUrl = [self buildUrl:url withParameters:nil forPage:0];
    requestUrl = [requestUrl stringByAppendingString:@"&apiVersion=2"];
    
    NSDictionary* params = @{@"regions": [[[Filters sharedInstance] filtersForType:FilterTypeRegionen] componentsJoinedByString:@","]};
    
    [[STHTTPSessionManager manager] GET:requestUrl
                             parameters:params
                                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                    if (completion) {
                                        NSError *mtlError = nil;
                                        NSArray *stadtInfoOverviewItems = [MTLJSONAdapter modelsOfClass:mappingClass
                                                                                          fromJSONArray:responseObject[@"content"]
                                                                                                  error:&mtlError];
                                        completion(stadtInfoOverviewItems,nil);
                                    }
                                    else {
                                        NSError *error = [NSError errorWithDomain:STOpenAPIErrorDomain
                                                                             code:0
                                                                         userInfo:nil];
                                        completion(nil, error);
                                    }
                                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                    //TODO
                                }];
}

#pragma mark - Settings options calls

+ (NSMutableArray *)getOnlyLeafIds:(NSDictionary *)jsonFilter
{
    NSMutableArray *filters = [NSMutableArray array];
    
    id children = jsonFilter[@"children"];
    if ([children isKindOfClass:[NSArray class]] && [children count] > 0) {
        for (NSDictionary *filter in children) {
            filters = [NSMutableArray arrayWithArray:[filters arrayByAddingObjectsFromArray:[STRequestsHandler getOnlyLeafIds:filter]]];
        }
    } else {
        if (jsonFilter[@"id"]) {
            [filters addObject:jsonFilter[@"id"]];
        }
    }
    return filters;
}

-(void)settingsOptionsFromUrl:(NSString *)url andCompletion:(void (^)(NSArray *, NSError *))completion {
    NSString* requestUrl = [self buildUrl:url withParameters:nil forPage:0];
    NSDictionary* params = @{@"regions": [[[Filters sharedInstance] filtersForType:FilterTypeRegionen] componentsJoinedByString:@","]};
    [[STHTTPSessionManager manager] GET:requestUrl
                             parameters:params
                                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                    if (completion) {
                                        NSMutableArray *settingsArray = [NSMutableArray array];
                                        NSDictionary *contentDict = responseObject[@"content"];
                                        if (contentDict) {
                                            // We go through all the keys in the dictionary to get the elements from server
                                            for (NSString *key in [contentDict allKeys])
                                            {
                                                // clear the saved Filters, that do not belong to this region
                                                NSError *error;
                                                NSArray *savedFiltersForType = [[Filters sharedInstance] filtersForType:key error:&error];
                                                if (!error)
                                                {
                                                    NSMutableSet *filtersNotForThisRegion = [NSMutableSet setWithArray:savedFiltersForType];
                                                    id children = [contentDict objectForKey:key];
                                                    if ([children isKindOfClass:[NSDictionary class]]) children = @[children];
                                                    if ([children isKindOfClass:[NSArray class]])
                                                    {
                                                        NSMutableArray *filters = [NSMutableArray array];
                                                        for (id child in children) [filters addObjectsFromArray:[STRequestsHandler getOnlyLeafIds:child]];
                                                        
                                                        NSSet *ids = [NSSet setWithArray:filters];
                                                        [filtersNotForThisRegion minusSet:ids];
                                                        [[Filters sharedInstance] deleteFilterWithFilterIds:[filtersNotForThisRegion allObjects]
                                                                                        forStringFilterType:key
                                                                                               notification:NO
                                                                                                      error:&error];
                                                        if (error) NSLog(@"%@", [error localizedFailureReason]);
                                                    }
                                                }
                                                else NSLog(@"%@", [error localizedFailureReason]);

                                                id childrenObject = [contentDict objectForKey:key];
                                                STLeftMenuSettingsModel * settingsModel = [[STLeftMenuSettingsModel alloc] init];
                                                settingsModel.type = key;
                                                [settingsModel loadSubItemsFromObject:childrenObject forFilterType:key];
                                                [settingsArray addObject:settingsModel];
                                                [[Filters sharedInstance] stringfilterTypeWasLoadedFromServer:key];
                                            }
                                        }
                                        completion(settingsArray,nil);
                                    }
                                    else {
                                        NSError *error = [NSError errorWithDomain:STOpenAPIErrorDomain
                                                                             code:0
                                                                         userInfo:nil];
                                        completion(nil, error);
                                    }
                                    
                                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                    //TODO
                                }];
}

#pragma mark - Werbung Items calls

- (void)werbungItemsWithCompletion:(void (^)(NSArray *, NSError *))completion {
    NSString *url = [NSString stringWithFormat:@"/werbung"];
    NSString *requestUrl = [self buildUrl:url withParameters:nil forPage:0];
    [[STHTTPSessionManager manager] GET:requestUrl
                             parameters:nil
                                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                    if (completion) {
                                        NSError *mtlError = nil;
                                        NSArray *werbungItems = [MTLJSONAdapter modelsOfClass:[STWerbungModel class]
                                                                                      fromJSONArray:responseObject[@"content"]
                                                                                              error:&mtlError];
                                        if (!mtlError) {
                                            completion(werbungItems,nil);
                                        }
                                        else {
                                            NSError *error = [NSError errorWithDomain:STOpenAPIErrorDomain
                                                                                 code:0
                                                                             userInfo:nil];
                                            completion(nil,error);
                                        }
                                    }
                                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                    //TODO
                                }];

}

#pragma mark - Right Menu Items calls

- (void)rightMenuItemsWithCompletion:(void (^)(NSArray *, NSError *))completion {
    NSNumber *rightMenuItemsId = [[STAppSettingsManager sharedSettingsManager] rightMenuItemsId];
    NSString *url = [NSString stringWithFormat:@"/sinfo?id=%d", [rightMenuItemsId intValue]];
    
    if ([STAppSettingsManager sharedSettingsManager].rightMenuCustom) {
        url =[STAppSettingsManager sharedSettingsManager].rightMenuCustom;
    }
    
    NSString *requestUrl = [self buildUrl:url withParameters:nil forPage:0];
    [[STHTTPSessionManager manager] GET:requestUrl
                             parameters:nil
                                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                    if (completion) {
                                 
                                        NSMutableArray *rightMenuItems = [NSMutableArray array];
                                        
                                        for (NSDictionary*rightMenuDictionary in [responseObject objectForKey:@"content"]) {
                                            [rightMenuItems addObject:[[STRightMenuItemsModel alloc] initWithDictionary:rightMenuDictionary]];
                                        }
                                        
                                        
                                        for (STRightMenuItemsModel*rightModel in rightMenuItems) {
                                         
                                            if ([rightModel.title isEqualToString:@"Störungsmeldung"]) {
                                               rightModel.title =  @"Strassenlaterne defekt?";
                                            }
                                            
                                        }
                                        
                                        __block dispatch_group_t rightMenuChildrenDataGroup = NULL;
                                        
                                        // local block that downloads the children data for ids
                                        void (^downloadRightMenuItemChildrenBlock)(STRightMenuItemsModel *) = ^void(STRightMenuItemsModel *rightMenuItem) {
                                            if (rightMenuChildrenDataGroup == NULL) {
                                                rightMenuChildrenDataGroup = dispatch_group_create();
                                            }
                                            
                                            dispatch_group_enter(rightMenuChildrenDataGroup);
                                            NSString *url = [NSString stringWithFormat:@"/sinfo?id=%ld", rightMenuItem.modelId];
                                            [[STRequestsHandler sharedInstance] stadtInfoItemForUrl:url
                                                                                       mappingClass:[STRightMenuItemsModel class] withCompletion:^(NSArray *data, NSError *error) {
                                                                                           if (!error) {
                                                                                               NSMutableArray *newChildren = [NSMutableArray arrayWithArray:rightMenuItem.children];
                                                                                               
                                                                                               for (STRightMenuItemsModel *model in data) {
                                                                                                   [newChildren addObject:model];
                                                                                               }
                                                                                               
                                                                                               rightMenuItem.children = newChildren;
                                                                                           }
                                                                                           dispatch_group_leave(rightMenuChildrenDataGroup);
                                                                                       }];

                                        };
                                        
                                        for (STRightMenuItemsModel *rightMenuItem in rightMenuItems) {
                                            if ([rightMenuItem.type isEqualToString:@"sinfo_kat"]) {
                                                downloadRightMenuItemChildrenBlock(rightMenuItem);
                                            } else if ([rightMenuItem.type isEqualToString:@"sinfo_feed"]) {
                                                downloadRightMenuItemChildrenBlock(rightMenuItem);
                                            }
                                        
                                            if (rightMenuChildrenDataGroup != NULL) {
                                                dispatch_group_notify(rightMenuChildrenDataGroup, dispatch_get_main_queue(), ^{
                                                    completion(rightMenuItems,nil);
                                                });
                                            } else {
                                                completion(rightMenuItems, nil);
                                            }
                                        }
                                    } else {
                                        NSError *error = [NSError errorWithDomain:STOpenAPIErrorDomain
                                                                             code:0
                                                                         userInfo:nil];
                                        completion(nil, error);
                                    }
                                    
                                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                    //TODO
                                }];
}


-(void)postViewCouponWithOfferId:(NSInteger)offerId{
    
    NSString *url = [self buildUrl:[NSString stringWithFormat:@"/view-coupon?id=%ld&apiVersion=2",offerId] withParameters:nil forPage:0];

    [[STHTTPSessionManager manager] GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"HIT");

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];

    

}

-(void)postUseCouponWithOfferId:(NSInteger)offerId{
    
    NSString *url = [self buildUrl:[NSString stringWithFormat:@"/use-coupon?id=%ld&apiVersion=2",offerId] withParameters:nil forPage:0];
    [[STHTTPSessionManager manager] GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"HIT");
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)postSecondUseOfCouponWithOfferId:(NSInteger)offerId name:(NSString*)name{


    NSDictionary*parameters = @{@"id":[NSString stringWithFormat:@"%ld",offerId], @"cn":name,@"os":@"ios",@"knr":[[STAppSettingsManager sharedSettingsManager] activeCoupon]};
    
    STHTTPSessionManager*manager = [STHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:@"https://download.stappy.de/suewag_couponing/add.php" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"OK");
    }];
    
}


@end

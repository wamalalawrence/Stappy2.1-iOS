
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

- (NSMutableDictionary *)buildParamsForType:(FilterType)type {
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    NSArray *enabledFilters = [[Filters sharedInstance] filtersForType:type];
    params[@"filter"] = [enabledFilters componentsJoinedByString:@","];
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
    NSMutableDictionary* parameters = [self buildParamsForType:FilterTypeAngebote];
    [parameters addEntriesFromDictionary:params];
    
    //build the url with param here to test pagination
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString* serializedUrl = [manager.requestSerializer requestWithMethod:@"GET" URLString:requestUrl parameters:params error:nil].URL.absoluteString;
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
    NSMutableDictionary* parameters = [self buildParamsForType:FilterTypeEvents];
    [parameters addEntriesFromDictionary:params];
    [parameters removeObjectForKey:@"sort"]; // FIXME: temporary solution. In the future all the parameters
    // for the requests should be store in configuration file
    
    //build the url with param here to test pagination
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
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
                                        
                                        NSUInteger pageCount = [responseObject[@"pages"][@"pageCount"] integerValue];
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
    NSMutableDictionary* parameters = [self buildParamsForType:FilterTypeVereinsnews];
//    [parameters addEntriesFromDictionary:params];
    
    [params addEntriesFromDictionary:@{@"sort":@"DESC"}];
    
    //build the url with param here to test pagination
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
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
    NSMutableDictionary* parameters = [self buildParamsForType:FilterTypeLokalnews];
    [parameters addEntriesFromDictionary:params];
    
    //build the url with param here to test pagination
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
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
    NSMutableDictionary* parameters = [self buildParamsForType:FilterTypeTicker];
    [parameters addEntriesFromDictionary:params];
    
    //build the url with param here to test pagination
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
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
    
    [[AFHTTPSessionManager manager] GET:requestUrl
                             parameters:nil
                                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                    if (completion) {
                                        NSError *mtlError = nil;
                                        
                                        id data = responseObject[@"content"];
                                        if ([data isKindOfClass:[NSArray class]]) data = data[0];
                                        
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

//weather
-(void)weatherForCurrentDayAndForecastWithCompletion:(void(^)(NSArray*, NSArray*,id currentObservation, NSError*, NSError*))completion {
    NSString *weatherUrl = [[STAppSettingsManager sharedSettingsManager] backendValueForKey:@"weather.conditionsAndForecastData"];
    
    [[AFHTTPSessionManager manager] GET:weatherUrl
                             parameters:nil
     
                                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                    if (completion) {
                                        NSError *mtlError = nil;
                                        NSArray *hourlyCurrentDayForecasts = [MTLJSONAdapter modelsOfClass:[STWeatherHourlyModel class]
                                                                                             fromJSONArray:responseObject[@"hourly_forecast"]
                                                                                                     error:&mtlError];
                                        NSArray *daysForecasts = [MTLJSONAdapter modelsOfClass:[STWeatherModel class]
                                                                           fromJSONArray:responseObject[@"forecast"][@"simpleforecast"][@"forecastday"]
                                                                                        error:&mtlError];
                                        STWeatherCurrentObservation *currentObservation = [MTLJSONAdapter modelOfClass:[STWeatherCurrentObservation class ] fromJSONDictionary:responseObject[@"current_observation"] error:&mtlError];

                                        if (!mtlError) {
                                            completion(hourlyCurrentDayForecasts,daysForecasts,currentObservation,nil,nil);
                                        }
                                        else {
                                            NSError *error = [NSError errorWithDomain:STOpenAPIErrorDomain
                                                                                 code:1 userInfo:nil];
                                            completion(nil,nil,nil,error,error);
                                        }
                                    }

                                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                                    @throw [NSException exceptionWithName:@"NotHandledException" reason:@"Please add error handling." userInfo:nil];
                                    //TODO
                                }];
}

- (void)weatherForStartScreenWithCompletion:(void(^)(STWeatherCurrentObservation *, NSError *))completion {
    NSString *url = [[STAppSettingsManager sharedSettingsManager] backendValueForKey:@"weather.conditionsData"];

    [[AFHTTPSessionManager manager] GET:url
                             parameters:nil
                                success:^(NSURLSessionDataTask *_Nonnull task, id _Nonnull responseObject) {
                                    if (completion) {
                                        NSError *mtlError = nil;
                                        STWeatherCurrentObservation *currentObservation = [MTLJSONAdapter modelOfClass:[STWeatherCurrentObservation class ] fromJSONDictionary:responseObject[@"current_observation"] error:&mtlError];

                                        if (!mtlError) {
                                            completion(currentObservation,nil);
                                        }
                                        else {
                                            NSError *error = [NSError errorWithDomain:STOpenAPIErrorDomain
                                                                                 code:1 userInfo:nil];
                                            completion(nil,error);
                                        }
                                    }
                                }
                                failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                                    //TODO: error handling?
                                }];
}

- (AFHTTPRequestOperation *)drugstoresWithSuccess:(void (^)(NSArray <STDrugstoresModel *>*))success failure:(void (^)(NSError *error))failure {
    NSString *url = [self buildUrl:@"/apotheken" withParameters:nil forPage:0];
    return [[AFHTTPRequestOperationManager manager] GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        NSArray *drugstoresArray = [MTLJSONAdapter modelsOfClass:STDrugstoresModel.class
                                             fromJSONArray:responseObject[@"content"]
                                                          error:&error];
        if (error || drugstoresArray.count == 0) failure(error);
        else                                     success(drugstoresArray);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.cancelled) return;
        failure(error);
    }];
}

- (AFHTTPRequestOperation *)emergenciesWithSuccess:(void (^)(NSArray <STEmergenciesModel *>*))success failure:(void (^)(NSError *error))failure {
    return [[AFHTTPRequestOperationManager manager] GET:self.emergenciesUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        NSArray *emergenciesArray = [MTLJSONAdapter modelsOfClass:STEmergenciesModel.class
                                                    fromJSONArray:responseObject[@"apotheken"]
                                                            error:&error];
        if (error) failure(error);
        else if (emergenciesArray && emergenciesArray.count != 0)  success(emergenciesArray);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.cancelled) return;
        failure(error);
    }];
}

#pragma mark - Park houses

-(void)loadParkHousesWithCompletion:(void(^)(NSArray *, NSError *))completion failure:(void (^)(NSError *error))failure{

    NSString *parkingUrl = [[STAppSettingsManager sharedSettingsManager] backendValueForKey:@"parkHaus.url"];
    NSString* userName = [STAppSettingsManager sharedSettingsManager].userName;
    NSString* password = [STAppSettingsManager sharedSettingsManager].password;
     AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSURLCredential *credential = [NSURLCredential credentialWithUser:userName password:password persistence:NSURLCredentialPersistenceNone];
    
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:parkingUrl parameters:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCredential:credential];
    [operation setResponseSerializer:[AFJSONResponseSerializer alloc]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
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

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure: %@", error.description);
    }];
    [manager.operationQueue addOperation:operation];
}

- (void)parkHausDetailsForUrl:(NSString*)url withCompletion:(void(^)(STParkHausModel *, NSError *))completion {
    
    NSString *encodedUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSString* userName = [STAppSettingsManager sharedSettingsManager].userName;
    NSString* password = [STAppSettingsManager sharedSettingsManager].password;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSURLCredential *credential = [NSURLCredential credentialWithUser:userName password:password persistence:NSURLCredentialPersistenceNone];
    
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:encodedUrl parameters:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCredential:credential];
    [operation setResponseSerializer:[AFJSONResponseSerializer alloc]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary * objectDict = [responseObject objectForKey:@"parking_unit"];
        STParkHausModel* locationObject = [[STParkHausModel alloc] initWithDictionary:objectDict];
        completion(locationObject,nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure: %@", error.description);
    }];
    [manager.operationQueue addOperation:operation];
}


-(void)allElektroTankStationWithCompletion:(void(^)(NSArray *, NSError *))completion{
    
    NSString *url = [self buildUrl:@"/data/de.endios.stappy.trier/sinfo?id=80796&apiVersion=2" withParameters:nil forPage:0];;
    NSString* userName = [STAppSettingsManager sharedSettingsManager].userName;
    NSString* password = [STAppSettingsManager sharedSettingsManager].password;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSURLCredential *credential = [NSURLCredential credentialWithUser:userName password:password persistence:NSURLCredentialPersistenceNone];
    
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:url parameters:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCredential:credential];
    [operation setResponseSerializer:[AFJSONResponseSerializer alloc]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure: %@", error.description);
        completion(nil,error);
    }];
    [manager.operationQueue addOperation:operation];

}

-(void)parkenAvailabilityTrier:(void(^)(NSArray *, NSError *))completion{
    
    NSString *url = @"http://www.swt.de/parken.xml";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:url parameters:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setResponseSerializer:[AFXMLDictionaryResponseSerializer serializer]];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
 
        NSMutableArray*array = [NSMutableArray array];
        
        for (NSDictionary*dict in [responseObject objectForKey:@"parkhaus"]) {
            [array addObject:[STTrierParkingAvailability availabilityFromDictionary:dict]];
        }
        
        completion([array copy],nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil,error);

    }];
    
    [manager.operationQueue addOperation:operation];
}

-(void)allTankStationsWithCompletion:(void(^)(NSArray *, NSError *))completion{
    
    NSString *url = [self buildUrl:@"/data/de.endios.stappy.trier/sinfo?id=80797&apiVersion=2" withParameters:nil forPage:0];;
    NSString* userName = [STAppSettingsManager sharedSettingsManager].userName;
    NSString* password = [STAppSettingsManager sharedSettingsManager].password;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSURLCredential *credential = [NSURLCredential credentialWithUser:userName password:password persistence:NSURLCredentialPersistenceNone];
    
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:url parameters:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCredential:credential];
    [operation setResponseSerializer:[AFJSONResponseSerializer alloc]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
       
        
        
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
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure: %@", error.description);
        completion(nil,error);
    }];
    [manager.operationQueue addOperation:operation];
}


-(void)searchForAddress:(NSString*)address completion:(void(^)(NSArray *, NSError *))completion{
    
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?key=%@&input=%@&types=geocode&language=de",[[STAppSettingsManager sharedSettingsManager] backendValueForKey:@"fahrplan.fahrplan_api---GOOGLE.access_id"],address ];
 
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:url parameters:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setResponseSerializer:[AFJSONResponseSerializer alloc]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        STGoogleAutocompleteResponseModel*model = [[STGoogleAutocompleteResponseModel alloc]
                                                   initWithDictionary:responseObject];
        
        completion(model.predictions,nil);
    
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure: %@", error.description);
        completion(nil,error);
    }];
    [manager.operationQueue addOperation:operation];
}

-(void)placeLocationForId:(NSString*)placeId completion:(void(^)(STGoogleLocation*, NSError *error))completion{
    
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?key=%@&placeid=%@&language=de",[[STAppSettingsManager sharedSettingsManager] backendValueForKey:@"fahrplan.fahrplan_api---GOOGLE.access_id"],placeId ];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:url parameters:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setResponseSerializer:[AFJSONResponseSerializer alloc]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        STGoogleLocation*location = [[STGoogleLocation alloc] initWithDictionary:[[[responseObject objectForKey:@"result"] objectForKey:@"geometry"] objectForKey:@"location"]];
        
        completion(location,nil);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure: %@", error.description);
        completion(nil,error);
    }];
    [manager.operationQueue addOperation:operation];
}



-(void)allGeneralParkHausesWithCompletion:(void(^)(NSArray *, NSError *))completion{
    
    NSString *url = [self buildUrl:@"/data/de.endios.stappy.trier/sinfo?id=81236&apiVersion=2" withParameters:nil forPage:0];;
    NSString* userName = [STAppSettingsManager sharedSettingsManager].userName;
    NSString* password = [STAppSettingsManager sharedSettingsManager].password;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSURLCredential *credential = [NSURLCredential credentialWithUser:userName password:password persistence:NSURLCredentialPersistenceNone];
    
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:url parameters:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCredential:credential];
    [operation setResponseSerializer:[AFJSONResponseSerializer alloc]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
       
        
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
                        
                        STTrierParkingAvailability*av = filtered[0];
                        
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

        
     
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure: %@", error.description);
        completion(nil,error);
    }];
    [manager.operationQueue addOperation:operation];
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
    [[STHTTPSessionManager manager] GET:requestUrl
                             parameters:nil
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
-(void)settingsOptionsFromUrl:(NSString *)url andCompletion:(void (^)(NSArray *, NSError *))completion {
    NSString* requestUrl = [self buildUrl:url withParameters:nil forPage:0];
    [[STHTTPSessionManager manager] GET:requestUrl
                             parameters:nil
                                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                    if (completion) {
                                        NSMutableArray *settingsArray = [NSMutableArray array];
                                        NSDictionary *contentDict = responseObject[@"content"];
                                        if (contentDict) {
                                            // We go through all the keys in the dictionary to get the elements from server
                                            for (NSString *key in [contentDict allKeys]) {
                                                id childrenObject = [contentDict objectForKey:key];
                                                STLeftMenuSettingsModel * settingsModel = [[STLeftMenuSettingsModel alloc] init];
                                                settingsModel.type = key;
                                                [settingsModel loadSubItemsFromObject:childrenObject forFilterType:key];
                                                [settingsArray addObject:settingsModel];
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
    NSString *requestUrl = [self buildUrl:url withParameters:nil forPage:0];
    [[STHTTPSessionManager manager] GET:requestUrl
                             parameters:nil
                                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                    if (completion) {
                                        NSError *mtlError;
                                        NSArray *rightMenuItems = [MTLJSONAdapter modelsOfClass:[STRightMenuItemsModel class]
                                                                                          fromJSONArray:responseObject[@"content"]
                                                                                                  error:&mtlError];
                                        
                                        __block dispatch_group_t rightMenuChildrenDataGroup = NULL;
                                        
                                        // local block that downloads the children data for ids
                                        void (^downloadRightMenuItemChildrenBlock)(STRightMenuItemsModel *) = ^void(STRightMenuItemsModel *rightMenuItem) {
                                            if (rightMenuChildrenDataGroup == NULL) {
                                                rightMenuChildrenDataGroup = dispatch_group_create();
                                            }
                                            
                                            dispatch_group_enter(rightMenuChildrenDataGroup);
                                            NSString *url = [NSString stringWithFormat:@"/sinfo?id=%d", [rightMenuItem.modelId intValue]];
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
                                            if ([rightMenuItem.optionType isEqualToString:@"sinfo_kat"]) {
                                                downloadRightMenuItemChildrenBlock(rightMenuItem);
                                            } else if ([rightMenuItem.optionType isEqualToString:@"sinfo_feed"]) {
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

@end

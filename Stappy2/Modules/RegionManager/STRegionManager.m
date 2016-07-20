//
// Created by Denis Grebennicov on 23/05/16.
// Copyright (c) 2016 endios GmbH. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <AFNetworking/AFHTTPSessionManager.h>
#import "STRegionManager.h"
#import "STRegionService.h"
#import "Stappy2-Swift.h"

#define kRegionsFile @"regions-suewag.json"
#define kRegionsJSONIdentifier @"regions"

@interface STRegionManager () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation STRegionManager

+ (STRegionManager *)sharedInstance
{
    static STRegionManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (void)getRegionFromCurrentUserLocation { [self getCurrentUserPosition]; }

- (void)getCurrentUserPosition
{
    if([CLLocationManager locationServicesEnabled])
    {
        if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
        {
            [self setDefaultRegion];
        }

        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;

        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 &&
                [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse)
        {
            [_locationManager requestWhenInUseAuthorization]; // Will open an confirm dialog to get user's approval
        }
        else [_locationManager startUpdatingLocation];
    }
    else
    {
        [self setDefaultRegion];
    }
}



- (void)setDefaultRegion
{
        
    self.currentRegion = [[STAppSettingsManager sharedSettingsManager] defaultRegion];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"regionAdjusted" object:nil];
    
    if (self.currentRegion == nil) [NSException raise:@"current region is nil" format:@"Write the default region in mainmenu.json"];
}

- (NSArray *)regionsJSONArray
{
    NSString *fileName = [[kRegionsFile lastPathComponent] stringByDeletingPathExtension];
    NSString *fileExt = [kRegionsFile pathExtension];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExt];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *regionsDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    regionsDict = [regionsDict objectForKey:kRegionsJSONIdentifier];
    NSArray *jsonArray = [regionsDict allValues];
    return jsonArray;
}

- (NSString *)currentRegion
{
    if (_currentRegion == nil) [self setDefaultRegion];
    return _currentRegion;
}

- (void)setCurrentRegionFromRegionId:(NSNumber *)regionId
{
    NSArray *jsonArray = [self regionsJSONArray];

    BOOL isFound = NO;
    for (NSDictionary *region in jsonArray)
    {
        if ([regionId isEqualToNumber:region[@"id"]])
        {
            _currentRegion = region[@"name"];
               [[NSNotificationCenter defaultCenter] postNotificationName:@"regionAdjusted" object:nil];
            isFound = YES;
        }
    }
    
    if (!isFound)  [self setDefaultRegion];
}

- (NSArray<NSString *> *)selectedAndCurrentRegions
{
    NSMutableSet *result = [NSMutableSet set];

    NSArray<NSNumber *> *selectedRegions = [[Filters sharedInstance] filtersForType:FilterTypeRegionen];

    for (NSDictionary *region in [self regionsJSONArray])
    {
        for (NSNumber *regionId in selectedRegions)
        {
            if ([regionId isEqualToNumber:region[@"id"]])
            {
                [result addObject:region[@"name"]];
            }
        }
    }

    [result addObject:self.currentRegion];

    /**
     * set currentRegion to be at index 0
     */
    NSMutableArray *resultArray = [result.allObjects mutableCopy];
    NSInteger indexOfCurrentRegion = -1;

    int i;
    for (i = 0; i < resultArray.count; ++i)
    {
        NSString *region = resultArray[i];
        if ([region isEqualToString:self.currentRegion])
        {
            indexOfCurrentRegion = i;
            break;
        }
    }

    [resultArray exchangeObjectAtIndex:0 withObjectAtIndex:i];
    return resultArray;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{

    CLLocation *currentLocation = [locations objectAtIndex:0];
    
    NSDate*eventDate = currentLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    if (howRecent<-5.0) {
        return;
    }
    [_locationManager stopUpdatingLocation];

    [[STRegionService sharedInstance] getPostalCodeFromUserLocation:currentLocation.coordinate success:^(NSString *postalCode) {
        [[STRegionService sharedInstance] getRegionIdFromPostalCode:postalCode success:^(NSNumber *regionId) {
            [self setCurrentRegionFromRegionId:regionId];
        } failure:^(NSError *error) {
            [self setDefaultRegion];
        }];
    } failure:^(NSError *error) {
        [self setDefaultRegion];
    }];
}

- (void)locationManager:(CLLocationManager*)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status)
    {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusDenied:
            [self setDefaultRegion];
            break;

        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            [_locationManager startUpdatingLocation];
            break;
        default: break;
    }
}

#pragma mark - magic

-(NSString*)weatherStationForRegion:(NSString*)region{
    NSString*cityname = region;
    NSArray*regions = [self loadRegions];
    if (!regions) {
        return cityname;
    }
    for (NSDictionary*dict in regions) {
        if ([[dict valueForKey:@"name"] isEqualToString:cityname] && [[dict valueForKey:@"weatherStation"] length] >0) {
            cityname =[dict valueForKey:@"weatherStation"];
            break;
        }
    }
    return cityname;
}


-(NSDictionary*)positionForRegion:(NSString*)region{
    NSDictionary*position;
    NSArray*regions = [self loadRegions];
    if (!regions) {
        return position;
    }
    for (NSDictionary*dict in regions) {
        if ([[dict valueForKey:@"name"] isEqualToString:region] && [[dict valueForKey:@"weatherStation"] length] >0) {
           
            position = @{@"xPos":[dict valueForKey:@"xPos"], @"yPos":[dict valueForKey:@"yPos"]};
            
            break;
        }
    }
    return position;
}


- (NSArray*)loadRegions
{
    NSString*JSONFileName = [STAppSettingsManager sharedSettingsManager].regionJSONFileName;
    if (JSONFileName)
    {
        NSString *fileName = [[JSONFileName lastPathComponent] stringByDeletingPathExtension];
        NSString *fileExt = [JSONFileName pathExtension];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExt];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSDictionary*jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        jsonDict = [jsonDict objectForKey:@"regions"];
        NSArray *jsonArray = [jsonDict allValues];
        if (jsonArray)
        {
            NSMutableArray *newArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in jsonArray)
            {
                NSMutableDictionary *nextDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                [newArray addObject:nextDict];
            }
            return [NSArray arrayWithArray:newArray];
        }
    }
    
    return nil;
}



@end
//
//  AppDelegate.m
//  Stappy2
//
//  Created by Cynthia Codrea on 19/10/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "AppDelegate.h"
#import "STAppSettingsManager.h"
#import "STRequestsHandler.h"
#import "AFNetworkReachabilityManager.h"
#import "StLocalDataArchiever.h"
#import "AFNetworking.h"
#import "Utils.h"
#import "Defines.h"
#import "RandomImageView.h"
#import "Stappy2-Swift.h"

#import <Google/Analytics.h>


@interface AppDelegate ()

@end

@implementation AppDelegate

+ (UIFont *)kievitFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"KievitOffc" size:size];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSError *error = nil;
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }
    //Read mainmenu.json
    NSString* path = [[NSBundle mainBundle] pathForResource:@"mainmenu" ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:path];

    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if (error) {
        @throw [NSException exceptionWithName:@"mainmenu.json error" reason:@"mainmenu.json can't read." userInfo:nil];
    }
    
    [STAppSettingsManager sharedSettingsManager].configurationDictionary = dict;
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    if ([Utils connected]) {
        //get all left menu items before starting the app
        
        NSString* requestString = [[STRequestsHandler sharedInstance] buildPartnerUrl:@"/side-menu."];
        NSURL *url = [NSURL URLWithString:requestString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        
        NSURLResponse *response = nil;
        error = nil;
        NSData *dataLeftMenu = [NSURLConnection sendSynchronousRequest:urlRequest
                                
                                                     returningResponse:&response
                                                                 error:&error];
        if (!error) {
            NSDictionary* dictLeftMenu = [NSJSONSerialization JSONObjectWithData:dataLeftMenu options:kNilOptions error:nil];
            [STAppSettingsManager sharedSettingsManager].leftMenuItemsDictionary = dictLeftMenu;
        } else {
            [STAppSettingsManager sharedSettingsManager].leftMenuItemsDictionary = nil;
        }
        
        /**
         * Get the right menu items. 
         * Since it is implemented using dispatch_group_t I didn't want to make it somehow synchronously,
         * so I've decided to post a notification, when the download is finished.
         *
         * The download time is fast enough, so that there is almost no need for a notification, but in order to
         * be sure, the notification is sent.
         */
        [[STRequestsHandler sharedInstance] rightMenuItemsWithCompletion:^(NSArray *data, NSError *error) {
            if (!error) {
                [STAppSettingsManager sharedSettingsManager].rightMenuItems = data;
                [[NSNotificationCenter defaultCenter] postNotificationName:kRightMenuNotificationKey object:nil];
            }
        }];
        //same logic for werbung
        [[STRequestsHandler sharedInstance] werbungItemsWithCompletion:^(NSArray *data, NSError *error) {
            if (!error) {
                [STAppSettingsManager sharedSettingsManager].werbungItems = data;
                [[NSNotificationCenter defaultCenter] postNotificationName:kWerbungMenuNotificationKey object:nil];
            }
        }];
    }else{
        NSLog(@"Side-menu was not loaded from the backend. (No internet connection)");
    }
    
    /**
     * GarbageCalendarManager restores the previous state.
     * If necessary loads the data from the network
     */
    [GarbageCalendarManager sharedInstance];
    
    
    /**
     * Push notification registration
     * iOS>=8
     */
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
    }
    
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[Filters sharedInstance] saveFilters];
    [[StLocalDataArchiever sharedArchieverManager] saveAllFavorites];
    [[StLocalDataArchiever sharedArchieverManager] saveSearchItems];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Reset badge number
    if (application.applicationIconBadgeNumber>0) {
        application.applicationIconBadgeNumber = 0;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    [[Filters sharedInstance] saveFilters];
    [[StLocalDataArchiever sharedArchieverManager] saveAllFavorites];
    [[StLocalDataArchiever sharedArchieverManager] saveSearchItems];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSessionImage];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Push notifications

- (void)application:(UIApplication *)application
didRegisterUserNotificationSettings:(UIUserNotificationSettings *)settings
{
    NSLog(@"Registering device for push notifications..."); // iOS 8
    [[UIApplication sharedApplication]  registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to register: %@", error);
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier
forRemoteNotification:(NSDictionary *)notification completionHandler:(void(^)())completionHandler
{
    NSLog(@"Received Action push notification: %@, identifier: %@", notification, identifier); // iOS 8
    if (completionHandler) {
        completionHandler();
    }
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)notification
{
    NSLog(@"Received push notification: %@", notification); // iOS 7 and earlier
    
    
    }

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (alertView.tag == 999 && buttonIndex ==1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[STAppSettingsManager sharedSettingsManager].pushUrl]];

    }

}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    
    NSLog(@"Registration successful, bundle identifier: %@, device token: %@",
          [NSBundle.mainBundle bundleIdentifier], deviceToken);
    
    //Token cleanup
    NSString* token = [deviceToken description];
    token = [token stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"Token %@",token);
    NSString *bundleName = [NSBundle mainBundle].bundleIdentifier;
    NSString *baseUrl = [STAppSettingsManager sharedSettingsManager].baseUrl;
    NSString *url = [NSString stringWithFormat:@"%@/registertoken/%@/ios/%@?sandbox=0", baseUrl, bundleName, token];

    NSLog(@"Push Notifications URL: %@",url);

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *root = responseObject;
        
        NSLog(@"Push Notifications registered: %@",root);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error registering notification token : %@", error);
    }];
    
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler {
    
    NSLog(@"Received push notification: %@", userInfo);
}


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "endios.Stappy2" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Stappy2" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Stappy2.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}


#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end

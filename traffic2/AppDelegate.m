//
//  AppDelegate.m
//  traffic2
//
//  Created by Catherine Zhao on 2016-09-01.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import "AppDelegate.h"
#import "SecondViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UINavigationController *navCon = (UINavigationController *)self.window.rootViewController;
    SecondViewController *secondViewCon = navCon.viewControllers[1];
    [secondViewCon initWithPlist];
    
    UIMutableUserNotificationCategory *notificationCategory = [[UIMutableUserNotificationCategory alloc]init];
    NSSet *categories = [NSSet setWithObject:notificationCategory];
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:categories];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    UINavigationController *navCon = (UINavigationController *)self.window.rootViewController;
    SecondViewController *secondViewCon = navCon.viewControllers[1];
    [secondViewCon addDataToStorageWithCompletionHandler:^(NSString *result) {
        if ([result isEqualToString:@"success"]) {
            completionHandler(UIBackgroundFetchResultNewData);
        } else {
            completionHandler(UIBackgroundFetchResultFailed);
        }
    }];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(nonnull UIUserNotificationSettings *)notificationSettings {
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        [application registerForRemoteNotifications];
    }

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    const char *data = [deviceToken bytes];
    NSMutableString *token = [NSMutableString string];
    
    for (NSUInteger i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    UINavigationController *navCon = (UINavigationController *)self.window.rootViewController;
    SecondViewController *secondViewCon = navCon.viewControllers[1];
    secondViewCon.deviceId = token;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //NSLog(error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    UINavigationController *navCon = (UINavigationController *)self.window.rootViewController;
    SecondViewController *secondViewCon = navCon.viewControllers[1];
    [secondViewCon getTrafficTimeWithAppleMap:userInfo completionHandler:^(double trafficTime) {
        if ([application applicationState] == UIApplicationStateActive) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Traffic Time" message:[NSString stringWithFormat:@"Current Traffic Time:%imin for Route %@", (int)trafficTime, userInfo[@"name"]] preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action){
                                                           //Do Some action here
                                                           [alert dismissViewControllerAnimated:YES completion:NULL];
                                                       }];
            [alert addAction:ok];
            UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
            [vc presentViewController:alert animated:YES completion:nil];
            completionHandler(UIBackgroundFetchResultNewData);
        }else {
            completionHandler(UIBackgroundFetchResultNewData);
            UILocalNotification *localNotification = [[UILocalNotification alloc]init];
            localNotification.timeZone = [NSTimeZone localTimeZone];
            localNotification.fireDate = [NSDate date];
            localNotification.soundName = @"ping.aiff";
            localNotification.alertTitle = [NSString stringWithFormat:@"%@ Route", userInfo[@"name"]];
            localNotification.alertBody = [NSString stringWithFormat:@"Current Traffic Time: %imin for Route %@", (int)trafficTime, userInfo[@"routeName"]];
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

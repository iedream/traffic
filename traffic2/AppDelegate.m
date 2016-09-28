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
    
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if ([locationNotification.alertAction isEqualToString:@"loadTrafficTime"]) {
        NSLog(@"receive local");
        UINavigationController *navCon = (UINavigationController *)self.window.rootViewController;
        SecondViewController *secondViewCon = navCon.viewControllers[1];
        [secondViewCon getTrafficTimeWithAppleMap:locationNotification.userInfo completionHandler:^(double trafficTime) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Traffic Time" message:[NSString stringWithFormat:@"Current Traffic Time:%f for Route %@", trafficTime, locationNotification.userInfo[@"name"]] preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action){
                                                           //Do Some action here
                                                           [alert dismissViewControllerAnimated:YES completion:NULL];
                                                       }];
            [alert addAction:ok];
            
            [secondViewCon presentViewController:alert animated:YES completion:NULL];
        }];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"receive remote");
    
    if ([notification.alertAction isEqualToString:@"loadTrafficTime"]) {
        
        UINavigationController *navCon = (UINavigationController *)self.window.rootViewController;
        SecondViewController *secondViewCon = navCon.viewControllers[1];
        [secondViewCon getTrafficTimeWithAppleMap:notification.userInfo completionHandler:^(double trafficTime) {
            if ([application applicationState] == UIApplicationStateActive) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Traffic Time" message:[NSString stringWithFormat:@"Current Traffic Time:%i for Route %@", (int)trafficTime, notification.userInfo[@"name"]] preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action){
                                                               //Do Some action here
                                                               [alert dismissViewControllerAnimated:YES completion:NULL];
                                                           }];
                [alert addAction:ok];
                [secondViewCon presentViewController:alert animated:YES completion:NULL];
            }else {
                    UILocalNotification *localNotification = [[UILocalNotification alloc]init];
                    localNotification.timeZone = [NSTimeZone localTimeZone];
                    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
                    localNotification.alertBody = [NSString stringWithFormat:@"%@ Route", notification.userInfo[@"name"]];
                    localNotification.alertTitle = [NSString stringWithFormat:@"Current Traffic Time:%imin for Route %@", (int)trafficTime, notification.userInfo[@"name"]];
                    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            }
        }];
    }
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

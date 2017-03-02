//
//  AppDelegate.m
//  teeptrak
//
//  Created by jackson on 1/25/16.
//  Copyright © 2016 steve. All rights reserved.
//

#import "AppDelegate.h"
#import "FCUUID.h"
#import "Notification.h"
#import "AlarmDB.h"
#import "MainViewController.h"
#import "Constant.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define DEFAULT_DEVICE_TOKEN                    @"2222222222"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.m_strDeviceToken = DEFAULT_DEVICE_TOKEN;
    self.m_bReceivedNotification = false;
    m_bTapNotification = FALSE;
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:AppLanguage])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"en" forKey:AppLanguage];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"languageIdx"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"priorityIndex"];
    }

    
    //-- Set Notification
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }

    NSLog(@"My Device UUID is: %@", [FCUUID uuidForVendor]);
    
    return YES;
}

//get device token.
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"My token is: %@", newToken);
    
    self.m_strDeviceToken = newToken;
    [GlobalPool sharedObject].m_constant.m_deviceToken = newToken;
    
    [[NSUserDefaults standardUserDefaults] setObject:newToken forKey:@"deviceid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
    self.m_strDeviceToken = DEFAULT_DEVICE_TOKEN;
    [GlobalPool sharedObject].m_constant.m_deviceToken = DEFAULT_DEVICE_TOKEN;

}

//receive push notification(alarm message) from server and put it into schedul time zone.
- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    if (![GlobalPool sharedObject].m_bLoginSuccess) return;
    if (m_bTapNotification)
    {
        m_bTapNotification = FALSE;
        return;
    }
    
    NSLog(@"Received notification: %@", userInfo);
    
    //NSInteger badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeCount];
    /*aps =     {
        "alarm_type" = 2;
        alert = testjmd1;
        badge = 1;
        machine = "Machine 1";
        performance = 0;
        speed = "<null>";
        "triggering_date" = "15-02-2016 05:36:45+0000";
        content-available:1

    };*/
    Notification *recvAlarm = [[Notification alloc] init];
    id value;
    
    //convet alarm date to string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ssZ"];
    value = [[userInfo valueForKey:@"aps"] valueForKey:@"triggering_date"];
    recvAlarm.m_date = [dateFormatter dateFromString:value];

    recvAlarm.m_message = [[userInfo valueForKey:@"aps"] valueForKey:@"message"];
    recvAlarm.m_alarmName = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
    recvAlarm.m_machine = [[userInfo valueForKey:@"aps"] valueForKey:@"machine"];
    recvAlarm.m_performance = [[[userInfo valueForKey:@"aps"] valueForKey:@"performance"] integerValue];
    
    value = [[userInfo valueForKey:@"aps"] valueForKey:@"speed"];
    if (value != [NSNull null])
        recvAlarm.m_speed = [value integerValue];
    recvAlarm.m_alarmLevel = [[[userInfo valueForKey:@"aps"]valueForKey:@"alarm_type"] integerValue];
    recvAlarm.m_readStatus = ALARM_ARRIVAL;

    //record alarm message to database
    recvAlarm.m_id = [[AlarmDB dbInstance] saveNotification:recvAlarm];
    
//    if (recvAlarm.m_alarmLevel == 0){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AlarmNotification"
                                                            object:recvAlarm];
//    } else {
//        
//    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    m_bTapNotification = FALSE;
   
}

- (BOOL) didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return NO;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //NSInteger badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeCount];
    m_bTapNotification = TRUE;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

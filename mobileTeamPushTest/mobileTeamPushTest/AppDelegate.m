//
//  AppDelegate.m
//  mobileTeamPushTest
//
//  Created by steve benedick on 8/23/15.
//  Copyright (c) 2015 steve benedick. All rights reserved.
//

#import "AppDelegate.h"
#import "ADBMobile.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [ADBMobile setDebugLogging:YES];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    else {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
#pragma GCC diagnostic pop
    }
    
    NSDictionary *pushNotificationDictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (pushNotificationDictionary) {
        NSLog(@"we should be tracking a push click-through here");
        [ADBMobile trackAction:@"should be a push click through" data:nil];
        [ADBMobile trackPushMessageClickThrough:pushNotificationDictionary];
    }
    
    
    NSLog(@"didFinishLaunching launchOptions: %@", launchOptions);
    
    return YES;
}

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"deviceToken = %@", [deviceToken description]);
    if (deviceToken.length != 32) {
        return;
    }
    
    const unsigned char * charBytes = [deviceToken bytes];
    NSMutableString *goodToken = [NSMutableString stringWithCapacity:64];
    
    for (int i = 0; i < 32; i++) {
        [goodToken appendString:[NSString stringWithFormat:@"%02x", charBytes[i]]];
    }
    NSLog(@"goodToken = %@", goodToken);
    [ADBMobile trackAction:@"pushToken" data:@{@"pushToken":goodToken}];
    [ADBMobile setPushIdentifier:deviceToken];
    
    ViewController *vc = (ViewController *)self.window.rootViewController;
    vc.lblPushToken.text = goodToken;
}
    
- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"failed - %@", error.localizedDescription);
    [ADBMobile setPushIdentifier:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //if the user has disabled push notifications, set the push identifier to nil in the Adobe Mobile SDK
    //for devices running iOS 8.0+
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        if (![application isRegisteredForRemoteNotifications]) {
            [ADBMobile setPushIdentifier:nil];
        }
    }
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    else if ([application enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone) {
        [ADBMobile setPushIdentifier:nil];
    }
#pragma GCC diagnostic pop
}
    
// ****************************************************************
// start target < iOS 7
// ****************************************************************
// if targeting an os lower than 7, have to use:
// app resuming from background - application:didReceiveRemoteNotification:
// app being launched - sdk handles via UIApplicationDidFinishLaunchingNotification handler
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // only send the hit if the app is not active
    if (application.applicationState == UIApplicationStateInactive) {
        [ADBMobile trackPushMessageClickThrough:userInfo];
    }
}

// ****************************************************************
// end target < iOS 7
// ****************************************************************
    
    
// ****************************************************************
// start target >= iOS 7
// ****************************************************************
// for iOS 7 and newer, this method will be called whether the app is resuming or being launched
// the sdk has no need to subscribe to UIApplicationDidFinishLaunchingNotification if targer is >= 7.0
// also need to enable Background Modes (Remote Notifications)
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"===================================================================");
    NSLog(@"in didReceiveRemoteNotification");
    NSString *appStateString = application.applicationState == UIApplicationStateInactive ? @"Inactive" : (application.applicationState == UIApplicationStateActive ? @"Active" : @"Background");
    [ADBMobile trackAction:@"didReceiveRemoteNotification" data:@{@"appState":appStateString}];
    
    // only send the hit if the app is not active
    if (application.applicationState == UIApplicationStateInactive) {
        NSLog(@"calling trackPushMessageClickThrough");
        [ADBMobile trackAction:@"push from didReceive" data:nil];
        [ADBMobile trackPushMessageClickThrough:userInfo];
    }
    
    completionHandler(UIBackgroundFetchResultNoData);
}
// ****************************************************************
// end target >= iOS 7
// ****************************************************************

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    [ADBMobile trackAdobeDeepLink:url];
    NSLog(@"deeplink processed: %@", url);
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options {
    [ADBMobile trackAdobeDeepLink:url];
    NSLog(@"deeplink processed: %@", url);
    
    return YES;
}

@end

//
//  AppDelegate.m
//  GoodNight
//
//  Created by Anthony Agatiello on 6/22/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "GammaController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSDictionary *defaultsToRegister = @{@"enabled": @NO,
                                         @"maxOrange": @0.4,
                                         @"colorChangingEnabled": @YES,
                                         @"redValue": @1.0,
                                         @"greenValue": @1.0,
                                         @"blueValue": @1.0,
                                         @"dimEnabled": @NO,
                                         @"dimLevel": @1.0,
                                         @"rgbEnabled": @NO,
                                         @"lastAutoChangeDate": [NSDate distantPast],
                                         @"autoStartHour": @19,
                                         @"autoStartMinute": @0,
                                         @"autoEndHour": @7,
                                         @"autoEndMinute": @0,
                                         @"suspendEnabled": @YES,
                                         @"forceTouchEnabled": @YES,
                                         @"tempForceTouch": @YES,
                                         @"dimForceTouch": @NO,
                                         @"rgbForceTouch": @NO};
    
    [userDefaults registerDefaults:defaultsToRegister];
    
    if ([application respondsToSelector:@selector(shortcutItems)] && application.shortcutItems.count > 0 && [userDefaults boolForKey:@"forceTouchEnabled"]) {
        [AppDelegate setShortcutItems];
    }
    
    [GammaController autoChangeOrangenessIfNeeded];
    
    [application setMinimumBackgroundFetchInterval:900];
    
    return YES;
}

+ (void)setShortcutItems {
    UIApplication *application = [UIApplication sharedApplication];
    [application setShortcutItems:nil];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") && [userDefaults boolForKey:@"forceTouchEnabled"]) {
        NSString *turnOnText = @"Turn on this adjustment";
        NSString *turnOffText = @"Turn off this adjustment";
        
        UIApplicationShortcutIcon *enableIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"enable-switch"];
        UIApplicationShortcutIcon *disableIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"disable-switch"];
        
        UIMutableApplicationShortcutItem *shortcut = nil;
        NSString *shortcutType = nil;
        
        if ([userDefaults boolForKey:@"tempForceTouch"]) {
            shortcutType = @"temperatureForceTouchAction";
            
            if (![userDefaults boolForKey:@"enabled"]) {
                shortcut = [[UIMutableApplicationShortcutItem alloc] initWithType:shortcutType localizedTitle:@"Enable Temperature" localizedSubtitle:turnOnText icon:enableIcon userInfo:nil];
            }
            else if ([userDefaults boolForKey:@"enabled"])  {
                shortcut = [[UIMutableApplicationShortcutItem alloc] initWithType:shortcutType localizedTitle:@"Disable Temperature" localizedSubtitle:turnOffText icon:disableIcon userInfo:nil];
            }
        }
        
        else if ([userDefaults boolForKey:@"dimForceTouch"]) {
            shortcutType = @"dimForceTouchAction";
            
            if (![userDefaults boolForKey:@"dimEnabled"]) {
                shortcut = [[UIMutableApplicationShortcutItem alloc] initWithType:shortcutType localizedTitle:@"Enable Dim" localizedSubtitle:turnOnText icon:enableIcon userInfo:nil];
            }
            else if ([userDefaults boolForKey:@"dimEnabled"]) {
                shortcut = [[UIMutableApplicationShortcutItem alloc] initWithType:shortcutType localizedTitle:@"Disable Dim" localizedSubtitle:turnOffText icon:disableIcon userInfo:nil];
            }
        }
        
        else if ([userDefaults boolForKey:@"rgbForceTouch"]) {
            shortcutType = @"rgbForceTouchAction";
            
            if (![userDefaults boolForKey:@"rgbEnabled"]) {
                shortcut = [[UIMutableApplicationShortcutItem alloc] initWithType:shortcutType localizedTitle:@"Enable Color" localizedSubtitle:turnOnText icon:enableIcon userInfo:nil];
            }
            else if ([userDefaults boolForKey:@"rgbEnabled"]) {
                shortcut = [[UIMutableApplicationShortcutItem alloc] initWithType:shortcutType localizedTitle:@"Disable Color" localizedSubtitle:turnOffText icon:disableIcon userInfo:nil];
            }
        }
        if (shortcut != nil && enableIcon != nil && disableIcon != nil && shortcutType != nil && turnOnText != nil && turnOffText != nil && [application respondsToSelector:@selector(setShortcutItems:)]) {
            [application setShortcutItems:@[shortcut]];
        }
    }
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    if ([shortcutItem.type isEqualToString:@"temperatureForceTouchAction"]) {
        if ([userDefaults boolForKey:@"enabled"]) {
            [GammaController disableOrangenessWithDefaults:YES key:@"enabled"];
        }
        else if (![userDefaults boolForKey:@"enabled"]) {
            [GammaController enableOrangenessWithDefaults:YES];
        }
    }
    else if ([shortcutItem.type isEqualToString:@"dimForceTouchAction"]) {
        if ([userDefaults boolForKey:@"dimEnabled"]) {
            [GammaController disableOrangenessWithDefaults:YES key:@"dimEnabled"];
        }
        else if (![userDefaults boolForKey:@"dimEnabled"]) {
            [GammaController enableDimness];
        }
    }
    else if ([shortcutItem.type isEqualToString:@"rgbForceTouchAction"]) {
        if ([userDefaults boolForKey:@"rgbEnabled"]) {
            [GammaController disableOrangenessWithDefaults:YES key:@"rgbEnabled"];
        }
        else if (![userDefaults boolForKey:@"rgbEnabled"]) {
            [GammaController setGammaWithCustomValues];
        }
    }
    if ([userDefaults boolForKey:@"suspendEnabled"]) {
        [[UIApplication sharedApplication] performSelector:@selector(suspend)];
        [NSThread sleepForTimeInterval:0.5];
        exit(0);
    }
    [AppDelegate setShortcutItems];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    [GammaController autoChangeOrangenessIfNeeded];
    completionHandler(UIBackgroundFetchResultNewData);
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

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
#import "ForceTouchController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSString *defaultsPath = [[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"];
    NSDictionary *defaultsToRegister = [NSDictionary dictionaryWithContentsOfFile:defaultsPath];
    [groupDefaults registerDefaults:defaultsToRegister];
    
    [GammaController autoChangeOrangenessIfNeededWithTransition:NO];
    [self registerForNotifications];
    [AppDelegate updateNotifications];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") && self.window.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable){
        [ForceTouchController sharedInstance];
    }
    
    if (application.applicationState == UIApplicationStateBackground) {
        [self installBackgroundTask:application];
    }

    [self.window makeKeyAndVisible];
    [self displaySplashAnimation];
    
    return YES;
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    BOOL handledShortcutItem = [ForceTouchController handleShortcutItem:shortcutItem];
    [ForceTouchController exitIfKeyEnabled];
    completionHandler(handledShortcutItem);
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [groupDefaults setObject:[NSDate date] forKey:@"lastBackgroundCheck"];
    [groupDefaults synchronize];
    [GammaController autoChangeOrangenessIfNeededWithTransition:YES];
    [NSThread sleepForTimeInterval:5.0];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)displaySplashAnimation {
    UIView *splashView = [[UIView alloc] initWithFrame:self.window.frame];
    splashView.backgroundColor = [UIColor whiteColor];
    UIImageView *logoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"launch"]];
    [splashView addSubview:logoImage];
    
    logoImage.contentMode = UIViewContentModeCenter;
    CGRect frame = logoImage.frame;
    frame.origin.x = self.window.frame.size.width/2 - frame.size.width/2;
    frame.origin.y = self.window.frame.size.height/2 - frame.size.height/2;
    logoImage.frame = frame;
    
    [self.window addSubview:splashView];
    
    float animationDuration = 0.25;
    [UIView animateWithDuration:animationDuration
            delay:0.25
            options:UIViewAnimationOptionCurveEaseInOut
            animations:^{
                logoImage.layer.transform = CATransform3DMakeScale(0.8, 0.8, 1.0);
            }
            completion:^(BOOL finished){
                [UIView animateWithDuration:animationDuration
                        delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                        animations:^{
                            splashView.alpha = 0;
                            logoImage.layer.transform = CATransform3DMakeScale(2.0, 2.0, 1.0);
                        }
                        completion:^(BOOL finished){
                            [splashView removeFromSuperview];
                        }
                ];
            }
     ];
}

- (void)registerForNotifications {
    if ([app respondsToSelector:@selector(registerUserNotificationSettings:)]){
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [app registerUserNotificationSettings:settings];
    }
}

+ (void)updateNotifications {
    NSString *bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    
    [app cancelAllLocalNotifications];
    
    if ([groupDefaults boolForKey:@"colorChangingEnabled"]){
        
        UILocalNotification *enableNotification = [[UILocalNotification alloc] init];
        
        if (enableNotification == nil) {
            return;
        }
        
        NSDateComponents *compsForEnable = [[NSDateComponents alloc] init];
        [compsForEnable setHour:[groupDefaults integerForKey:@"autoStartHour"]];
        [compsForEnable setMinute:[groupDefaults integerForKey:@"autoStartMinute"]];
        [enableNotification setSoundName:UILocalNotificationDefaultSoundName];
        if ([enableNotification respondsToSelector:@selector(setAlertTitle:)]){
            [enableNotification setAlertTitle:bundleName];
        }
        [enableNotification setAlertBody:[NSString stringWithFormat:@"Time to enable %@!", bundleName]];
        [enableNotification setTimeZone:[NSTimeZone defaultTimeZone]];
        [enableNotification setFireDate:[[NSCalendar currentCalendar] dateFromComponents:compsForEnable]];
        [enableNotification setRepeatInterval:NSCalendarUnitDay];
        
        UILocalNotification *disableNotification = [[UILocalNotification alloc] init];
        
        if (disableNotification == nil) {
            return;
        }
        
        NSDateComponents *compsForDisable = [[NSDateComponents alloc] init];
        [compsForDisable setHour:[groupDefaults integerForKey:@"autoEndHour"]];
        [compsForDisable setMinute:[groupDefaults integerForKey:@"autoEndMinute"]];
        [disableNotification setSoundName:UILocalNotificationDefaultSoundName];
        if ([disableNotification respondsToSelector:@selector(setAlertTitle:)]){
            [disableNotification setAlertTitle:bundleName];
        }
        [disableNotification setAlertBody:[NSString stringWithFormat:@"Time to disable %@!", bundleName]];
        [disableNotification setTimeZone:[NSTimeZone defaultTimeZone]];
        [disableNotification setFireDate:[[NSCalendar currentCalendar] dateFromComponents:compsForDisable]];
        [disableNotification setRepeatInterval:NSCalendarUnitDay];
        
        [app scheduleLocalNotification:enableNotification];
        [app scheduleLocalNotification:disableNotification];
    }
    
    if ([groupDefaults boolForKey:@"colorChangingEnabled"] || [groupDefaults boolForKey:@"colorChangingLocationEnabled"]){
        if ([groupDefaults boolForKey:@"colorChangingNightEnabled"]) {
            
            UILocalNotification *enableNightNotification = [[UILocalNotification alloc] init];
            
            if (enableNightNotification == nil) {
                return;
            }
            
            NSDateComponents *compsForNightEnable = [[NSDateComponents alloc] init];
            [compsForNightEnable setHour:[groupDefaults integerForKey:@"nightStartHour"]];
            [compsForNightEnable setMinute:[groupDefaults integerForKey:@"nightStartMinute"]];
            [enableNightNotification setSoundName:UILocalNotificationDefaultSoundName];
            if ([enableNightNotification respondsToSelector:@selector(setAlertTitle:)]){
                [enableNightNotification setAlertTitle:bundleName];
            }
            [enableNightNotification setAlertBody:[NSString stringWithFormat:@"Time to enable night mode!"]];
            [enableNightNotification setTimeZone:[NSTimeZone defaultTimeZone]];
            [enableNightNotification setFireDate:[[NSCalendar currentCalendar] dateFromComponents:compsForNightEnable]];
            [enableNightNotification setRepeatInterval:NSCalendarUnitDay];
            
            UILocalNotification *disableNightNotification = [[UILocalNotification alloc] init];
            
            if (disableNightNotification == nil) {
                return;
            }
            
            NSDateComponents *compsForNightDisable = [[NSDateComponents alloc] init];
            [compsForNightDisable setHour:[groupDefaults integerForKey:@"nightEndHour"]];
            [compsForNightDisable setMinute:[groupDefaults integerForKey:@"nightEndMinute"]];
            [disableNightNotification setSoundName:UILocalNotificationDefaultSoundName];
            if ([disableNightNotification respondsToSelector:@selector(setAlertTitle:)]){
                [disableNightNotification setAlertTitle:bundleName];
            }
            [disableNightNotification setAlertBody:[NSString stringWithFormat:@"Time to disable night mode!"]];
            [disableNightNotification setTimeZone:[NSTimeZone defaultTimeZone]];
            [disableNightNotification setFireDate:[[NSCalendar currentCalendar] dateFromComponents:compsForNightDisable]];
            [disableNightNotification setRepeatInterval:NSCalendarUnitDay];
            
            [app scheduleLocalNotification:enableNightNotification];
            [app scheduleLocalNotification:disableNightNotification];
        }
    }
}

- (BOOL) installBackgroundTask:(UIApplication *)application{
    if (![groupDefaults boolForKey:@"colorChangingEnabled"] && ![groupDefaults boolForKey:@"colorChangingLocationEnabled"]) {
        [application clearKeepAliveTimeout];
        [application setMinimumBackgroundFetchInterval:86400];
        return NO;
    }
    
    [application setMinimumBackgroundFetchInterval:900];
    
    BOOL result = [app setKeepAliveTimeout:600 handler:^{
        [groupDefaults setObject:[NSDate date] forKey:@"lastBackgroundCheck"];
        [groupDefaults synchronize];
        [GammaController autoChangeOrangenessIfNeededWithTransition:YES];
        [NSThread sleepForTimeInterval:5.0];
    }];
    return result;
}

+ (BOOL)checkAlertNeededWithViewController:(UIViewController*)vc andExecutionBlock:(void(^)(UIAlertAction *action))block forKeys:(NSString *)firstKey, ... {
    
    va_list args;
    va_start(args, firstKey);
    BOOL adjustmentsEnabled = [GammaController adjustmentForKeysEnabled:firstKey withParameters:args];
    va_end(args);
    
    if (adjustmentsEnabled) {
        NSString *title = @"Error";
        NSString *message = @"You may only use one adjustment at a time. Please disable any other adjustments before enabling this one.";
        NSString *cancelButton = @"Cancel";
        NSString *disableButton = @"Disable";
        
        if (NSClassFromString(@"UIAlertController") != nil) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:cancelButton style:UIAlertActionStyleCancel handler:nil]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:disableButton style:UIAlertActionStyleDestructive handler:block]];
            
            [vc presentViewController:alertController animated:YES completion:nil];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButton otherButtonTitles:nil];
            
            [alertView show];
        }
    }
    
    return adjustmentsEnabled;
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [GammaController autoChangeOrangenessIfNeededWithTransition:YES];
    [ForceTouchController exitIfKeyEnabled];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id) annotation {
    if ([url.scheme isEqualToString: @"goodnight"]) {
        if ([url.host isEqualToString: @"enable"] && ![groupDefaults boolForKey:@"enabled"]) {
            [GammaController enableOrangenessWithDefaults:YES transition:YES];
            if ([[groupDefaults objectForKey:@"keyEnabled"] isEqualToString:@"0"]) {
                [GammaController suspendApp];
            }
        }
        else if ([url.host isEqualToString: @"disable"] && [groupDefaults boolForKey:@"enabled"]) {
            [GammaController disableOrangeness];
            if ([[groupDefaults objectForKey:@"keyEnabled"] isEqualToString:@"0"]) {
                [GammaController suspendApp];
            }
        }
    }
    return NO;
}

+ (id)initWithIdentifier:(NSString *)identifier {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:identifier];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self installBackgroundTask:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [application clearKeepAliveTimeout];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

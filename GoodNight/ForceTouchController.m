//
//  ForceTouchController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 10/20/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

@implementation ForceTouchController

+ (UIApplicationShortcutItem *)shortcutItemForCurrentState {
    UIMutableApplicationShortcutItem *shortcut = nil;
    NSString *shortcutType = nil;
    NSString *turnOnText = @"Turn on this adjustment";
    NSString *turnOffText = @"Turn off this adjustment";
    
    UIApplicationShortcutIcon *enableIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"enable-switch"];
    UIApplicationShortcutIcon *disableIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"disable-switch"];
    
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
    return shortcut;
}

+ (void)updateShortcutItems {
    UIApplication *application = [UIApplication sharedApplication];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") && [application respondsToSelector:@selector(shortcutItems)] && [application respondsToSelector:@selector(setShortcutItems:)]) {
        if ([userDefaults boolForKey:@"forceTouchEnabled"]) {
            UIApplicationShortcutItem *shortcut = [ForceTouchController shortcutItemForCurrentState];
            if (shortcut != nil) {
                [application setShortcutItems:@[shortcut]];
            }
        }
        else {
            [application setShortcutItems:nil];
        }
    }
}

+ (BOOL)handleShortcutItem:(UIApplicationShortcutItem *)shortcutItem {
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
    if ([userDefaults boolForKey:@"suspendEnabled"] && [[userDefaults objectForKey:@"keyEnabled"] isEqualToString:@"0"]) {
        [[UIApplication sharedApplication] performSelector:@selector(suspend)];
        [NSThread sleepForTimeInterval:0.5];
        exit(0);
    }
    return NO;
}

@end
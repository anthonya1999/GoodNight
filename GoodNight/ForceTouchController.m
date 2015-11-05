//
//  ForceTouchController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 10/20/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

@implementation ForceTouchController

+ (UIApplicationShortcutItem *)shortcutItemForCurrentState {
    NSString *shortcutType, *shortcutTitle, *shortcutSubtitle, *iconTemplate = nil;
    
    static NSString * const turnOnText = @"Turn on this adjustment";
    static NSString * const turnOffText = @"Turn off this adjustment";
    
    if ([userDefaults boolForKey:@"tempForceTouch"]) {
        shortcutType = @"temperatureForceTouchAction";
        
        if (![userDefaults boolForKey:@"enabled"]) {
            forceTouchActionEnabled = NO;
            shortcutTitle = @"Enable Temperature";
        }
        else if ([userDefaults boolForKey:@"enabled"])  {
            forceTouchActionEnabled = YES;
            shortcutTitle = @"Disable Temperature";
        }
    }
    
    else if ([userDefaults boolForKey:@"dimForceTouch"]) {
        shortcutType = @"dimForceTouchAction";
        
        if (![userDefaults boolForKey:@"dimEnabled"]) {
            forceTouchActionEnabled = NO;
            shortcutTitle = @"Enable Dimness";
        }
        else if ([userDefaults boolForKey:@"dimEnabled"]) {
            forceTouchActionEnabled = YES;
            shortcutTitle = @"Disable Dimness";
        }
    }
    
    else if ([userDefaults boolForKey:@"rgbForceTouch"]) {
        shortcutType = @"rgbForceTouchAction";
        
        if (![userDefaults boolForKey:@"rgbEnabled"]) {
            forceTouchActionEnabled = NO;
            shortcutTitle = @"Enable Color";
        }
        else if ([userDefaults boolForKey:@"rgbEnabled"]) {
            forceTouchActionEnabled = YES;
            shortcutTitle = @"Disable Color";
        }
    }
    
    if (forceTouchActionEnabled == NO) {
        shortcutSubtitle = turnOnText;
        iconTemplate = @"enable-switch";
    }
    else if (forceTouchActionEnabled == YES) {
        shortcutSubtitle = turnOffText;
        iconTemplate = @"disable-switch";
    }
    
    UIApplicationShortcutIcon *shortcutIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:iconTemplate];
    UIMutableApplicationShortcutItem *shortcut = [[UIMutableApplicationShortcutItem alloc] initWithType:shortcutType localizedTitle:shortcutTitle localizedSubtitle:shortcutSubtitle icon:shortcutIcon userInfo:nil];
    
    return shortcut;
}

+ (void)updateShortcutItems {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") && [app respondsToSelector:@selector(shortcutItems)] && [app respondsToSelector:@selector(setShortcutItems:)]) {
        if ([userDefaults boolForKey:@"forceTouchEnabled"]) {
            UIApplicationShortcutItem *shortcut = [self shortcutItemForCurrentState];
            if (shortcut != nil) {
                NSArray *shortcutArray = @[shortcut];
                if (shortcutArray.count > 0) {
                    [app setShortcutItems:shortcutArray];
                }
            }
        }
        else {
            [app setShortcutItems:nil];
        }
    }
}

+ (BOOL)handleShortcutItem:(UIApplicationShortcutItem *)shortcutItem {
    if ([shortcutItem.type isEqualToString:@"temperatureForceTouchAction"]) {
        if ([userDefaults boolForKey:@"enabled"]) {
            [GammaController disableOrangenessWithDefaults:YES key:@"enabled" transition:YES];
        }
        else if (![userDefaults boolForKey:@"enabled"]) {
            [GammaController enableOrangenessWithDefaults:YES transition:YES];
        }
    }
    else if ([shortcutItem.type isEqualToString:@"dimForceTouchAction"]) {
        if ([userDefaults boolForKey:@"dimEnabled"]) {
            [GammaController disableOrangenessWithDefaults:YES key:@"dimEnabled" transition:NO];
        }
        else if (![userDefaults boolForKey:@"dimEnabled"]) {
            [GammaController enableDimness];
        }
    }
    else if ([shortcutItem.type isEqualToString:@"rgbForceTouchAction"]) {
        if ([userDefaults boolForKey:@"rgbEnabled"]) {
            [GammaController disableOrangenessWithDefaults:YES key:@"rgbEnabled" transition:NO];
        }
        else if (![userDefaults boolForKey:@"rgbEnabled"]) {
            [GammaController setGammaWithCustomValues];
        }
    }
    return NO;
}

+ (void)exitIfKeyEnabled {
    if ([userDefaults boolForKey:@"suspendEnabled"] && [[userDefaults objectForKey:@"keyEnabled"] isEqualToString:@"0"]) {
        [GammaController suspendApp];
    }
}

@end
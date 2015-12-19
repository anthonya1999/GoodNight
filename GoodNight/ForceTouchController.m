//
//  ForceTouchController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 10/20/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "ForceTouchController.h"
#import "GammaController.h"

@implementation ForceTouchController

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken = 0;
    static ForceTouchController *sharedForceTouchController = nil;
    
    dispatch_once(&onceToken, ^{
        sharedForceTouchController = [[self alloc] init];
        [userDefaults addObserver:sharedForceTouchController forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:NULL];
        [userDefaults addObserver:sharedForceTouchController forKeyPath:@"dimEnabled" options:NSKeyValueObservingOptionNew context:NULL];
        [userDefaults addObserver:sharedForceTouchController forKeyPath:@"rgbEnabled" options:NSKeyValueObservingOptionNew context:NULL];
        [userDefaults addObserver:sharedForceTouchController forKeyPath:@"whitePointEnabled" options:NSKeyValueObservingOptionNew context:NULL];
        [userDefaults addObserver:sharedForceTouchController forKeyPath:@"keyEnabled" options:NSKeyValueObservingOptionNew context:NULL];
    });
    
    return sharedForceTouchController;
}

- (void)dealloc {
    [userDefaults removeObserver:self forKeyPath:@"enabled"];
    [userDefaults removeObserver:self forKeyPath:@"dimEnabled"];
    [userDefaults removeObserver:self forKeyPath:@"rgbEnabled"];
    [userDefaults removeObserver:self forKeyPath:@"whitePointEnabled"];
    [userDefaults removeObserver:self forKeyPath:@"keyEnabled"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [ForceTouchController updateShortcutItems];
}

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
    
    else if ([userDefaults boolForKey:@"whitePointForceTouch"]) {
        shortcutType = @"whitePointForceTouchAction";
        
        if (![userDefaults boolForKey:@"whitePointEnabled"]) {
            forceTouchActionEnabled = NO;
            shortcutTitle = @"Enable White Point";
        }
        else if ([userDefaults boolForKey:@"whitePointEnabled"]) {
            forceTouchActionEnabled = YES;
            shortcutTitle = @"Disable White Point";
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
            [GammaController disableOrangeness];
        }
        else if (![userDefaults boolForKey:@"enabled"]) {
            if (![GammaController adjustmentForKeysEnabled:@"dimEnabled", @"rgbEnabled", @"whitePointEnabled", nil]) {
                [GammaController enableOrangenessWithDefaults:YES transition:YES];
            }
            else {
                [self showFailedAlertWithKey:@"enabled"];
            }
        }
    }
    else if ([shortcutItem.type isEqualToString:@"dimForceTouchAction"]) {
        if ([userDefaults boolForKey:@"dimEnabled"]) {
            [GammaController disableDimness];
        }
        else if (![userDefaults boolForKey:@"dimEnabled"]) {
            if (![GammaController adjustmentForKeysEnabled:@"enabled", @"rgbEnabled", @"whitePointEnabled", nil]) {
                [GammaController enableDimness];
            }
            else {
                [self showFailedAlertWithKey:@"dimEnabled"];
            }
        }
    }
    else if ([shortcutItem.type isEqualToString:@"rgbForceTouchAction"]) {
        if ([userDefaults boolForKey:@"rgbEnabled"]) {
            [GammaController disableColorAdjustment];
        }
        else if (![userDefaults boolForKey:@"rgbEnabled"]) {
            if (![GammaController adjustmentForKeysEnabled:@"enabled", @"dimEnabled", @"whitePointEnabled", nil]) {
                [GammaController setGammaWithCustomValues];
            }
            else {
                [self showFailedAlertWithKey:@"rgbEnabled"];
            }
        }
    }
    else if ([shortcutItem.type isEqualToString:@"whitePointForceTouchAction"]) {
        if ([userDefaults boolForKey:@"whitePointEnabled"]) {
            [GammaController resetWhitePoint];
            [userDefaults setBool:NO forKey:@"whitePointEnabled"];
        }
        else if (![userDefaults boolForKey:@"whitePointEnabled"]) {
            if (![GammaController adjustmentForKeysEnabled:@"enabled", @"dimEnabled", @"rgbEnabled", nil]) {
                [GammaController setWhitePoint:[userDefaults boolForKey:@"whitePointValue"]];
                [userDefaults setBool:YES forKey:@"whitePointEnabled"];
            }
            else {
                [self showFailedAlertWithKey:@"whitePointEnabled"];
            }
        }
    }
    return NO;
}

+ (void)exitIfKeyEnabled {
    if ([userDefaults boolForKey:@"suspendEnabled"] && [[userDefaults objectForKey:@"keyEnabled"] isEqualToString:@"0"]) {
        [GammaController suspendApp];
    }
}


+ (void)showFailedAlertWithKey:(NSString *)key {
    [userDefaults setObject:@"1" forKey:@"keyEnabled"];
    [userDefaults setBool:NO forKey:key];
    [userDefaults synchronize];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You may only use one adjustment at a time. Please disable any other adjustments before enabling this one." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
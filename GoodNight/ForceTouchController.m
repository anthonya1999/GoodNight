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
        
        NSUserDefaults *defaults = userDefaults;
        [defaults addSuiteNamed:appGroupID];
        [defaults addObserver:sharedForceTouchController forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:NULL];
        [defaults addObserver:sharedForceTouchController forKeyPath:@"dimEnabled" options:NSKeyValueObservingOptionNew context:NULL];
        [defaults addObserver:sharedForceTouchController forKeyPath:@"rgbEnabled" options:NSKeyValueObservingOptionNew context:NULL];
        [defaults addObserver:sharedForceTouchController forKeyPath:@"whitePointEnabled" options:NSKeyValueObservingOptionNew context:NULL];
        [defaults addObserver:sharedForceTouchController forKeyPath:@"keyEnabled" options:NSKeyValueObservingOptionNew context:NULL];
    });
    
    return sharedForceTouchController;
}

- (void)userDefaultsChanged:(NSNotification *)notification {
    [ForceTouchController updateShortcutItems];
}

- (void)dealloc {
    NSUserDefaults *defaults = userDefaults;
    [defaults addSuiteNamed:appGroupID];
    [defaults removeObserver:self forKeyPath:@"enabled"];
    [defaults removeObserver:self forKeyPath:@"dimEnabled"];
    [defaults removeObserver:self forKeyPath:@"rgbEnabled"];
    [defaults removeObserver:self forKeyPath:@"whitePointEnabled"];
    [defaults removeObserver:self forKeyPath:@"keyEnabled"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [ForceTouchController updateShortcutItems];
}

+ (UIApplicationShortcutItem *)shortcutItemForCurrentState {
    NSString *shortcutType, *shortcutTitle, *shortcutSubtitle, *iconTemplate = nil;
    
    static NSString * const turnOnText = @"Turn on this adjustment";
    static NSString * const turnOffText = @"Turn off this adjustment";
    
    if ([groupDefaults boolForKey:@"tempForceTouch"]) {
        shortcutType = @"temperatureForceTouchAction";
        
        if (![groupDefaults boolForKey:@"enabled"]) {
            forceTouchActionEnabled = NO;
            shortcutTitle = @"Enable Temperature";
        }
        else if ([groupDefaults boolForKey:@"enabled"])  {
            forceTouchActionEnabled = YES;
            shortcutTitle = @"Disable Temperature";
        }
    }
    
    else if ([groupDefaults boolForKey:@"dimForceTouch"]) {
        shortcutType = @"dimForceTouchAction";
        
        if (![groupDefaults boolForKey:@"dimEnabled"]) {
            forceTouchActionEnabled = NO;
            shortcutTitle = @"Enable Dimness";
        }
        else if ([groupDefaults boolForKey:@"dimEnabled"]) {
            forceTouchActionEnabled = YES;
            shortcutTitle = @"Disable Dimness";
        }
    }
    
    else if ([groupDefaults boolForKey:@"rgbForceTouch"]) {
        shortcutType = @"rgbForceTouchAction";
        
        if (![groupDefaults boolForKey:@"rgbEnabled"]) {
            forceTouchActionEnabled = NO;
            shortcutTitle = @"Enable Color";
        }
        else if ([groupDefaults boolForKey:@"rgbEnabled"]) {
            forceTouchActionEnabled = YES;
            shortcutTitle = @"Disable Color";
        }
    }
    
    else if ([groupDefaults boolForKey:@"whitePointForceTouch"]) {
        shortcutType = @"whitePointForceTouchAction";
        
        if (![groupDefaults boolForKey:@"whitePointEnabled"]) {
            forceTouchActionEnabled = NO;
            shortcutTitle = @"Enable White Point";
        }
        else if ([groupDefaults boolForKey:@"whitePointEnabled"]) {
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
        if ([groupDefaults boolForKey:@"forceTouchEnabled"]) {
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
        if ([groupDefaults boolForKey:@"enabled"]) {
            [GammaController disableOrangeness];
        }
        else if (![groupDefaults boolForKey:@"enabled"]) {
            if (![GammaController adjustmentForKeysEnabled:@"dimEnabled", @"rgbEnabled", @"whitePointEnabled", nil]) {
                [GammaController enableOrangenessWithDefaults:YES transition:YES];
            }
            else {
                [self showFailedAlertWithKey:@"enabled"];
            }
        }
    }
    else if ([shortcutItem.type isEqualToString:@"dimForceTouchAction"]) {
        if ([groupDefaults boolForKey:@"dimEnabled"]) {
            [GammaController disableDimness];
        }
        else if (![groupDefaults boolForKey:@"dimEnabled"]) {
            if (![GammaController adjustmentForKeysEnabled:@"enabled", @"rgbEnabled", @"whitePointEnabled", nil]) {
                [GammaController enableDimness];
            }
            else {
                [self showFailedAlertWithKey:@"dimEnabled"];
            }
        }
    }
    else if ([shortcutItem.type isEqualToString:@"rgbForceTouchAction"]) {
        if ([groupDefaults boolForKey:@"rgbEnabled"]) {
            [GammaController disableColorAdjustment];
        }
        else if (![groupDefaults boolForKey:@"rgbEnabled"]) {
            if (![GammaController adjustmentForKeysEnabled:@"enabled", @"dimEnabled", @"whitePointEnabled", nil]) {
                [GammaController setGammaWithCustomValues];
            }
            else {
                [self showFailedAlertWithKey:@"rgbEnabled"];
            }
        }
    }
    else if ([shortcutItem.type isEqualToString:@"whitePointForceTouchAction"]) {
        if ([groupDefaults boolForKey:@"whitePointEnabled"]) {
            [GammaController resetWhitePoint];
            [groupDefaults setBool:NO forKey:@"whitePointEnabled"];
        }
        else if (![groupDefaults boolForKey:@"whitePointEnabled"]) {
            if (![GammaController adjustmentForKeysEnabled:@"enabled", @"dimEnabled", @"rgbEnabled", nil]) {
                [GammaController setWhitePoint:[groupDefaults boolForKey:@"whitePointValue"]];
                [groupDefaults setBool:YES forKey:@"whitePointEnabled"];
            }
            else {
                [self showFailedAlertWithKey:@"whitePointEnabled"];
            }
        }
    }
    return NO;
}

+ (void)exitIfKeyEnabled {
    if ([groupDefaults boolForKey:@"suspendEnabled"] && [[groupDefaults objectForKey:@"keyEnabled"] isEqualToString:@"0"]) {
        [GammaController suspendApp];
    }
}


+ (void)showFailedAlertWithKey:(NSString *)key {
    [groupDefaults setObject:@"1" forKey:@"keyEnabled"];
    [groupDefaults setBool:NO forKey:key];
    [groupDefaults synchronize];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You may only use one adjustment at a time. Please disable any other adjustments before enabling this one." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
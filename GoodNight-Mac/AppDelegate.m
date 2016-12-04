//
//  AppDelegate.m
//  GoodNight-Mac
//
//  Created by Anthony Agatiello on 11/17/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "TemperatureViewController.h"
#import <Sparkle/Sparkle.h>

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.image = [NSImage imageNamed:@"menu"];
    [self.statusItem setHighlightMode:YES];
    
    self.statusMenu = [[NSMenu alloc] initWithTitle:@""];
    
    NSMenuItem *titleItem = [[NSMenuItem alloc] initWithTitle:@"GoodNight" action:nil keyEquivalent:@""];
    
    NSString *appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSMenuItem *versionItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Version %@", appVersionString] action:nil keyEquivalent:@""];
    
    NSMenuItem *seperatorItem = [NSMenuItem separatorItem];
    NSMenuItem *aboutItem = [[NSMenuItem alloc] initWithTitle:@"About GoodNight..." action:@selector(openAboutWindow) keyEquivalent:@""];
    NSMenuItem *updateItem = [[NSMenuItem alloc] initWithTitle:@"Check for Updates..." action:@selector(checkForUpdateMenuAction) keyEquivalent:@""];
    NSMenuItem *seperatorItem2 = [NSMenuItem separatorItem];
    
    NSMenuItem *resetItem = [[NSMenuItem alloc] initWithTitle:@"Reset All" action:@selector(resetAll) keyEquivalent:@"r"];
    [resetItem setKeyEquivalentModifierMask:GoodNightModifierFlags];
    
    NSMenuItem *darkroomItem = [[NSMenuItem alloc] initWithTitle:@"Toggle Darkroom" action:@selector(toggleDarkroom) keyEquivalent:@"x"];
    [darkroomItem setKeyEquivalentModifierMask:GoodNightModifierFlags];
    
    NSMenuItem *darkThemeItem = [[NSMenuItem alloc] initWithTitle:@"Toggle Dark Theme" action:@selector(menuToggleSystemTheme) keyEquivalent:@"t"];
    [darkThemeItem setKeyEquivalentModifierMask:GoodNightModifierFlags];
    
    NSMenuItem *seperatorItem3 = [NSMenuItem separatorItem];
    
    NSMenuItem *openItem = [[NSMenuItem alloc] initWithTitle:@"Open..." action:@selector(openNewWindow) keyEquivalent:@"g"];
    [openItem setKeyEquivalentModifierMask:GoodNightModifierFlags];
    
    NSMenuItem *closeWindowItem = [[NSMenuItem alloc] initWithTitle:@"Close" action:@selector(performClose:) keyEquivalent:@"w"];
    NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
    
    [self.statusMenu addItem:titleItem];
    [self.statusMenu addItem:versionItem];
    [self.statusMenu addItem:seperatorItem];
    [self.statusMenu addItem:aboutItem];
    [self.statusMenu addItem:updateItem];
    [self.statusMenu addItem:seperatorItem2];
    [self.statusMenu addItem:resetItem];
    [self.statusMenu addItem:darkroomItem];
    [self.statusMenu addItem:darkThemeItem];
    [self.statusMenu addItem:seperatorItem3];
    [self.statusMenu addItem:openItem];
    [self.statusMenu addItem:closeWindowItem];
    [self.statusMenu addItem:quitItem];

    [self.statusItem setMenu:self.statusMenu];
    
    float defaultValue = 1.0;
    BOOL defaultBooleanValue = NO;
    
    NSDictionary *defaultValues = @{@"orangeValue":     @(defaultValue),
                                    @"darkroomEnabled": @(defaultBooleanValue),
                                    @"alertShowed":     @(defaultBooleanValue),
                                    @"brightnessValue": @(defaultValue),
                                    @"darkThemeEnabled":@(defaultBooleanValue),
                                    MASOpenShortcutEnabledKey:      @YES,
                                    MASResetShortcutEnabledKey:     @YES,
                                    MASDarkroomShortcutEnabledKey:  @YES,
                                    MASDarkThemeShortcutEnabledKey: @YES};
    
    [userDefaults registerDefaults:defaultValues];
    
    float orangeValue = [userDefaults floatForKey:@"orangeValue"];
    if (orangeValue != 1) {
        [TemperatureViewController setGammaWithOrangeness:[userDefaults floatForKey:@"orangeValue"]];
    }

    float brightnessValue = [userDefaults floatForKey:@"brightnessValue"];
    if (brightnessValue != 1) {
        [TemperatureViewController setGammaWithRed:brightnessValue green:brightnessValue blue:brightnessValue];
    }
    
    [userDefaults addObserver:self forKeyPath:MASOpenShortcutEnabledKey options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:MASObservingContext];
    [userDefaults addObserver:self forKeyPath:MASResetShortcutEnabledKey options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:MASObservingContext];
    [userDefaults addObserver:self forKeyPath:MASDarkroomShortcutEnabledKey options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:MASObservingContext];
    [userDefaults addObserver:self forKeyPath:MASDarkThemeShortcutEnabledKey options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:MASObservingContext];
}

- (void)menuToggleSystemTheme {
    [TemperatureViewController toggleSystemTheme];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context != MASObservingContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    BOOL newValue = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
    
    if ([keyPath isEqualToString:MASOpenShortcutEnabledKey]) {
        [self setOpenShortcutEnabled:newValue];
    }
    if ([keyPath isEqualToString:MASResetShortcutEnabledKey]) {
        [self setResetShortcutEnabled:newValue];
    }
    if ([keyPath isEqualToString:MASDarkroomShortcutEnabledKey]) {
        [self setDarkroomShortcutEnabled:newValue];
    }
    if ([keyPath isEqualToString:MASDarkThemeShortcutEnabledKey]) {
        [self setSystemThemeShortcutEnabled:newValue];
    }
}

- (void)setOpenShortcutEnabled:(BOOL)enabled {
    MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:kVK_ANSI_G modifierFlags:GoodNightModifierFlags];
    if (enabled) {
        [[MASShortcutMonitor sharedMonitor] registerShortcut:shortcut withAction:^{
            [self openNewWindow];
        }];
    }
    else {
        [[MASShortcutMonitor sharedMonitor] unregisterShortcut:shortcut];
    }
}

- (void)setResetShortcutEnabled:(BOOL)enabled {
    MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:kVK_ANSI_R modifierFlags:GoodNightModifierFlags];
    if (enabled) {
        [[MASShortcutMonitor sharedMonitor] registerShortcut:shortcut withAction:^{
            [self resetAll];
        }];
    }
    else {
        [[MASShortcutMonitor sharedMonitor] unregisterShortcut:shortcut];
    }
}

- (void)setDarkroomShortcutEnabled:(BOOL)enabled {
    MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:kVK_ANSI_X modifierFlags:GoodNightModifierFlags];
    if (enabled) {
        [[MASShortcutMonitor sharedMonitor] registerShortcut:shortcut withAction:^{
            [self toggleDarkroom];
        }];
    }
    else {
        [[MASShortcutMonitor sharedMonitor] unregisterShortcut:shortcut];
    }
}

- (void)setSystemThemeShortcutEnabled:(BOOL)enabled {
    MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:kVK_ANSI_T modifierFlags:GoodNightModifierFlags];
    if (enabled) {
        [[MASShortcutMonitor sharedMonitor] registerShortcut:shortcut withAction:^{
            [TemperatureViewController toggleSystemTheme];
        }];
    }
    else {
        [[MASShortcutMonitor sharedMonitor] unregisterShortcut:shortcut];
    }
}

- (void)checkForUpdateMenuAction {
    [[[SUUpdater alloc] init] checkForUpdates:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    
    if ([userDefaults boolForKey:@"darkroomEnabled"]) {
        [self toggleDarkroom];
    }
}

- (void)resetAll {
    [TemperatureViewController resetAllAdjustments];
}

- (void)toggleDarkroom {
    [TemperatureViewController toggleDarkroom];
}

- (void)openAboutWindow {
    self.aboutWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"aboutWC"];
    [self.aboutWindowController.window setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark]];
    [self.aboutWindowController showWindow:nil];
    [self.aboutWindowController.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)openNewWindow {
    self.tabWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"windowController"];
    [self.tabWindowController showWindow:nil];
    [self.tabWindowController.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

@end

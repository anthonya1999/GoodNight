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
    NSMenuItem *resetItem = [[NSMenuItem alloc] initWithTitle:@"Reset All" action:@selector(resetAll) keyEquivalent:@""];
    NSMenuItem *darkroomItem = [[NSMenuItem alloc] initWithTitle:@"Toggle Darkroom" action:@selector(toggleDarkroom) keyEquivalent:@""];
    NSMenuItem *seperatorItem3 = [NSMenuItem separatorItem];
    NSMenuItem *openItem = [[NSMenuItem alloc] initWithTitle:@"Open..." action:@selector(openNewWindow) keyEquivalent:@"n"];
    NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
    
    [self.statusMenu addItem:titleItem];
    [self.statusMenu addItem:versionItem];
    [self.statusMenu addItem:seperatorItem];
    [self.statusMenu addItem:aboutItem];
    [self.statusMenu addItem:updateItem];
    [self.statusMenu addItem:seperatorItem2];
    [self.statusMenu addItem:resetItem];
    [self.statusMenu addItem:darkroomItem];
    [self.statusMenu addItem:seperatorItem3];
    [self.statusMenu addItem:openItem];
    [self.statusMenu addItem:quitItem];

    [self.statusItem setMenu:self.statusMenu];
    
    float defaultValue = 1.0;
    BOOL defaultDarkroomValue = NO;
    
    NSDictionary *defaultValues = @{@"orangeValue":     @(defaultValue),
                                    @"darkroomEnabled": @(defaultDarkroomValue),
                                    @"brightnessValue": @(defaultValue)};
    
    [userDefaults registerDefaults:defaultValues];
    
    float orangeValue = [userDefaults floatForKey:@"orangeValue"];
    if (orangeValue != 1) {
        [TemperatureViewController setGammaWithOrangeness:[userDefaults floatForKey:@"orangeValue"]];
    }

    float brightnessValue = [userDefaults floatForKey:@"brightnessValue"];
    if (brightnessValue != 1) {
        [TemperatureViewController setGammaWithRed:brightnessValue green:brightnessValue blue:brightnessValue];
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
    [userDefaults setFloat:1 forKey:@"orangeValue"];
    [userDefaults setBool:NO forKey:@"darkroomEnabled"];
    [userDefaults synchronize];
    CGDisplayRestoreColorSyncSettings();
    [TemperatureViewController setInvertedColorsEnabled:NO];
}

- (void)toggleDarkroom {
    if (![userDefaults boolForKey:@"darkroomEnabled"]) {
        [userDefaults setFloat:1 forKey:@"orangeValue"];
        [userDefaults setBool:YES forKey:@"darkroomEnabled"];
        [TemperatureViewController setGammaWithRed:1 green:0 blue:0];
        [TemperatureViewController setInvertedColorsEnabled:YES];
    }
    else {
        [userDefaults setFloat:1 forKey:@"orangeValue"];
        [userDefaults setBool:NO forKey:@"darkroomEnabled"];
        CGDisplayRestoreColorSyncSettings();
        [TemperatureViewController setInvertedColorsEnabled:NO];
    }
    [userDefaults synchronize];
}

- (void)openAboutWindow {
    self.windowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"aboutWC"];
    [self.windowController showWindow:nil];
    [self.windowController.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)openNewWindow {
    self.windowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"windowController"];
    [self.windowController showWindow:nil];
    [self.windowController.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

@end

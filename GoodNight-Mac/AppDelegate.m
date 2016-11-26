//
//  AppDelegate.m
//  GoodNight-Mac
//
//  Created by Anthony Agatiello on 11/17/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "TemperatureViewController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.image = [NSImage imageNamed:@"menu"];
    [self.statusItem setHighlightMode:YES];
    
    self.statusMenu = [[NSMenu alloc] initWithTitle:@""];
    
    NSMenuItem *titleItem = [[NSMenuItem alloc] initWithTitle:@"GoodNight" action:nil keyEquivalent:@""];
    NSMenuItem *seperatorItem = [NSMenuItem separatorItem];
    NSMenuItem *resetItem = [[NSMenuItem alloc] initWithTitle:@"Reset All" action:@selector(resetAll) keyEquivalent:@""];
    NSMenuItem *darkroomItem = [[NSMenuItem alloc] initWithTitle:@"Toggle Darkroom" action:@selector(toggleDarkroom) keyEquivalent:@""];
    NSMenuItem *seperatorItem2 = [NSMenuItem separatorItem];
    NSMenuItem *openItem = [[NSMenuItem alloc] initWithTitle:@"Open..." action:@selector(openNewWindow) keyEquivalent:@""];
    NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
    
    [self.statusMenu addItem:titleItem];
    [self.statusMenu addItem:seperatorItem];
    [self.statusMenu addItem:resetItem];
    [self.statusMenu addItem:darkroomItem];
    [self.statusMenu addItem:seperatorItem2];
    [self.statusMenu addItem:openItem];
    [self.statusMenu addItem:quitItem];

    [self.statusItem setMenu:self.statusMenu];
    
    float defaultOrangeValue = 1.0;
    BOOL defaultDarkroomValue = NO;
    
    NSDictionary *defaultValues = @{@"orangeValue":     @(defaultOrangeValue),
                                    @"darkroomEnabled": @(defaultDarkroomValue)};
    
    [userDefaults registerDefaults:defaultValues];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
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

- (void)openNewWindow {
    self.windowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"windowController"];
    [self.windowController showWindow:nil];
    [self.windowController.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

@end

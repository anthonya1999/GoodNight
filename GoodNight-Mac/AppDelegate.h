//
//  AppDelegate.h
//  GoodNight-Mac
//
//  Created by Anthony Agatiello on 11/17/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MASShortcut/Shortcut.h>
#import <Sparkle/Sparkle.h>

static NSString * const MASOpenShortcutEnabledKey = @"openShortcutEnabled";
static NSString * const MASResetShortcutEnabledKey = @"resetShortcutEnabled";
static NSString * const MASDarkroomShortcutEnabledKey = @"darkroomShortcutEnabled";
static NSString * const MASDarkThemeShortcutEnabledKey = @"darkThemeShortcutEnabled";

static NSUInteger const GoodNightModifierFlags = NSEventModifierFlagCommand | NSEventModifierFlagOption;

static float _darkThemeFloatValue = 33/255.0f;

static void *MASObservingContext = &MASObservingContext;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSMenu *statusMenu;
@property (strong, nonatomic) NSMenuItem *loginItem;

@property NSWindowController *tabWindowController;
@property NSWindowController *aboutWindowController;

@end

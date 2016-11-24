//
//  AppDelegate.m
//  GoodNight-Mac
//
//  Created by Anthony Agatiello on 11/17/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    float defaultOrangeValue = 1.0;
    BOOL defaultDarkroomValue = NO;
    
    NSDictionary *defaultValues = @{@"orangeValue":     @(defaultOrangeValue),
                                    @"darkroomEnabled": @(defaultDarkroomValue)};
    
    [userDefaults registerDefaults:defaultValues];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end

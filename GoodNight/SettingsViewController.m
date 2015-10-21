//
//  SettingsViewController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 10/16/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "SettingsViewController.h"

@implementation SettingsViewController

- (instancetype)init
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    self = [storyboard instantiateViewControllerWithIdentifier:@"settingsViewController"];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.suspendSwitch.on = [userDefaults boolForKey:@"suspendEnabled"];
    self.forceTouchSwitch.on = [userDefaults boolForKey:@"forceTouchEnabled"];
    self.temperatureForceTouch.on = [userDefaults boolForKey:@"tempForceTouch"];
    self.dimForceTouch.on = [userDefaults boolForKey:@"dimForceTouch"];
    self.rgbForceTouch.on = [userDefaults boolForKey:@"rgbForceTouch"];
}

- (IBAction)suspendSwitchChanged {
    [userDefaults setBool:self.suspendSwitch.on forKey:@"suspendEnabled"];
}

- (IBAction)forceTouchSwitchChanged {
    [userDefaults setBool:self.forceTouchSwitch.on forKey:@"forceTouchEnabled"];
    
    if (![userDefaults boolForKey:@"dimForceTouch"] && ![userDefaults boolForKey:@"tempForceTouch"] && ![userDefaults boolForKey:@"rgbForceTouch"]) {
        [userDefaults setBool:YES forKey:@"tempForceTouch"];
        [self viewDidLoad];
    }
    [self.tableView reloadData];
    [ForceTouchController updateShortcutItems];
}

- (IBAction)tempForceTouchSwitchChanged {
    if ([userDefaults boolForKey:@"rgbForceTouch"]) {
        [userDefaults setBool:NO forKey:@"rgbForceTouch"];
    }
    else if ([userDefaults boolForKey:@"dimForceTouch"]) {
        [userDefaults setBool:NO forKey:@"dimForceTouch"];
    }
    [userDefaults setBool:self.temperatureForceTouch.on forKey:@"tempForceTouch"];
    [ForceTouchController updateShortcutItems];
    [self checkForForceTouchActions];
}

- (IBAction)dimForceTouchSwitchChanged {
    if ([userDefaults boolForKey:@"tempForceTouch"]) {
        [userDefaults setBool:NO forKey:@"tempForceTouch"];
    }
    else if ([userDefaults boolForKey:@"rgbForceTouch"]) {
        [userDefaults setBool:NO forKey:@"rgbForceTouch"];
    }
    [userDefaults setBool:self.dimForceTouch.on forKey:@"dimForceTouch"];
    [ForceTouchController updateShortcutItems];
    [self checkForForceTouchActions];
}

- (IBAction)rgbForceTouchSwitchChanged {
    if ([userDefaults boolForKey:@"tempForceTouch"]) {
        [userDefaults setBool:NO forKey:@"tempForceTouch"];
    }
    else if ([userDefaults boolForKey:@"dimForceTouch"]) {
        [userDefaults setBool:NO forKey:@"dimForceTouch"];
    }
    [userDefaults setBool:self.rgbForceTouch.on forKey:@"rgbForceTouch"];
    [ForceTouchController updateShortcutItems];
    [self checkForForceTouchActions];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        if (section == 0) {
            if ([userDefaults boolForKey:@"forceTouchEnabled"]) {
                return 2;
            }
            else {
                return 1;
            }
        }
        if (section == 1) {
            return 3;
        }
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        if ([userDefaults boolForKey:@"forceTouchEnabled"]) {
            return 2;
        }
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerText = @"";
    if (tableView) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
            if (section == 0) {
                headerText = @"3D Touch";
            }
            if (section == 1) {
                headerText = @"Quick Actions";
            }
        }
    }
    return headerText;
}

- (void)checkForForceTouchActions {
    if (![userDefaults boolForKey:@"dimForceTouch"] && ![userDefaults boolForKey:@"tempForceTouch"] && ![userDefaults boolForKey:@"rgbForceTouch"]) {
        [userDefaults setBool:NO forKey:@"forceTouchEnabled"];
        [self.tableView reloadData];
    }
    [self viewDidLoad];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *footerText = @"";
    if (tableView) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
            if (section == 0) {
                if ([userDefaults boolForKey:@"forceTouchEnabled"]) {
                    footerText = @"Turn on or off 3D Touch actions for GoodNight. When enabled, the \"Exit After Action\" exits the app after you enable or disable the set adjustment using 3D Touch.";
                }
                else {
                    footerText = @"Turn on or off 3D Touch actions for GoodNight.";
                }
            }
            if (section == 1) {
                footerText = @"Choose the adjustment that you would like to enable and disable using 3D Touch. You may only have one enabled at a time.";
            }
        }
        else {
            footerText = @"There are no settings for your device at this moment. However, some may be added in a future update.";
        }
    }
    return footerText;
}

@end

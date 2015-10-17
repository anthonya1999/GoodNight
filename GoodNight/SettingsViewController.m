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
    [self.tableView reloadData];
    [AppDelegate setShortcutItems];
}

- (IBAction)tempForceTouchSwitchChanged {
    if (![userDefaults boolForKey:@"dimForceTouch"] && ![userDefaults boolForKey:@"rgbForceTouch"]) {
        [userDefaults setBool:self.temperatureForceTouch.on forKey:@"tempForceTouch"];
    }
    else {
        [self showErrorAlert];
    }
    [AppDelegate setShortcutItems];
    [self viewDidLoad];
}

- (IBAction)dimForceTouchSwitchChanged {
    if (![userDefaults boolForKey:@"tempForceTouch"] && ![userDefaults boolForKey:@"rgbForceTouch"]) {
        [userDefaults setBool:self.dimForceTouch.on forKey:@"dimForceTouch"];
    }
    else {
        [self showErrorAlert];
    }
    [AppDelegate setShortcutItems];
    [self viewDidLoad];
}

- (IBAction)rgbForceTouchSwitchChanged {
    if (![userDefaults boolForKey:@"tempForceTouch"] && ![userDefaults boolForKey:@"dimForceTouch"]) {
        [userDefaults setBool:self.rgbForceTouch.on forKey:@"rgbForceTouch"];
    }
    else {
        [self showErrorAlert];
    }
    [AppDelegate setShortcutItems];
    [self viewDidLoad];
}

- (void)showErrorAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You may only have one adjustment enabled for use with 3D Touch. Please the one you currently have enabled to turn on another one." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[self.view traitCollection] forceTouchCapability] == UIForceTouchCapabilityAvailable) {
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
    if ([[self.view traitCollection] forceTouchCapability] == UIForceTouchCapabilityAvailable) {
        if ([userDefaults boolForKey:@"forceTouchEnabled"]) {
            return 2;
        }
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerText = @"";
    if (tableView) {
        if ([[self.view traitCollection] forceTouchCapability] == UIForceTouchCapabilityAvailable) {
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

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *footerText = @"";
    if (tableView) {
        if (section == 0) {
            if ([[self.view traitCollection] forceTouchCapability] == UIForceTouchCapabilityAvailable) {
                if ([userDefaults boolForKey:@"forceTouchEnabled"]) {
                    footerText = @"Turn on or off 3D Touch actions for GoodNight. When enabled, the \"Exit After Action\" exits the app after you enable or disable the temperature adjustment using 3D Touch.";
                }
                else {
                    footerText = @"Turn on or off 3D Touch actions for GoodNight.";
                }
            }
            else {
                footerText = @"There are no settings for your device at this moment. However, some may be added in a future update.";
            }
        }
    }
    return footerText;
}

@end

//
//  SettingsViewController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 10/16/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "SettingsViewController.h"
#import "ForceTouchController.h"

@implementation SettingsViewController

- (instancetype)init
{
    self = [AppDelegate initWithIdentifier:@"settingsViewController"];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.suspendSwitch.on = [groupDefaults boolForKey:@"suspendEnabled"];
    self.forceTouchSwitch.on = [groupDefaults boolForKey:@"forceTouchEnabled"];
    self.peekPopSwitch.on = [groupDefaults boolForKey:@"peekPopEnabled"];
    self.temperatureForceTouch.on = [groupDefaults boolForKey:@"tempForceTouch"];
    self.dimForceTouch.on = [groupDefaults boolForKey:@"dimForceTouch"];
    self.rgbForceTouch.on = [groupDefaults boolForKey:@"rgbForceTouch"];
    self.wpForceTouchSwitch.on = [groupDefaults boolForKey:@"whitePointForceTouch"];
}

- (IBAction)suspendSwitchChanged {
    [groupDefaults setBool:self.suspendSwitch.on forKey:@"suspendEnabled"];
}

- (IBAction)forceTouchSwitchChanged {
    [groupDefaults setBool:self.forceTouchSwitch.on forKey:@"forceTouchEnabled"];
    
    if (![groupDefaults boolForKey:@"dimForceTouch"] && ![groupDefaults boolForKey:@"tempForceTouch"] && ![groupDefaults boolForKey:@"rgbForceTouch"]) {
        [groupDefaults setBool:YES forKey:@"tempForceTouch"];
        [self viewDidLoad];
    }
    [self.tableView reloadData];
    [ForceTouchController updateShortcutItems];
}

- (IBAction)tempForceTouchSwitchChanged {
    if ([groupDefaults boolForKey:@"rgbForceTouch"]) {
        [groupDefaults setBool:NO forKey:@"rgbForceTouch"];
    }
    else if ([groupDefaults boolForKey:@"dimForceTouch"]) {
        [groupDefaults setBool:NO forKey:@"dimForceTouch"];
    }
    else if ([groupDefaults boolForKey:@"whitePointForceTouch"]) {
        [groupDefaults setBool:NO forKey:@"whitePointForceTouch"];
    }
    [groupDefaults setBool:self.temperatureForceTouch.on forKey:@"tempForceTouch"];
    [self checkForForceTouchActions];
}

- (IBAction)dimForceTouchSwitchChanged {
    if ([groupDefaults boolForKey:@"tempForceTouch"]) {
        [groupDefaults setBool:NO forKey:@"tempForceTouch"];
    }
    else if ([groupDefaults boolForKey:@"rgbForceTouch"]) {
        [groupDefaults setBool:NO forKey:@"rgbForceTouch"];
    }
    else if ([groupDefaults boolForKey:@"whitePointForceTouch"]) {
        [groupDefaults setBool:NO forKey:@"whitePointForceTouch"];
    }
    [groupDefaults setBool:self.dimForceTouch.on forKey:@"dimForceTouch"];
    [self checkForForceTouchActions];
}

- (IBAction)rgbForceTouchSwitchChanged {
    if ([groupDefaults boolForKey:@"tempForceTouch"]) {
        [groupDefaults setBool:NO forKey:@"tempForceTouch"];
    }
    else if ([groupDefaults boolForKey:@"dimForceTouch"]) {
        [groupDefaults setBool:NO forKey:@"dimForceTouch"];
    }
    else if ([groupDefaults boolForKey:@"whitePointForceTouch"]) {
        [groupDefaults setBool:NO forKey:@"whitePointForceTouch"];
    }
    [groupDefaults setBool:self.rgbForceTouch.on forKey:@"rgbForceTouch"];
    [self checkForForceTouchActions];
}

- (IBAction)peekPopSwitchChanged {
    [groupDefaults setBool:self.peekPopSwitch.on forKey:@"peekPopEnabled"];
}

- (IBAction)wpForceTouchSwitchChanged {
    if ([groupDefaults boolForKey:@"tempForceTouch"]) {
        [groupDefaults setBool:NO forKey:@"tempForceTouch"];
    }
    else if ([groupDefaults boolForKey:@"dimForceTouch"]) {
        [groupDefaults setBool:NO forKey:@"dimForceTouch"];
    }
    else if ([groupDefaults boolForKey:@"rgbForceTouch"]) {
        [groupDefaults setBool:NO forKey:@"rgbForceTouch"];
    }
    [groupDefaults setBool:self.wpForceTouchSwitch.on forKey:@"whitePointForceTouch"];
    [self checkForForceTouchActions];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        if (section == 0) {
            return 2;
        }
        if (section == 1) {
            return 1;
        }
        if (section == 2) {
            return 4;
        }
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        if ([groupDefaults boolForKey:@"forceTouchEnabled"]) {
            return 3;
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
            if (section == 2) {
                headerText = @"Quick Actions";
            }
        }
    }
    return headerText;
}

- (void)checkForForceTouchActions {
    if (![groupDefaults boolForKey:@"dimForceTouch"] && ![groupDefaults boolForKey:@"tempForceTouch"] && ![groupDefaults boolForKey:@"rgbForceTouch"] && ![groupDefaults boolForKey:@"whitePointForceTouch"]) {
        [groupDefaults setBool:NO forKey:@"forceTouchEnabled"];
        [self.tableView reloadData];
    }
    [ForceTouchController updateShortcutItems];
    [self viewDidLoad];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *footerText = @"";
    if (tableView) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
            if (section == 0) {
                footerText = @"Turn on or off 3D Touch quick actions or \"Peek and Pop\" capability.";
            }
            if (section == 1) {
                footerText = @"When enabled, the \"Exit After Action\" exits the app after you enable or disable the set adjustment using 3D Touch.";
            }
            if (section == 2) {
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

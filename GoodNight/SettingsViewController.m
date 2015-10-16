//
//  SettingsViewController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 10/16/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

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
}

- (IBAction)suspendSwitchChanged {
    [userDefaults setBool:self.suspendSwitch.on forKey:@"suspendEnabled"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[self.view traitCollection] forceTouchCapability] == UIForceTouchCapabilityAvailable) {
        return 1;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerText = @"";
    if (tableView) {
        if (section == 0) {
            if ([[self.view traitCollection] forceTouchCapability] == UIForceTouchCapabilityAvailable) {
                headerText = @"3D Touch";
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
                footerText = @"Turn this setting on to exit the app after you enable or disable the temperature adjustment using 3D Touch.";
            }
            else {
               footerText = @"There are no settings for your device at this moment. However, some may be added in a future update.";
            }
        }
    }
    return footerText;
}

@end

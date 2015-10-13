//
//  ViewController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 6/22/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "MainViewController.h"
#import "GammaController.h"

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.orangeSlider.value = [[NSUserDefaults standardUserDefaults] floatForKey:@"maxOrange"];
    self.colorChangingEnabledSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"colorChangingEnabled"];
    self.enabledSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"enabled"];
}

- (IBAction)enabledSwitchChanged {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"rgbEnabled"] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"dimEnabled"]) {
        [[NSUserDefaults standardUserDefaults] setBool:self.enabledSwitch.on forKey:@"enabled"];
        
        if (self.enabledSwitch.on) {
            [GammaController setGammaWithOrangeness:[[NSUserDefaults standardUserDefaults] floatForKey:@"maxOrange"]];
        }
        else {
            [GammaController setGammaWithOrangeness:0];
        }
    }
    else {
        [self.enabledSwitch setOn:NO animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You may only use one adjustment at a time. Please disable any other adjustments before enabling this one." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)maxOrangeSliderChanged {
    [[NSUserDefaults standardUserDefaults] setFloat:self.orangeSlider.value forKey:@"maxOrange"];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.enabledSwitch.on) {
        [GammaController setGammaWithOrangeness:self.orangeSlider.value];
    }
}

- (IBAction)colorChangingEnabledSwitchChanged {
    NSLog(@"color changing switch changed");
    [[NSUserDefaults standardUserDefaults] setBool:self.colorChangingEnabledSwitch.on forKey:@"colorChangingEnabled"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate distantPast] forKey:@"lastAutoChangeDate"];
    [GammaController autoChangeOrangenessIfNeeded];
}

- (IBAction)resetSlider {
    self.orangeSlider.value = 0.4;
    [[NSUserDefaults standardUserDefaults] setFloat:self.orangeSlider.value forKey:@"maxOrange"];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.enabledSwitch.on) {
        [GammaController setGammaWithOrangeness:self.orangeSlider.value];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerText = @"";
    if (tableView) {
        if (section == 1) {
            headerText = [NSString stringWithFormat:@"Temperature (%.2f)", (self.orangeSlider.value * 10)];
        }
        if (section == 2) {
            headerText = @"Automatic Mode";
        }
    }
    return headerText;
}

@end
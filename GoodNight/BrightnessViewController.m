//
//  BrightnessViewController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 10/4/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "BrightnessViewController.h"
#import "GammaController.h"

@implementation BrightnessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dimSlider.value = [userDefaults floatForKey:@"dimLevel"];
    self.dimSwitch.on = [userDefaults boolForKey:@"dimEnabled"];
}

- (IBAction)brightnessSwitchChanged {
    if (![userDefaults boolForKey:@"enabled"] && ![userDefaults boolForKey:@"rgbEnabled"]) {
        [userDefaults setBool:self.dimSwitch.on forKey:@"dimEnabled"];
        
        if (self.dimSwitch.on) {
            [GammaController setGammaWithRed:self.dimSlider.value green:self.dimSlider.value blue:self.dimSlider.value];
        }
        else {
            [GammaController setGammaWithOrangeness:0];
        }

    }
    else {
        [self.dimSwitch setOn:NO animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You may only use one adjustment at a time. Please disable any other adjustments before enabling this one." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)dimSliderLevelChanged {
    [userDefaults setFloat:self.dimSlider.value forKey:@"dimLevel"];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.dimSwitch.on) {
        [GammaController setGammaWithRed:self.dimSlider.value green:self.dimSlider.value blue:self.dimSlider.value];
    }
}

- (IBAction)resetSlider {
    self.dimSlider.value = 1.0;
    [userDefaults setFloat:self.dimSlider.value forKey:@"dimLevel"];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.dimSwitch.on) {
        [GammaController setGammaWithRed:self.dimSlider.value green:self.dimSlider.value blue:self.dimSlider.value];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerText = @"";
    if (tableView) {
        if (section == 1) {
            headerText = [NSString stringWithFormat:@"Level (%.2f)", (self.dimSlider.value * 10)];
        }
    }
    return headerText;
}

@end
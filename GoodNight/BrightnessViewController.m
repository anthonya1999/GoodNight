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

- (instancetype)init
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    self = [storyboard instantiateViewControllerWithIdentifier:@"brightnessViewController"];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dimSlider.value = [userDefaults floatForKey:@"dimLevel"];
    self.dimSwitch.on = [userDefaults boolForKey:@"dimEnabled"];
}

- (IBAction)brightnessSwitchChanged {
    [userDefaults setBool:self.dimSwitch.on forKey:@"dimEnabled"];
        
    if (self.dimSwitch.on) {
        [GammaController enableDimness];
    }
    else {
        [GammaController disableOrangenessWithDefaults:NO key:@"dimEnabled"];
    }
    [self viewDidLoad];
}

- (IBAction)dimSliderLevelChanged {
    [userDefaults setFloat:self.dimSlider.value forKey:@"dimLevel"];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.dimSwitch.on) {
        [GammaController enableDimness];
    }
}

- (IBAction)resetSlider {
    self.dimSlider.value = 1.0;
    [userDefaults setFloat:self.dimSlider.value forKey:@"dimLevel"];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.dimSwitch.on) {
        [GammaController enableDimness];
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
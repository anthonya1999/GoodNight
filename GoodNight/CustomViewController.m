//
//  CustomViewController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 10/4/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "CustomViewController.h"
#import "GammaController.h"

@implementation CustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rgbSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"rgbEnabled"];
    self.redSlider.value = [[NSUserDefaults standardUserDefaults] floatForKey:@"redValue"];
    self.greenSlider.value = [[NSUserDefaults standardUserDefaults] floatForKey:@"greenValue"];
    self.blueSlider.value = [[NSUserDefaults standardUserDefaults] floatForKey:@"blueValue"];
}

- (IBAction)redChanged {
    [[NSUserDefaults standardUserDefaults] setFloat:self.redSlider.value forKey:@"redValue"];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];

    if (self.rgbSwitch.on) {
        [GammaController setGammaWithRed:self.redSlider.value green:self.greenSlider.value blue:self.blueSlider.value];
    }
}

- (IBAction)greenChanged {
    [[NSUserDefaults standardUserDefaults] setFloat:self.greenSlider.value forKey:@"greenValue"];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];

    if (self.rgbSwitch.on) {
        [GammaController setGammaWithRed:self.redSlider.value green:self.greenSlider.value blue:self.blueSlider.value];
    }
}

- (IBAction)blueChanged {
    [[NSUserDefaults standardUserDefaults] setFloat:self.blueSlider.value forKey:@"blueValue"];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];

    if (self.rgbSwitch.on) {
        [GammaController setGammaWithRed:self.redSlider.value green:self.greenSlider.value blue:self.blueSlider.value];
    }
}

- (IBAction)colorSwitchChanged {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"enabled"] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"dimEnabled"]) {
        [[NSUserDefaults standardUserDefaults] setBool:self.rgbSwitch.on forKey:@"rgbEnabled"];
        
        if (self.rgbSwitch.on) {
            [GammaController setGammaWithRed:self.redSlider.value green:self.greenSlider.value blue:self.blueSlider.value];
        }
        else {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"enabled"]) {
                [GammaController setGammaWithOrangeness:[[NSUserDefaults standardUserDefaults] floatForKey:@"maxOrange"]];
            }
            else {
                [GammaController setGammaWithOrangeness:0];
            }
        }
    }
    else {
        [self.rgbSwitch setOn:NO animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You may only use one adjustment at a time. Please disable any other adjustments before enabling this one." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)resetDisplayColor {
    self.redSlider.value = 1.0;
    [[NSUserDefaults standardUserDefaults] setFloat:self.redSlider.value forKey:@"redValue"];
    
    self.greenSlider.value = 1.0;
    [[NSUserDefaults standardUserDefaults] setFloat:self.greenSlider.value forKey:@"greenValue"];
    
    self.blueSlider.value = 1.0;
    [[NSUserDefaults standardUserDefaults] setFloat:self.blueSlider.value forKey:@"blueValue"];
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.rgbSwitch.on) {
        [GammaController setGammaWithRed:self.redSlider.value green:self.greenSlider.value blue:self.blueSlider.value];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerText = @"";
    if (tableView) {
        if (section == 1) {
            headerText = [NSString stringWithFormat:@"Red (%.2f)", (self.redSlider.value * 10)];
        }
        if (section == 2) {
            headerText = [NSString stringWithFormat:@"Green (%.2f)", (self.greenSlider.value * 10)];
        }
        if (section == 3) {
            headerText = [NSString stringWithFormat:@"Blue (%.2f)", (self.blueSlider.value * 10)];
        }
    }
    return headerText;
}

@end
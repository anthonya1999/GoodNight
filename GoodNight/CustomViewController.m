//
//  CustomViewController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 10/4/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "CustomViewController.h"

@implementation CustomViewController

- (instancetype)init
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    self = [storyboard instantiateViewControllerWithIdentifier:@"colorViewController"];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rgbSwitch.on = [userDefaults boolForKey:@"rgbEnabled"];
    self.redSlider.value = [userDefaults floatForKey:@"redValue"];
    self.greenSlider.value = [userDefaults floatForKey:@"greenValue"];
    self.blueSlider.value = [userDefaults floatForKey:@"blueValue"];
}

- (IBAction)redChanged {
    [self updateDisplayColorWithValue:self.redSlider.value forKey:@"redValue"];
}

- (IBAction)greenChanged {
    [self updateDisplayColorWithValue:self.greenSlider.value forKey:@"greenValue"];
}

- (IBAction)blueChanged {
    [self updateDisplayColorWithValue:self.blueSlider.value forKey:@"blueValue"];
}

- (IBAction)colorSwitchChanged {
    [userDefaults setBool:self.rgbSwitch.on forKey:@"rgbEnabled"];
        
    if (self.rgbSwitch.on) {
        [GammaController setGammaWithCustomValues];
    }
    else {
        [GammaController disableOrangenessWithDefaults:NO key:@"rgbEnabled"];
    }
    [self viewDidLoad];
}

- (void)updateDisplayColorWithValue:(float)value forKey:(NSString *)key {
    if (value != 0 && key != nil) {
    [userDefaults setFloat:value forKey:key];
    }
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.rgbSwitch.on) {
        [GammaController setGammaWithCustomValues];
    }
}

- (IBAction)resetDisplayColor {
    self.redSlider.value = 1.0;
    [userDefaults setFloat:self.redSlider.value forKey:@"redValue"];
    
    self.greenSlider.value = 1.0;
    [userDefaults setFloat:self.greenSlider.value forKey:@"greenValue"];
    
    self.blueSlider.value = 1.0;
    [userDefaults setFloat:self.blueSlider.value forKey:@"blueValue"];
    
    [self updateDisplayColorWithValue:0 forKey:nil];
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
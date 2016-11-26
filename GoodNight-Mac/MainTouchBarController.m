//
//  MainTouchBarController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 11/25/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import "MainTouchBarController.h"
#import "TemperatureViewController.h"

@implementation MainTouchBarController

- (void)awakeFromNib {
    [self.touchBarColorPicker setEnabled:YES];
}

- (IBAction)setColorFromColorPicker:(NSButton *)button {
    NSColor *color = self.touchBarColorPicker.color;
    
    float redValue = [color redComponent];
    float greenValue = [color greenComponent];
    float blueValue = [color blueComponent];
    
    [TemperatureViewController setGammaWithRed:redValue green:greenValue blue:blueValue];
}

- (IBAction)resetAll:(NSButton *)button {
    [userDefaults setFloat:1 forKey:@"orangeValue"];
    [userDefaults setFloat:1 forKey:@"brightnessValue"];
    [userDefaults setBool:NO forKey:@"darkroomEnabled"];
    [userDefaults synchronize];
    CGDisplayRestoreColorSyncSettings();
    [TemperatureViewController setInvertedColorsEnabled:NO];
}

@end

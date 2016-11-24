//
//  ColorViewController.m
//  GoodNight-Mac
//
//  Created by Anthony Agatiello on 11/23/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import "ColorViewController.h"
#import "TemperatureViewController.h"

@implementation ColorViewController

- (IBAction)setColor:(NSButton *)button {
    float redValue = self.redField.floatValue;
    float greenValue = self.greenField.floatValue;
    float blueValue = self.blueField.floatValue;
    
    [TemperatureViewController setGammaWithRed:redValue green:greenValue blue:blueValue];
}

- (IBAction)resetColor:(NSButton *)button {
    CGDisplayRestoreColorSyncSettings();
}

@end

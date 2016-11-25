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
    
    if (redValue >= 0 && redValue <= 1 && greenValue >= 0 && greenValue <= 1 && blueValue >= 0 && redValue <= 1) {
        [TemperatureViewController setGammaWithRed:redValue green:greenValue blue:blueValue];
    }
    else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Error"];
        [alert setInformativeText:@"You must enter a value between 0 and 1 (not inclusive of 0) for the red, green, and blue values!"];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
}

- (IBAction)resetColor:(NSButton *)button {
    CGDisplayRestoreColorSyncSettings();
}

@end

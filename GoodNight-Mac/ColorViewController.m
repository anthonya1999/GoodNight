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
    float redValue = self.redField.floatValue / 255;
    float greenValue = self.greenField.floatValue / 255;
    float blueValue = self.blueField.floatValue / 255;
    
    if (redValue >= 0 && redValue <= 1 && greenValue >= 0 && greenValue <= 1 && blueValue >= 0 && blueValue <= 1) {
        [TemperatureViewController setGammaWithRed:redValue green:greenValue blue:blueValue];
    }
    else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Error"];
        [alert setInformativeText:@"You must enter a value between 0 and 255 for the red, green, and blue values!"];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
}

- (IBAction)resetColor:(NSButton *)button {
    CGDisplayRestoreColorSyncSettings();
}

@end

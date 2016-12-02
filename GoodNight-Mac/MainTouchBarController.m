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
    [self.touchBarColorPicker addObserver:self forKeyPath:@"color" options:kNilOptions context:nil];
}

- (void)dealloc {
    [self.touchBarColorPicker removeObserver:self forKeyPath:@"color"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSColor *color = self.touchBarColorPicker.color;
    
    float redValue = [color redComponent];
    float greenValue = [color greenComponent];
    float blueValue = [color blueComponent];
    
    [TemperatureViewController setGammaWithRed:redValue green:greenValue blue:blueValue];
}

- (IBAction)resetAll:(NSButton *)button {
    [TemperatureViewController resetAllAdjustments];
}

@end

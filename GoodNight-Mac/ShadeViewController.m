//
//  ShadeViewController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 11/25/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import "ShadeViewController.h"
#import "ShadeTouchBarController.h"
#import "TemperatureViewController.h"

@implementation ShadeViewController

- (void)viewWillAppear {
    [super viewWillAppear];
    
    [self.brightnessSlider setFloatValue:[userDefaults floatForKey:@"brightnessValue"]];
}

- (IBAction)brightnessSliderDidChange:(NSSlider *)slider {
    float sliderValue = self.brightnessSlider.floatValue;
    [userDefaults setFloat:sliderValue forKey:@"brightnessValue"];
    [userDefaults synchronize];
    sliderValue = [userDefaults floatForKey:@"brightnessValue"];
    
    [TemperatureViewController setGammaWithRed:sliderValue green:sliderValue blue:sliderValue];
    
    if (self.brightnessSlider.floatValue == 1) {
        [self resetBrightness:nil];
    }
    
    [[ShadeTouchBarController sharedInstance] awakeFromNib];
}

- (IBAction)resetBrightness:(NSButton *)button {
    [userDefaults setFloat:1 forKey:@"brightnessValue"];
    self.brightnessSlider.floatValue = [userDefaults floatForKey:@"brightnessValue"];
    [userDefaults synchronize];
    CGDisplayRestoreColorSyncSettings();
    [[ShadeTouchBarController sharedInstance] awakeFromNib];
}

@end

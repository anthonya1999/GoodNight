//
//  ShadeTouchBarController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 11/25/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import "ShadeTouchBarController.h"
#import "TemperatureViewController.h"

@implementation ShadeTouchBarController

- (void)awakeFromNib {
    [self.brightnessTouchBarSlider.slider setFloatValue:[userDefaults floatForKey:@"brightnessValue"]];
    self.brightnessTouchBarSlider.label = @"100%";

    [notificationCenter addObserver:self selector:@selector(defaultsChanged) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)defaultsChanged {
    [self.brightnessTouchBarSlider.slider setFloatValue:[userDefaults floatForKey:@"brightnessValue"]];
    self.brightnessTouchBarSlider.label = [NSString stringWithFormat:@"%d%%", (int)round([userDefaults floatForKey:@"brightnessValue"] * 100)];
}

- (IBAction)brightnessSliderDidChange:(NSSliderTouchBarItem *)slider {
    float sliderValue = self.brightnessTouchBarSlider.slider.floatValue;
    [userDefaults setFloat:sliderValue forKey:@"brightnessValue"];
    [userDefaults synchronize];
    sliderValue = [userDefaults floatForKey:@"brightnessValue"];
    
    [TemperatureViewController setGammaWithRed:sliderValue green:sliderValue blue:sliderValue];
    self.brightnessTouchBarSlider.label = [NSString stringWithFormat:@"%d%%", (int)round([userDefaults floatForKey:@"brightnessValue"] * 100)];
    
    if (self.brightnessTouchBarSlider.slider.floatValue == 1) {
        [self resetBrightness:nil];
    }
}

- (IBAction)resetBrightness:(NSButton *)button {
    [userDefaults setFloat:1 forKey:@"orangeValue"];
    [userDefaults setFloat:1 forKey:@"brightnessValue"];
    [userDefaults setBool:NO forKey:@"darkroomEnabled"];
    self.brightnessTouchBarSlider.label = @"100%";
    self.brightnessTouchBarSlider.slider.floatValue = [userDefaults floatForKey:@"brightnessValue"];
    [userDefaults synchronize];
    CGDisplayRestoreColorSyncSettings();
}

@end

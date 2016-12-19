//
//  TouchBarController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 11/24/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import "TemperatureTouchBarController.h"
#import "MacGammaController.h"
#import "TemperatureViewController.h"

@implementation TemperatureTouchBarController

- (void)awakeFromNib {
    [self.touchBarTemperatureSlider.slider setFloatValue:[userDefaults floatForKey:@"orangeValue"]];
    self.touchBarTemperatureSlider.label = [NSString stringWithFormat:@"%dK", (int)round((((self.touchBarTemperatureSlider.slider.maxValue - self.touchBarTemperatureSlider.slider.floatValue) * 45 + 20) * 10) * 10)];
    
    [defNotifCenter addObserver:self selector:@selector(defaultsChanged) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)defaultsChanged {
    [self.touchBarTemperatureSlider.slider setFloatValue:[userDefaults floatForKey:@"orangeValue"]];
    self.touchBarTemperatureSlider.label = [NSString stringWithFormat:@"%dK", (int)round((((self.touchBarTemperatureSlider.slider.maxValue - self.touchBarTemperatureSlider.slider.floatValue) * 45 + 20) * 10) * 10)];
    
    if ([userDefaults boolForKey:@"darkroomEnabled"]) {
        [self.touchBarDarkroomButton setTitle:@"Disable Darkroom"];
    }
    else {
        [self.touchBarDarkroomButton setTitle:@"Enable Darkroom"];
    }
}

- (IBAction)touchBarSliderValueDidChange:(NSSliderTouchBarItem *)slider {
    [self.touchBarDarkroomButton setTitle:@"Enable Darkroom"];
    [userDefaults setFloat:self.touchBarTemperatureSlider.slider.floatValue forKey:@"orangeValue"];
    [MacGammaController setGammaWithOrangeness:[userDefaults floatForKey:@"orangeValue"]];
    
    if (self.touchBarTemperatureSlider.slider.floatValue == 0) {
        [self resetTemperature:nil];
    }
    
    self.touchBarTemperatureSlider.label = [NSString stringWithFormat:@"%dK", (int)round((((self.touchBarTemperatureSlider.slider.maxValue - self.touchBarTemperatureSlider.slider.floatValue) * 45 + 20) * 10) * 10)];
    
    [userDefaults setFloat:1 forKey:@"brightnessValue"];
    [userDefaults setFloat:0.5 forKey:@"whitePointValue"];
    [userDefaults setBool:NO forKey:@"darkroomEnabled"];
    [userDefaults synchronize];
}

- (IBAction)resetTemperature:(NSButton *)button {
    [MacGammaController resetAllAdjustments];
}

- (IBAction)toggleDarkroom:(NSButton *)button {
    [self.touchBarTemperatureSlider.slider setFloatValue:[userDefaults floatForKey:@"orangeValue"]];
    self.touchBarTemperatureSlider.label = [NSString stringWithFormat:@"%dK", (int)round((((self.touchBarTemperatureSlider.slider.maxValue - self.touchBarTemperatureSlider.slider.floatValue) * 45 + 20) * 10) * 10)];
    
    if ([self.touchBarDarkroomButton.title isEqualToString:@"Enable Darkroom"]) {
        [self.touchBarDarkroomButton setTitle:@"Disable Darkroom"];
    }
    else {
        [self.touchBarDarkroomButton setTitle:@"Enable Darkroom"];
    }
    
    [MacGammaController toggleDarkroom];
}

@end


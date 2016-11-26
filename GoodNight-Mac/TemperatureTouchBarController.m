//
//  TouchBarController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 11/24/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import "TemperatureTouchBarController.h"
#import "TemperatureViewController.h"

@implementation TemperatureTouchBarController

+ (instancetype)sharedInstance {
    static TemperatureTouchBarController *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TemperatureTouchBarController alloc] init];
    });
    return sharedInstance;
}

- (void)awakeFromNib {
    [self.touchBarTemperatureSlider.slider setFloatValue:[userDefaults floatForKey:@"orangeValue"]];
    self.touchBarTemperatureSlider.label = [NSString stringWithFormat:@"%dK", (int)((self.touchBarTemperatureSlider.slider.floatValue * 45 + 20) * 10) * 10];
}

- (IBAction)touchBarSliderValueDidChange:(NSSliderTouchBarItem *)slider {
    [self.touchBarDarkroomButton setTitle:@"Enable Darkroom"];
    [userDefaults setFloat:self.touchBarTemperatureSlider.slider.floatValue forKey:@"orangeValue"];
    [userDefaults synchronize];
    [TemperatureViewController setGammaWithOrangeness:[userDefaults floatForKey:@"orangeValue"]];
    
    if (self.touchBarTemperatureSlider.slider.floatValue == 1) {
        [self resetTemperature:nil];
    }
    
    self.touchBarTemperatureSlider.label = [NSString stringWithFormat:@"%dK", (int)((self.touchBarTemperatureSlider.slider.floatValue * 45 + 20) * 10) * 10];
}

- (IBAction)resetTemperature:(NSButton *)button {
    [userDefaults setFloat:1 forKey:@"orangeValue"];
    [userDefaults setFloat:1 forKey:@"brightnessValue"];
    [userDefaults setBool:NO forKey:@"darkroomEnabled"];
    [userDefaults synchronize];
    self.touchBarTemperatureSlider.slider.floatValue = [userDefaults floatForKey:@"orangeValue"];
    self.touchBarTemperatureSlider.label = @"6500K";
    CGDisplayRestoreColorSyncSettings();
    [TemperatureViewController setInvertedColorsEnabled:NO];
}

- (IBAction)toggleDarkroom:(NSButton *)button {
    [self resetTemperature:nil];
    
    if ([self.touchBarDarkroomButton.title isEqualToString:@"Enable Darkroom"]) {
        [userDefaults setBool:YES forKey:@"darkroomEnabled"];
        [TemperatureViewController setGammaWithRed:1 green:0 blue:0];
        [TemperatureViewController setInvertedColorsEnabled:YES];
        [self.touchBarDarkroomButton setTitle:@"Disable Darkroom"];
    }
    else {
        [userDefaults setBool:NO forKey:@"darkroomEnabled"];
        [self.touchBarDarkroomButton setTitle:@"Enable Darkroom"];
        [TemperatureViewController setInvertedColorsEnabled:NO];
    }
    [userDefaults synchronize];
}

@end

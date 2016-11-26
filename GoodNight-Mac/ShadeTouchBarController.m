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

+ (instancetype)sharedInstance {
    static ShadeTouchBarController *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ShadeTouchBarController alloc] init];
    });
    return sharedInstance;
}

- (void)awakeFromNib {
    [self.bightnessTouchBarSlider.slider setFloatValue:[userDefaults floatForKey:@"brightnessValue"]];
}

- (IBAction)brightnessSliderDidChange:(NSSliderTouchBarItem *)slider {
    float sliderValue = self.bightnessTouchBarSlider.slider.floatValue;
    [userDefaults setFloat:sliderValue forKey:@"brightnessValue"];
    [userDefaults synchronize];
    sliderValue = [userDefaults floatForKey:@"brightnessValue"];
    
    [TemperatureViewController setGammaWithRed:sliderValue green:sliderValue blue:sliderValue];
    
    if (self.bightnessTouchBarSlider.slider.floatValue == 1) {
        [self resetBrightness:nil];
    }
}

- (IBAction)resetBrightness:(NSButton *)button {
    [userDefaults setFloat:1 forKey:@"orangeValue"];
    [userDefaults setFloat:1 forKey:@"brightnessValue"];
    [userDefaults setBool:NO forKey:@"darkroomEnabled"];
    self.bightnessTouchBarSlider.slider.floatValue = [userDefaults floatForKey:@"brightnessValue"];
    [userDefaults synchronize];
    CGDisplayRestoreColorSyncSettings();
}

@end

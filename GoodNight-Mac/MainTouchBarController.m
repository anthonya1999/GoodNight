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
    
    [defNotifCenter addObserver:self selector:@selector(defaultsChanged) name:NSUserDefaultsDidChangeNotification object:nil];
    [self setDarkThemeButtonText];
}

- (void)dealloc {
    [self.touchBarColorPicker removeObserver:self forKeyPath:@"color"];
}

- (void)defaultsChanged {
    [self setDarkThemeButtonText];
}

- (void)setDarkThemeButtonText {
    if ([userDefaults boolForKey:@"darkThemeEnabled"]) {
        [self.touchBarDarkThemeButton setTitle:@"Disable Dark Theme"];
    }
    else {
        [self.touchBarDarkThemeButton setTitle:@"Enable Dark Theme"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSColor *color = self.touchBarColorPicker.color;
    
    float redValue = [color redComponent];
    float greenValue = [color greenComponent];
    float blueValue = [color blueComponent];
    
    [userDefaults setFloat:1 forKey:@"orangeValue"];
    [userDefaults setFloat:1 forKey:@"brightnessValue"];
    [userDefaults setBool:NO forKey:@"darkroomEnabled"];
    [userDefaults synchronize];
    
    [TemperatureViewController setGammaWithRed:redValue green:greenValue blue:blueValue];
}

- (IBAction)resetAll:(NSButton *)button {
    [TemperatureViewController resetAllAdjustments];
}

- (IBAction)toggleDarkTheme:(NSButton *)button {
    if ([self.touchBarDarkThemeButton.title isEqualToString:@"Enable Dark Theme"]) {
        [self.touchBarDarkThemeButton setTitle:@"Disable Dark Theme"];
    }
    else {
        [self.touchBarDarkThemeButton setTitle:@"Enable Dark Theme"];
    }
    
    [TemperatureViewController toggleSystemTheme];
}

@end

//
//  MainTouchBarController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 11/25/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import "MainTouchBarController.h"
#import "MacGammaController.h"
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
        [self.touchBarDarkThemeButton setTitle:@"Dark Theme Off"];
    }
    else {
        [self.touchBarDarkThemeButton setTitle:@"Dark Theme On"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSColor *color = self.touchBarColorPicker.color;
    
    float redValue = [color redComponent];
    float greenValue = [color greenComponent];
    float blueValue = [color blueComponent];
    
    [MacGammaController setGammaWithRed:redValue green:greenValue blue:blueValue];
    
    [userDefaults setFloat:1 forKey:@"orangeValue"];
    [userDefaults setFloat:1 forKey:@"brightnessValue"];
    [userDefaults setFloat:0.5 forKey:@"whitePointValue"];
    [userDefaults setBool:NO forKey:@"darkroomEnabled"];
    [userDefaults synchronize];
}

- (IBAction)resetAll:(NSButton *)button {
    [MacGammaController resetAllAdjustments];
}

- (IBAction)toggleDarkTheme:(NSButton *)button {
    if ([self.touchBarDarkThemeButton.title isEqualToString:@"Dark Theme On"]) {
        [self.touchBarDarkThemeButton setTitle:@"Dark Theme Off"];
    }
    else {
        [self.touchBarDarkThemeButton setTitle:@"Dark Theme On"];
    }
    
    [MacGammaController toggleSystemTheme];
}

@end

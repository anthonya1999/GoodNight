//
//  ShadeViewController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 11/25/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import "ShadeViewController.h"
#import "TemperatureViewController.h"
#import "AppDelegate.h"

@implementation ShadeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [notificationCenter addObserver:self selector:@selector(defaultsChanged) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)defaultsChanged {
    [self.brightnessSlider setFloatValue:[userDefaults floatForKey:@"brightnessValue"]];
    [self.percentTextField setStringValue:[NSString stringWithFormat:@"%d%%", (int)round([userDefaults floatForKey:@"brightnessValue"] * 100)]];
}

- (void)dealloc {
    [notificationCenter removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    [self.view setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark]];
    [self.view.window setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark]];
    [self.view.layer setBackgroundColor:[[NSColor colorWithRed:_darkThemeFloatValue green:_darkThemeFloatValue blue:_darkThemeFloatValue alpha:1.0] CGColor]];
    
    [self.brightnessSlider setFloatValue:[userDefaults floatForKey:@"brightnessValue"]];
    [self.percentTextField setStringValue:[NSString stringWithFormat:@"%d%%", (int)round([userDefaults floatForKey:@"brightnessValue"] * 100)]];
}

- (IBAction)brightnessSliderDidChange:(NSSlider *)slider {
    [TemperatureViewController setInvertedColorsEnabled:NO];
    
    float sliderValue = self.brightnessSlider.floatValue;
    [userDefaults setFloat:sliderValue forKey:@"brightnessValue"];
    sliderValue = [userDefaults floatForKey:@"brightnessValue"];
    
    self.percentTextField.stringValue = [NSString stringWithFormat:@"%d%%", (int)round(sliderValue * 100)];
    [TemperatureViewController setGammaWithRed:sliderValue green:sliderValue blue:sliderValue];
    
    if (self.brightnessSlider.floatValue == 1) {
        [self resetBrightness:nil];
    }
    
    if (self.brightnessSlider.floatValue < 0.3) {
        float sliderValue = self.brightnessSlider.floatValue = 0.3;
        [userDefaults setFloat:sliderValue forKey:@"brightnessValue"];
        sliderValue = [userDefaults floatForKey:@"brightnessValue"];
        
        self.percentTextField.stringValue = [NSString stringWithFormat:@"%d%%", (int)round(sliderValue * 100)];
        [TemperatureViewController setGammaWithRed:sliderValue green:sliderValue blue:sliderValue];
        
        [ShadeViewController showBrightnessAlert];
    }
    
    [userDefaults synchronize];
}

+ (void)showBrightnessAlert {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Warning!"];
    [alert setInformativeText:@"If you set the brightness lower than the current level, you will not be able to see your screen!"];
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
}

- (IBAction)resetBrightness:(NSButton *)button {
    [TemperatureViewController resetAllAdjustments];
    self.brightnessSlider.floatValue = [userDefaults floatForKey:@"brightnessValue"];
    self.percentTextField.stringValue = @"100%";
}

@end

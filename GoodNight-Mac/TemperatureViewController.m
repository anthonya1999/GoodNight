//
//  ViewController.m
//  GoodNight-Mac
//
//  Created by Anthony Agatiello on 11/17/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import "TemperatureViewController.h"
#import "MacGammaController.h"
#import "AppDelegate.h"

@implementation TemperatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [defNotifCenter addObserver:self selector:@selector(defaultsChanged) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)defaultsChanged {
    [self.temperatureSlider setFloatValue:[userDefaults floatForKey:@"orangeValue"]];
    self.temperatureLabel.stringValue = [NSString stringWithFormat:@"Temperature: %dK", (int)round(((self.temperatureSlider.floatValue * 45 + 20) * 10) * 10)];
    [self.darkroomButton setState:[userDefaults boolForKey:@"darkroomEnabled"]];
    [self.darkThemeButton setState:[userDefaults boolForKey:@"darkThemeEnabled"]];
}

- (void)dealloc {
    [defNotifCenter removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    [self.view setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark]];
    [self.view.window setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark]];
    [self.view.layer setBackgroundColor:[[NSColor colorWithRed:_darkThemeFloatValue green:_darkThemeFloatValue blue:_darkThemeFloatValue alpha:1.0] CGColor]];
    
    [self.temperatureSlider setFloatValue:[userDefaults floatForKey:@"orangeValue"]];
    self.temperatureLabel.stringValue = [NSString stringWithFormat:@"Temperature: %dK", (int)round(((self.temperatureSlider.floatValue * 45 + 20) * 10) * 10)];
    [self.darkroomButton setState:[userDefaults boolForKey:@"darkroomEnabled"]];
    [self.darkThemeButton setState:[userDefaults boolForKey:@"darkThemeEnabled"]];
}

- (IBAction)sliderValueDidChange:(NSSlider *)slider {
    [MacGammaController setInvertedColorsEnabled:NO];
    
    [userDefaults setFloat:self.temperatureSlider.floatValue forKey:@"orangeValue"];
    [MacGammaController setGammaWithOrangeness:[userDefaults floatForKey:@"orangeValue"]];
    
    self.temperatureLabel.stringValue = [NSString stringWithFormat:@"Temperature: %dK", (int)round(((self.temperatureSlider.floatValue * 45 + 20) * 10) * 10)];
    
    if (self.temperatureSlider.floatValue == 1) {
        [self resetTemperature:nil];
    }
    
    [userDefaults setBool:NO forKey:@"darkroomEnabled"];
    [userDefaults setFloat:1 forKey:@"brightnessValue"];
    [userDefaults synchronize];
}

- (IBAction)toggleDarkroom:(NSButton *)button {
    self.temperatureSlider.floatValue = [userDefaults floatForKey:@"orangeValue"];
    self.temperatureLabel.stringValue = @"Temperature: 6500K";
    
    [MacGammaController toggleDarkroom];
    
    if (self.darkroomButton.state == NSOnState) {
        [self.darkroomButton setState:NSOnState];
    }
    else {
        [self.darkroomButton setState:NSOffState];
    }
}

- (IBAction)resetTemperature:(NSButton *)button {
    if ([userDefaults boolForKey:@"darkroomEnabled"]) {
        [self.darkroomButton setState:NSOffState];
    }
    
    self.temperatureSlider.floatValue = [userDefaults floatForKey:@"orangeValue"];
    self.temperatureLabel.stringValue = @"Temperature: 6500K";
    
    [MacGammaController resetAllAdjustments];
}

- (IBAction)toggleDarkTheme:(NSButton *)button {
    [MacGammaController toggleSystemTheme];
    
    if (self.darkThemeButton.state == NSOnState) {
        [self.darkThemeButton setState:NSOnState];
    }
    else {
        [self.darkThemeButton setState:NSOffState];
    }
}

@end

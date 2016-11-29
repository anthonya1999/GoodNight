//
//  ColorViewController.m
//  GoodNight-Mac
//
//  Created by Anthony Agatiello on 11/23/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import "ColorViewController.h"
#import "TemperatureViewController.h"

@implementation ColorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.colorWell addObserver:self forKeyPath:@"color" options:0 context:nil];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    [self.view setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark]];
    [self.view.window setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark]];
    [self.view.layer setBackgroundColor:[[NSColor colorWithRed:(float)33/255 green:(float)33/255 blue:(float)33/255 alpha:1.0] CGColor]];
}

- (void)dealloc {
    [self.colorWell removeObserver:self forKeyPath:@"color"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSColor *color = [self.colorWell color];
    
    float redValue = [color redComponent];
    float greenValue = [color greenComponent];
    float blueValue = [color blueComponent];
    
    [TemperatureViewController setGammaWithRed:redValue green:greenValue blue:blueValue];
    
    [userDefaults setFloat:1 forKey:@"orangeValue"];
    [userDefaults setBool:NO forKey:@"darkroomEnabled"];
    [userDefaults synchronize];
}

- (IBAction)resetColor:(NSButton *)button {
    [userDefaults setFloat:1 forKey:@"orangeValue"];
    [userDefaults setFloat:1 forKey:@"brightnessValue"];
    [userDefaults setBool:NO forKey:@"darkroomEnabled"];
    [userDefaults synchronize];
    CGDisplayRestoreColorSyncSettings();
    [TemperatureViewController setInvertedColorsEnabled:NO];
}

@end

//
//  WhitePointMacViewController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 12/9/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import "WhitePointMacViewController.h"
#import "AppDelegate.h"
#import "MacGammaController.h"

@implementation WhitePointMacViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [defNotifCenter addObserver:self selector:@selector(defaultsChanged) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    [self.view setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark]];
    [self.view.window setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark]];
    [self.view.layer setBackgroundColor:[[NSColor colorWithRed:_darkThemeFloatValue green:_darkThemeFloatValue blue:_darkThemeFloatValue alpha:1.0] CGColor]];
    
    [self.whitePointSlider setFloatValue:[userDefaults floatForKey:@"whitePointValue"]];
    [self.whitePointLabel setStringValue:[NSString stringWithFormat:@"%d%%", (int)round([userDefaults floatForKey:@"whitePointValue"] * 100) * 2]];
}

- (void)dealloc {
    [defNotifCenter removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)defaultsChanged {
    [self.whitePointSlider setFloatValue:[userDefaults floatForKey:@"whitePointValue"]];
    [self.whitePointLabel setStringValue:[NSString stringWithFormat:@"%d%%", (int)round([userDefaults floatForKey:@"whitePointValue"] * 100) * 2]];
}

- (IBAction)whitePointSliderDidChange:(NSSlider *)slider {
    [userDefaults setFloat:self.whitePointSlider.floatValue forKey:@"whitePointValue"];
    self.whitePointLabel.stringValue = [NSString stringWithFormat:@"%d%%", (int)round([userDefaults floatForKey:@"whitePointValue"] * 100) * 2];

    [MacGammaController setWhitePoint:[userDefaults floatForKey:@"whitePointValue"]];
    
    [userDefaults setBool:NO forKey:@"darkroomEnabled"];
    [userDefaults setFloat:1 forKey:@"brightnessValue"];
    [userDefaults setFloat:1 forKey:@"orangeValue"];
    [userDefaults synchronize];
}

- (IBAction)resetWhitePoint:(NSButton *)button {
    self.whitePointSlider.floatValue = [userDefaults floatForKey:@"whitePointValue"];
    self.whitePointLabel.stringValue = @"100%";
    [MacGammaController resetAllAdjustments];
}

@end

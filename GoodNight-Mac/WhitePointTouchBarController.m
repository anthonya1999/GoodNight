//
//  WhitePointTouchBarController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 12/9/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import "WhitePointTouchBarController.h"
#import "MacGammaController.h"

@implementation WhitePointTouchBarController

- (void)awakeFromNib {
    [self.whitePointTouchBarSlider.slider setFloatValue:[userDefaults floatForKey:@"whitePointValue"]];
    self.whitePointTouchBarSlider.label = [NSString stringWithFormat:@"%d%%", (int)round([userDefaults floatForKey:@"whitePointValue"] * 100) * 2];
    
    [defNotifCenter addObserver:self selector:@selector(defaultsChanged) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)defaultsChanged {
    [self.whitePointTouchBarSlider.slider setFloatValue:[userDefaults floatForKey:@"whitePointValue"]];
    self.whitePointTouchBarSlider.label = [NSString stringWithFormat:@"%d%%", (int)round([userDefaults floatForKey:@"whitePointValue"] * 100) * 2];
}

- (IBAction)whitePointTouchBarChanged:(NSSliderTouchBarItem *)slider {
    [userDefaults setFloat:self.whitePointTouchBarSlider.slider.floatValue forKey:@"whitePointValue"];
    self.whitePointTouchBarSlider.label = [NSString stringWithFormat:@"%d%%", (int)round([userDefaults floatForKey:@"whitePointValue"] * 100) * 2];
    
    [MacGammaController setWhitePoint:[userDefaults floatForKey:@"whitePointValue"]];
}

- (IBAction)resetWhitePoint:(NSButton *)button {
    [MacGammaController resetAllAdjustments];
    self.whitePointTouchBarSlider.label = @"100%";
    self.whitePointTouchBarSlider.slider.floatValue = [userDefaults floatForKey:@"whitePointValue"];
}

@end

//
//  WhitePointViewController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 12/18/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "WhitePointViewController.h"
#import "GammaController.h"
#import "IOMobileFramebufferClient.h"
#import "AppDelegate.h"

@implementation WhitePointViewController

- (instancetype)init
{
    self = [AppDelegate initWithIdentifier:@"whitepointController"];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![[IOMobileFramebufferClient sharedInstance] gamutMatrixFunctionIsUsable]) {
        self.whitePointSlider.minimumValue = 0.43110;
    }
    else {
        self.whitePointSlider.minimumValue = 0.25009;
    }
    
    self.whitePointSlider.maximumValue = 0.65535;
    self.whitePointSlider.value = [userDefaults floatForKey:@"whitePointValue"];
    self.whitePointSwitch.on = [userDefaults boolForKey:@"whitePointEnabled"];
}

- (IBAction)whitePointSliderChanged {
    [userDefaults setFloat:self.whitePointSlider.value forKey:@"whitePointValue"];
    
    if (self.whitePointSwitch.on) {
        [[IOMobileFramebufferClient sharedInstance] setBrightnessCorrection:[userDefaults floatForKey:@"whitePointValue"] * 100000];
    }
}

- (IBAction)whitePointSwitchChanged {
    [userDefaults setBool:self.whitePointSwitch.on forKey:@"whitePointEnabled"];
    
    if (self.whitePointSwitch.on) {
        if ([[IOMobileFramebufferClient sharedInstance] gamutMatrixFunctionIsUsable]) {
            [userDefaults setBool:NO forKey:@"enabled"];
            [GammaController setGammaWithMatrixAndRed:1 green:1 blue:1];
        }
        [[IOMobileFramebufferClient sharedInstance] setBrightnessCorrection:[userDefaults floatForKey:@"whitePointValue"] * 100000];
    }
    else {
        [[IOMobileFramebufferClient sharedInstance] setBrightnessCorrection:IOMobileFramebufferBrightnessCorrectionDefault];
    }
}

- (IBAction)whitePointValueReset {
    self.whitePointSlider.value = self.whitePointSlider.maximumValue;
    [userDefaults setFloat:self.whitePointSlider.value forKey:@"whitePointValue"];
    
    if (self.whitePointSwitch.on) {
        [[IOMobileFramebufferClient sharedInstance] setBrightnessCorrection:[userDefaults floatForKey:@"whitePointValue"] * 100000];
    }
}

@end
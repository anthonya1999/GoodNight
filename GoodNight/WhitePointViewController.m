//
//  WhitePointViewController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 12/18/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "WhitePointViewController.h"
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
    
    self.whitePointSlider.minimumValue = 0.25009;
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
        [[IOMobileFramebufferClient sharedInstance] setBrightnessCorrection:[userDefaults floatForKey:@"whitePointValue"] * 100000];
    }
    else {
        [[IOMobileFramebufferClient sharedInstance] setBrightnessCorrection:IOMobileFramebufferBrightnessCorrectionDefault];
    }
}

@end
//
//  WhitePointViewController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 12/18/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "WhitePointViewController.h"
#import "GammaController.h"
#import "AppDelegate.h"

@implementation WhitePointViewController

- (instancetype)init
{
    self = [AppDelegate initWithIdentifier:@"whitepointController"];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.whitePointSlider.minimumValue = ((float)[GammaController getMinimumWhitePoint]) / 100000;
    self.whitePointSlider.maximumValue = 0.65535;
    [self updateUI];
}

- (void)updateUI {
    self.whitePointSlider.value = [groupDefaults floatForKey:@"whitePointValue"];
    self.whitePointSwitch.on = [groupDefaults boolForKey:@"whitePointEnabled"];
    
    float brightness = self.whitePointSlider.value;
    
    self.whitePointSwitch.onTintColor = [UIColor colorWithRed:(1.0f-brightness)*0.9f green:((2.0f-brightness)/2.0f)*0.9f blue:0.9f alpha:1.0];
    self.whitePointSlider.tintColor = [UIColor colorWithRed:(1.0f-brightness)*0.9f green:((2.0f-brightness)/2.0f)*0.9f blue:0.9f alpha:1.0];
}

- (IBAction)whitePointSliderChanged {
    [groupDefaults setFloat:self.whitePointSlider.value forKey:@"whitePointValue"];
    
    if (self.whitePointSwitch.on) {
        [GammaController setWhitePoint:[groupDefaults floatForKey:@"whitePointValue"] * 100000];
    }
}

- (IBAction)whitePointSwitchChanged {
    BOOL adjustmentsEnabled = [AppDelegate checkAlertNeededWithViewController:self
                andExecutionBlock:^(UIAlertAction *action) {
                    [GammaController disableColorAdjustment];
                    [groupDefaults setBool:NO forKey:@"enabled"];
                    [groupDefaults setBool:NO forKey:@"rgbEnabled"];
                    [groupDefaults setBool:NO forKey:@"dimEnabled"];
                    [groupDefaults setBool:YES forKey:@"whitePointEnabled"];
                    [self.whitePointSwitch setOn:YES animated:YES];
                    [self whitePointSwitchChanged];
                }
                forKeys:@"enabled", @"rgbEnabled", @"dimEnabled", nil];
    
    if (!adjustmentsEnabled) {
        [groupDefaults setBool:self.whitePointSwitch.on forKey:@"whitePointEnabled"];
        
        if (self.whitePointSwitch.on) {
            [GammaController setWhitePoint:[groupDefaults floatForKey:@"whitePointValue"] * 100000];
        }
        else {
            [GammaController resetWhitePoint];
        }
    }
    
    [self updateUI];
}

- (IBAction)whitePointValueReset {
    self.whitePointSlider.value = self.whitePointSlider.maximumValue;
    [groupDefaults setFloat:self.whitePointSlider.value forKey:@"whitePointValue"];
    
    if (self.whitePointSwitch.on) {
        [GammaController setWhitePoint:[groupDefaults floatForKey:@"whitePointValue"] * 100000];
    }
}

- (void)enableOrDisableBasedOnDefaults {
    if ([groupDefaults boolForKey:@"whitePointEnabled"]) {
        [GammaController resetWhitePoint];
        [groupDefaults setBool:NO forKey:@"whitePointEnabled"];
    }
    else {
        [GammaController setWhitePoint:[groupDefaults floatForKey:@"whitePointValue"] * 100000];
        [groupDefaults setBool:YES forKey:@"whitePointEnabled"];
    }
}

- (NSArray <id <UIPreviewActionItem>> *)previewActionItems {
    NSString *title = nil;
    if ([groupDefaults boolForKey:@"whitePointEnabled"]) {
        title = @"Disable";
    }
    else {
        title = @"Enable";
    }
    UIPreviewAction *enableDisableAction = [UIPreviewAction actionWithTitle:title style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self enableOrDisableBasedOnDefaults];
    }];
    UIPreviewAction * _Nullable cancelAction = [UIPreviewAction actionWithTitle:@"Cancel" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {}];
    return @[enableDisableAction, cancelAction];
}

@end
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
    self.whitePointSlider.value = [userDefaults floatForKey:@"whitePointValue"];
    self.whitePointSwitch.on = [userDefaults boolForKey:@"whitePointEnabled"];
    
    float brightness = self.whitePointSlider.value;
    
    self.whitePointSwitch.onTintColor = [UIColor colorWithRed:(1.0f-brightness)*0.9f green:((2.0f-brightness)/2.0f)*0.9f blue:0.9f alpha:1.0];
    self.whitePointSlider.tintColor = [UIColor colorWithRed:(1.0f-brightness)*0.9f green:((2.0f-brightness)/2.0f)*0.9f blue:0.9f alpha:1.0];
}

- (IBAction)whitePointSliderChanged {
    [userDefaults setFloat:self.whitePointSlider.value forKey:@"whitePointValue"];
    
    if (self.whitePointSwitch.on) {
        [GammaController setWhitePoint:[userDefaults floatForKey:@"whitePointValue"] * 100000];
    }
}

- (IBAction)whitePointSwitchChanged {
    if (![GammaController adjustmentForKeysEnabled:@"enabled", @"rgbEnabled", @"dimEnabled", nil]) {
        [userDefaults setBool:self.whitePointSwitch.on forKey:@"whitePointEnabled"];
        
        if (self.whitePointSwitch.on) {
            [GammaController setWhitePoint:[userDefaults floatForKey:@"whitePointValue"] * 100000];
        }
        else {
            [GammaController resetWhitePoint];
        }
    }
    
    else {
        NSString *title = @"Error";
        NSString *message = @"You may only use one adjustment at a time. Please disable any other adjustments before enabling this one.";
        NSString *cancelButton = @"Cancel";
        NSString *disableButton = @"Disable";
        
        if (NSClassFromString(@"UIAlertController") != nil) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:cancelButton style:UIAlertActionStyleCancel handler:nil]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:disableButton style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                [GammaController disableColorAdjustment];
                [userDefaults setBool:NO forKey:@"enabled"];
                [userDefaults setBool:NO forKey:@"rgbEnabled"];
                [userDefaults setBool:NO forKey:@"dimEnabled"];
                [userDefaults setBool:YES forKey:@"whitePointEnabled"];
                [self.whitePointSwitch setOn:YES animated:YES];
                [self whitePointSwitchChanged];
            }]];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButton otherButtonTitles:nil];
            
            [alertView show];
        }
    }
    
    [self updateUI];
}

- (IBAction)whitePointValueReset {
    self.whitePointSlider.value = self.whitePointSlider.maximumValue;
    [userDefaults setFloat:self.whitePointSlider.value forKey:@"whitePointValue"];
    
    if (self.whitePointSwitch.on) {
        [GammaController setWhitePoint:[userDefaults floatForKey:@"whitePointValue"] * 100000];
    }
}

- (void)enableOrDisableBasedOnDefaults {
    if ([userDefaults boolForKey:@"whitePointEnabled"]) {
        [GammaController resetWhitePoint];
        [userDefaults setBool:NO forKey:@"whitePointEnabled"];
    }
    else {
        [GammaController setWhitePoint:[userDefaults floatForKey:@"whitePointValue"] * 100000];
        [userDefaults setBool:YES forKey:@"whitePointEnabled"];
    }
}

- (NSArray <id <UIPreviewActionItem>> *)previewActionItems {
    NSString *title = nil;
    if ([userDefaults boolForKey:@"whitePointEnabled"]) {
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
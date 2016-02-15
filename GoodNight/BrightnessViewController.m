//
//  BrightnessViewController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 10/4/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "BrightnessViewController.h"
#import "AppDelegate.h"
#import "GammaController.h"

@implementation BrightnessViewController

- (instancetype)init
{
    self = [AppDelegate initWithIdentifier:@"brightnessViewController"];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateUI];
    
    warningIgnored = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)userDefaultsChanged:(NSNotification *)notification {
    [self updateUI];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self updateUI];
}

- (void)updateUI {
    self.dimSlider.value = [groupDefaults floatForKey:@"dimLevel"];
    self.dimSwitch.on = [groupDefaults boolForKey:@"dimEnabled"];
    self.darkroomSwitch.on = [groupDefaults boolForKey:@"darkroomEnabled"];
    
    if (self.dimSwitch.on) {
        self.darkroomSwitch.enabled = NO;
    }
    else {
        self.darkroomSwitch.enabled = YES;
    }
    
    if (self.darkroomSwitch.on) {
        self.dimSwitch.enabled = NO;
        self.dimSlider.enabled = NO;
    }
    else {
        self.dimSwitch.enabled = YES;
        self.dimSlider.enabled = YES;
    }
    
    float brightness = self.dimSlider.value;
    
    self.dimSwitch.onTintColor = [UIColor colorWithRed:(1.0f-brightness)*0.9f green:((2.0f-brightness)/2.0f)*0.9f blue:0.9f alpha:1.0];
    self.dimSlider.tintColor = [UIColor colorWithRed:(1.0f-brightness)*0.9f green:((2.0f-brightness)/2.0f)*0.9f blue:0.9f alpha:1.0];
    
}

- (IBAction)brightnessSwitchChanged {
    BOOL adjustmentsEnabled = [AppDelegate checkAlertNeededWithViewController:self
                andExecutionBlock:^(UIAlertAction *action) {
                    [groupDefaults setBool:NO forKey:@"enabled"];
                    [groupDefaults setBool:NO forKey:@"rgbEnabled"];
                    [groupDefaults setBool:NO forKey:@"whitePointEnabled"];
                    [groupDefaults setBool:YES forKey:@"dimEnabled"];
                    [self brightnessSwitchChanged];
                }
                forKeys:@"enabled", @"rgbEnabled", @"whitePointEnabled", nil];
    
    if (!adjustmentsEnabled) {
        [groupDefaults setBool:self.dimSwitch.on forKey:@"dimEnabled"];
        [groupDefaults setObject:[NSDate distantPast] forKey:@"lastAutoChangeDate"];

        if (self.dimSwitch.on) {
            [GammaController enableDimness];
        }
        else {
            [GammaController disableDimness];
        }
    }
    
    [self updateUI];
}

- (IBAction)darkroomSwitchChanged {
    BOOL adjustmentsEnabled = [AppDelegate checkAlertNeededWithViewController:self
                andExecutionBlock:^(UIAlertAction *action) {
                    [groupDefaults setBool:NO forKey:@"enabled"];
                    [groupDefaults setBool:NO forKey:@"rgbEnabled"];
                    [groupDefaults setBool:NO forKey:@"whitePointEnabled"];
                    [groupDefaults setBool:NO forKey:@"dimEnabled"];
                    [self.darkroomSwitch setOn:YES animated:YES];
                    [self darkroomSwitchChanged];
                }
                forKeys:@"enabled", @"rgbEnabled", @"whitePointEnabled", nil];
    
    if (!adjustmentsEnabled) {
        [groupDefaults setBool:self.darkroomSwitch.on forKey:@"darkroomEnabled"];
        [groupDefaults setObject:[NSDate distantPast] forKey:@"lastAutoChangeDate"];

        if (self.darkroomSwitch.on) {
            [GammaController setDarkroomEnabled:YES];
        }
        else {
            [GammaController setDarkroomEnabled:NO];
        }
    }

    [self updateUI];
}

- (IBAction)dimSliderLevelChanged {
    if (self.dimSlider.value < 0.1f && !warningIgnored){
        if (![self presentedViewController]){
            NSString *title = @"Warning";
            NSString *message = @"If you further reduce the brightness, your screen will go completely dark! If you accidently do this, you can restart your device to undo the effect.";
            NSString *cancelButton = @"Cancel";
            NSString *acknowledgeButton = @"Ignore";
            NSString *darkroomButton = @"Enable Darkroom";
            
            if (NSClassFromString(@"UIAlertController") != nil) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
                
                [alertController addAction:[UIAlertAction actionWithTitle:cancelButton style:UIAlertActionStyleCancel handler:nil]];
                
                [alertController addAction:[UIAlertAction actionWithTitle:acknowledgeButton style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                    warningIgnored = YES;
                }]];
                
                [alertController addAction:[UIAlertAction actionWithTitle:darkroomButton style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self.darkroomSwitch setOn:YES animated:YES];
                    [self darkroomSwitchChanged];
                }]];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButton otherButtonTitles:acknowledgeButton,darkroomButton,nil];
                
                [alertView show];
            }
        }
        
        self.dimSlider.value = 0.1f;
    }
    
    
    [groupDefaults setFloat:self.dimSlider.value forKey:@"dimLevel"];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.dimSwitch.on && !self.darkroomSwitch.on) {
        [GammaController setDarkroomEnabled:NO];
        [GammaController enableDimness];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Ignore"]){
        warningIgnored = YES;
    }
    else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Enable Darkroom"]){
        [self.darkroomSwitch setOn:YES animated:YES];
        [self darkroomSwitchChanged];
    }
}

- (IBAction)resetSlider {
    self.dimSlider.value = 1.0;
    [groupDefaults setFloat:self.dimSlider.value forKey:@"dimLevel"];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    
    
    [self.darkroomSwitch setOn:NO animated:YES];
    [groupDefaults setBool:NO forKey:@"darkroomEnabled"];
    [GammaController setDarkroomEnabled:NO];
    
    if (self.dimSwitch.on) {
        [GammaController enableDimness];
    }
}

- (NSArray <id <UIPreviewActionItem>> *)previewActionItems {
    NSString *title = nil;
    
    if (![groupDefaults boolForKey:@"dimEnabled"]) {
        title = @"Enable";
    }
    else if ([groupDefaults boolForKey:@"dimEnabled"]) {
        title = @"Disable";
    }
    
    UIPreviewAction *enableDisableAction = [UIPreviewAction actionWithTitle:title style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self enableOrDisableBasedOnDefaults];
    }];
    UIPreviewAction *cancelButton = [UIPreviewAction actionWithTitle:@"Cancel" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {}];
    
    return @[enableDisableAction, cancelButton];
}

- (void)enableOrDisableBasedOnDefaults {
    if (![groupDefaults boolForKey:@"dimEnabled"]) {
        [GammaController enableDimness];
    }
    else if ([groupDefaults boolForKey:@"dimEnabled"]) {
        [GammaController disableDimness];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerText = @"";
    if (tableView) {
        if (section == 1) {
            headerText = [NSString stringWithFormat:@"Level (%.2f)", (self.dimSlider.value * 10)];
        }
    }
    return headerText;
}

@end
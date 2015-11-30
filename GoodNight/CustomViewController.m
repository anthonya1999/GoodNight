//
//  CustomViewController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 10/4/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "CustomViewController.h"
#import "GammaController.h"
#import "AppDelegate.h"

@implementation CustomViewController

- (instancetype)init
{
    self = [AppDelegate initWithIdentifier:@"colorViewController"];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)userDefaultsChanged:(NSNotification *)notification {
    [self updateUI];
}

- (void)updateUI {
    self.rgbSwitch.on = [userDefaults boolForKey:@"rgbEnabled"];
    self.redSlider.value = [userDefaults floatForKey:@"redValue"];
    self.greenSlider.value = [userDefaults floatForKey:@"greenValue"];
    self.blueSlider.value = [userDefaults floatForKey:@"blueValue"];
    
    self.rgbSwitch.onTintColor = [UIColor colorWithRed:self.redSlider.value*0.8f green:self.greenSlider.value*0.8f blue:self.blueSlider.value*0.8f alpha:1.0];
    self.redSlider.tintColor = [UIColor colorWithRed:1.0f green:1.0f-self.redSlider.value blue:1.0f-self.redSlider.value alpha:1.0];
    self.greenSlider.tintColor = [UIColor colorWithRed:1.0f-self.greenSlider.value green:1.0f blue:1.0f-self.greenSlider.value alpha:1.0];
    self.blueSlider.tintColor = [UIColor colorWithRed:1.0f-self.blueSlider.value green:1.0f-self.blueSlider.value blue:1.0f alpha:1.0];
}

- (IBAction)redChanged {
    [self updateDisplayColorWithValue:self.redSlider.value forKey:@"redValue"];
}

- (IBAction)greenChanged {
    [self updateDisplayColorWithValue:self.greenSlider.value forKey:@"greenValue"];
}

- (IBAction)blueChanged {
    [self updateDisplayColorWithValue:self.blueSlider.value forKey:@"blueValue"];
}

- (IBAction)colorSwitchChanged {
    [userDefaults setBool:self.rgbSwitch.on forKey:@"rgbEnabled"];
        
    if (self.rgbSwitch.on) {
        [GammaController setGammaWithCustomValues];
    }
    else {
        [GammaController disableColorAdjustment];
    }
    [self viewDidLoad];
}

- (void)updateDisplayColorWithValue:(float)value forKey:(NSString *)key {
    if (value != 0 && key != nil) {
        [userDefaults setFloat:value forKey:key];
    }
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.rgbSwitch.on) {
        [GammaController setGammaWithCustomValues];
    }
}

- (IBAction)resetDisplayColor {
    self.redSlider.value = 1.0;
    [userDefaults setFloat:self.redSlider.value forKey:@"redValue"];
    
    self.greenSlider.value = 1.0;
    [userDefaults setFloat:self.greenSlider.value forKey:@"greenValue"];
    
    self.blueSlider.value = 1.0;
    [userDefaults setFloat:self.blueSlider.value forKey:@"blueValue"];
    
    [self updateDisplayColorWithValue:0 forKey:nil];
}

- (NSArray <id <UIPreviewActionItem>> *)previewActionItems {
    UIPreviewAction *redColor = [UIPreviewAction actionWithTitle:@"Red" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self setGammaWithRedColor];
    }];
    UIPreviewAction *greenColor = [UIPreviewAction actionWithTitle:@"Green" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self setGammaWithGreenColor];
    }];
    UIPreviewAction *blueColor = [UIPreviewAction actionWithTitle:@"Blue" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self setGammaWithBlueColor];
    }];
    UIPreviewAction *cancelButton = [UIPreviewAction actionWithTitle:@"Cancel" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {}];
    return @[redColor, greenColor, blueColor, cancelButton];
}

- (void)setGammaWithRedColor {
    [userDefaults setFloat:1.0 forKey:@"redValue"];
    [userDefaults setFloat:0.0 forKey:@"greenValue"];
    [userDefaults setFloat:0.0 forKey:@"blueValue"];
    [GammaController setGammaWithCustomValues];
}

- (void)setGammaWithGreenColor {
    [userDefaults setFloat:0.0 forKey:@"redValue"];
    [userDefaults setFloat:1.0 forKey:@"greenValue"];
    [userDefaults setFloat:0.0 forKey:@"blueValue"];
    [GammaController setGammaWithCustomValues];
}

- (void)setGammaWithBlueColor {
    [userDefaults setFloat:0.0 forKey:@"redValue"];
    [userDefaults setFloat:0.0 forKey:@"greenValue"];
    [userDefaults setFloat:1.0 forKey:@"blueValue"];
    [GammaController setGammaWithCustomValues];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerText = @"";
    if (tableView) {
        if (section == 1) {
            headerText = [NSString stringWithFormat:@"Red (%.2f)", (self.redSlider.value * 10)];
        }
        if (section == 2) {
            headerText = [NSString stringWithFormat:@"Green (%.2f)", (self.greenSlider.value * 10)];
        }
        if (section == 3) {
            headerText = [NSString stringWithFormat:@"Blue (%.2f)", (self.blueSlider.value * 10)];
        }
    }
    return headerText;
}

@end
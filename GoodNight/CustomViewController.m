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
    
    warningIgnored = NO;
    
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


- (void)checkWarningIssued:(UISlider*)currentSlider{
    if (self.redSlider.value+self.greenSlider.value+self.blueSlider.value < 0.2f && !warningIgnored){
        if (![self presentedViewController]){
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:@"If you further reduce the color your screen will go completely dark!" preferredStyle:UIAlertControllerStyleAlert];
        
                [alertController addAction:[UIAlertAction actionWithTitle:@"Understood" style:UIAlertActionStyleDefault handler:nil]];
        
                [alertController addAction:[UIAlertAction actionWithTitle:@"I know what I'm doing" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                    warningIgnored = YES;
                }]];

                [self presentViewController:alertController animated:YES completion:nil];
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"If you further reduce the color your screen will go completely dark!" delegate:self cancelButtonTitle:@"Understood" otherButtonTitles:@"I know what I'm doing",nil];
                
                [alertView show];
            }
        }
        
        float minValue = 0.3f-(self.redSlider.value+self.greenSlider.value+self.blueSlider.value-currentSlider.value);
        
        currentSlider.value = minValue;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"I know what I'm doing"]){
        warningIgnored = YES;
    }
}

- (IBAction)redChanged {
    [self checkWarningIssued:self.redSlider];
    
    [self updateDisplayColorWithValue:self.redSlider.value forKey:@"redValue"];
}

- (IBAction)greenChanged {
    [self checkWarningIssued:self.greenSlider];
    
    [self updateDisplayColorWithValue:self.greenSlider.value forKey:@"greenValue"];
}

- (IBAction)blueChanged {
    [self checkWarningIssued:self.blueSlider];
    
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
    if ( key != nil) {
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
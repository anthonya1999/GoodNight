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
    self.rgbSwitch.on = [groupDefaults boolForKey:@"rgbEnabled"];
    self.redSlider.value = [groupDefaults floatForKey:@"redValue"];
    self.greenSlider.value = [groupDefaults floatForKey:@"greenValue"];
    self.blueSlider.value = [groupDefaults floatForKey:@"blueValue"];
    
    self.rgbSwitch.onTintColor = [UIColor colorWithRed:self.redSlider.value*0.8f green:self.greenSlider.value*0.8f blue:self.blueSlider.value*0.8f alpha:1.0];
    self.redSlider.tintColor = [UIColor colorWithRed:1.0f green:1.0f-self.redSlider.value blue:1.0f-self.redSlider.value alpha:1.0];
    self.greenSlider.tintColor = [UIColor colorWithRed:1.0f-self.greenSlider.value green:1.0f blue:1.0f-self.greenSlider.value alpha:1.0];
    self.blueSlider.tintColor = [UIColor colorWithRed:1.0f-self.blueSlider.value green:1.0f-self.blueSlider.value blue:1.0f alpha:1.0];
}


- (void)checkWarningIssued:(UISlider*)currentSlider{
    if (self.redSlider.value+self.greenSlider.value+self.blueSlider.value < 0.2f && !warningIgnored){
        if (![self presentedViewController]){
            NSString *title = NSLocalizedString(@"Cancel", @"");
            NSString *message = NSLocalizedString(@"If you further reduce the color your screen will go completely dark!", @"");
            NSString *cancelButton = NSLocalizedString(@"Understood", @"");
            NSString *acknowledgeButton = NSLocalizedString(@"Ignore", @"");
            
            if (NSClassFromString(@"UIAlertController") != nil) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
                [alertController addAction:[UIAlertAction actionWithTitle:cancelButton style:UIAlertActionStyleDefault handler:nil]];
        
                [alertController addAction:[UIAlertAction actionWithTitle:acknowledgeButton style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                    warningIgnored = YES;
                }]];

                [self presentViewController:alertController animated:YES completion:nil];
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButton otherButtonTitles:acknowledgeButton,nil];
                
                [alertView show];
            }
        }
        
        float minValue = 0.3f-(self.redSlider.value+self.greenSlider.value+self.blueSlider.value-currentSlider.value);
        
        currentSlider.value = minValue;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Ignore", @"")]){
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
    BOOL adjustmentsEnabled = [AppDelegate checkAlertNeededWithViewController:self
                andExecutionBlock:^(UIAlertAction *action) {
                    [groupDefaults setBool:NO forKey:@"enabled"];
                    [groupDefaults setBool:NO forKey:@"dimEnabled"];
                    [groupDefaults setBool:NO forKey:@"whitePointEnabled"];
                    [groupDefaults setBool:YES forKey:@"rgbEnabled"];
                    [GammaController setDarkroomEnabled:NO];
                    [self colorSwitchChanged];
                }
                forKeys:@"enabled", @"dimEnabled",@"whitePointEnabled", nil];
    
    if (!adjustmentsEnabled) {
        [groupDefaults setBool:self.rgbSwitch.on forKey:@"rgbEnabled"];
        [groupDefaults setObject:[NSDate distantPast] forKey:@"lastAutoChangeDate"];
        
        if (self.rgbSwitch.on) {
            [GammaController setGammaWithCustomValues];
        }
        else {
            [GammaController disableColorAdjustment];
        }
    }
    
    [self updateUI];
}

- (void)updateDisplayColorWithValue:(float)value forKey:(NSString *)key {
    if ( key != nil) {
        [groupDefaults setFloat:value forKey:key];
    }
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.rgbSwitch.on) {
        [GammaController setGammaWithCustomValues];
    }
}

- (IBAction)resetDisplayColor {
    self.redSlider.value = 1.0;
    [groupDefaults setFloat:self.redSlider.value forKey:@"redValue"];
    
    self.greenSlider.value = 1.0;
    [groupDefaults setFloat:self.greenSlider.value forKey:@"greenValue"];
    
    self.blueSlider.value = 1.0;
    [groupDefaults setFloat:self.blueSlider.value forKey:@"blueValue"];
    
    [self updateDisplayColorWithValue:0 forKey:nil];
}

- (NSArray <id <UIPreviewActionItem>> *)previewActionItems {
    UIPreviewAction *redColor = [UIPreviewAction actionWithTitle:NSLocalizedString(@"Red", @"") style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self setGammaWithRedColor];
    }];
    UIPreviewAction *greenColor = [UIPreviewAction actionWithTitle:NSLocalizedString(@"Green", @"") style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self setGammaWithGreenColor];
    }];
    UIPreviewAction *blueColor = [UIPreviewAction actionWithTitle:NSLocalizedString(@"Blue", @"") style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self setGammaWithBlueColor];
    }];
    UIPreviewAction *cancelButton = [UIPreviewAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {}];
    return @[redColor, greenColor, blueColor, cancelButton];
}

- (void)setGammaWithRedColor {
    [groupDefaults setFloat:1.0 forKey:@"redValue"];
    [groupDefaults setFloat:0.0 forKey:@"greenValue"];
    [groupDefaults setFloat:0.0 forKey:@"blueValue"];
    [GammaController setGammaWithCustomValues];
}

- (void)setGammaWithGreenColor {
    [groupDefaults setFloat:0.0 forKey:@"redValue"];
    [groupDefaults setFloat:1.0 forKey:@"greenValue"];
    [groupDefaults setFloat:0.0 forKey:@"blueValue"];
    [GammaController setGammaWithCustomValues];
}

- (void)setGammaWithBlueColor {
    [groupDefaults setFloat:0.0 forKey:@"redValue"];
    [groupDefaults setFloat:0.0 forKey:@"greenValue"];
    [groupDefaults setFloat:1.0 forKey:@"blueValue"];
    [GammaController setGammaWithCustomValues];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerText = @"";
    if (tableView) {
        if (section == 1) {
            headerText = [NSString stringWithFormat:NSLocalizedString(@"Red (%.2f)", @""), (self.redSlider.value * 10)];
        }
        if (section == 2) {
            headerText = [NSString stringWithFormat:NSLocalizedString(@"Green (%.2f)", @""), (self.greenSlider.value * 10)];
        }
        if (section == 3) {
            headerText = [NSString stringWithFormat:NSLocalizedString(@"Blue (%.2f)", @""), (self.blueSlider.value * 10)];
        }
    }
    return headerText;
}

@end
//
//  ViewController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 6/22/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import "GammaController.h"


// The multiple (in degrees Kelvin) to round orange values to
#define ORANGE_VALUE_INCREMENT 100.0f

// Given an currentOrangeValue as a float in the range [0.0, 1.0], converts it to Kelvin, rounds
// to the nearest ORANGE_VALUE_INCREMENT, and returns the new orange value as a float.
float roundOrangeValue(float currentOrangeValue) {
    // Get the current slider value in Kelvin (rounded
    float temperature = (currentOrangeValue * 4500.0f) + 2000.0f;

    // Round to the nearest ORANGE_VALUE_INCREMENT degree Kelvin
    float temperatureRounded = roundf(temperature / ORANGE_VALUE_INCREMENT) * ORANGE_VALUE_INCREMENT;

    // Convert back to float value in range [0.0, 1.0] to get slider value
    return ((temperatureRounded - 2000.0f) / 4500.0f);
}


@implementation MainViewController

- (instancetype)init
{
    self = [AppDelegate initWithIdentifier:@"mainViewController"];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.timeFormatter = [[NSDateFormatter alloc] init];
        self.timeFormatter.timeStyle = NSDateFormatterShortStyle;
        self.timeFormatter.dateStyle = NSDateFormatterNoStyle;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.timePicker = [[UIDatePicker alloc] init];
    self.timePicker.datePickerMode = UIDatePickerModeTime;
    self.timePicker.minuteInterval = 15;
    self.timePicker.backgroundColor = [UIColor whiteColor];
    [self.timePicker addTarget:self action:@selector(timePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.endTimeTextField.inputView = self.timePicker;
    self.startTimeTextField.inputView = self.timePicker;
    self.endTimeNightTextField.inputView = self.timePicker;
    self.startTimeNightTextField.inputView = self.timePicker;
    
    self.timePickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toolbarDoneButtonClicked:)];
    [self.timePickerToolbar setItems:@[doneButton]];
    
    self.endTimeTextField.inputAccessoryView = self.timePickerToolbar;
    self.startTimeTextField.inputAccessoryView = self.timePickerToolbar;
    self.endTimeNightTextField.inputAccessoryView = self.timePickerToolbar;
    self.startTimeNightTextField.inputAccessoryView = self.timePickerToolbar;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    
    self.endTimeTextField.delegate = self;
    self.startTimeTextField.delegate = self;
    self.endTimeNightTextField.delegate = self;
    self.startTimeNightTextField.delegate = self;
    
    
    if ([groupDefaults boolForKey:@"colorChangingNightEnabled"] && !([groupDefaults boolForKey:@"colorChangingEnabled"] || [groupDefaults boolForKey:@"colorChangingLocationEnabled"])){
        //Could maybe happen at update from version without night mode
        [groupDefaults setBool:NO forKey:@"colorChangingNightEnabled"];
    }
    
    [self updateUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [GammaController autoChangeOrangenessIfNeededWithTransition:YES];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
    [self updateUI];
}

- (void)updateUI {
    self.enabledSwitch.on = [groupDefaults boolForKey:@"enabled"];
    
    self.colorChangingEnabledSwitch.on = [groupDefaults boolForKey:@"colorChangingEnabled"];
    self.colorChangingLocationBasedSwitch.on = [groupDefaults boolForKey:@"colorChangingLocationEnabled"];
    self.colorChangingNightModeSwitch.on = [groupDefaults boolForKey:@"colorChangingNightEnabled"];
    
    self.enabledSwitch.enabled = !(self.colorChangingEnabledSwitch.on || self.colorChangingLocationBasedSwitch.on);
    self.colorChangingNightModeSwitch.enabled = self.colorChangingEnabledSwitch.on || self.colorChangingLocationBasedSwitch.on;
    
    if (self.enabledSwitch.on && !(self.colorChangingEnabledSwitch.on || self.colorChangingLocationBasedSwitch.on)){
        self.timeOfDaySegmentedControl.selectedSegmentIndex = 1;
        self.timeOfDaySegmentedControl.enabled = NO;
    }
    else{
        self.timeOfDaySegmentedControl.enabled = YES;
    }

    self.enabledSwitch.on = [groupDefaults boolForKey:@"enabled"];

    [self.currentOrangeSlider setValue:[groupDefaults floatForKey:@"currentOrange"] animated:YES];

    float orange = 1.0f - self.currentOrangeSlider.value;
    self.currentOrangeSlider.thumbTintColor = [UIColor colorWithRed:0.8f green:((2.0f-orange)/2.0f)*0.8f blue:(1.0f-orange)*0.8f alpha:0.4];
    
    switch (self.timeOfDaySegmentedControl.selectedSegmentIndex) {
        case 0:
            self.orangeSlider.value = [groupDefaults floatForKey:@"dayOrange"];
            break;
        case 1:
            self.orangeSlider.value = [groupDefaults floatForKey:@"maxOrange"];
            break;
        case 2:
            self.orangeSlider.value = [groupDefaults floatForKey:@"nightOrange"];
            break;
    }
    
    orange = 1.0f - self.orangeSlider.value;
    self.orangeSlider.tintColor = [UIColor colorWithRed:0.9f green:((2.0f-orange)/2.0f)*0.9f blue:(1.0f-orange)*0.9f alpha:1.0];
    
    self.enabledSwitch.onTintColor = [UIColor colorWithRed:0.9f green:((2.0f-orange)/2.0f)*0.9f blue:(1.0f-orange)*0.9f alpha:1.0];
    
    NSDate *date = [self dateForHour:[groupDefaults integerForKey:@"autoStartHour"] andMinute:[groupDefaults integerForKey:@"autoStartMinute"]];
    self.startTimeTextField.text = [self.timeFormatter stringFromDate:date];
    date = [self dateForHour:[groupDefaults integerForKey:@"autoEndHour"] andMinute:[groupDefaults integerForKey:@"autoEndMinute"]];
    self.endTimeTextField.text = [self.timeFormatter stringFromDate:date];
    date = [self dateForHour:[groupDefaults integerForKey:@"nightStartHour"] andMinute:[groupDefaults integerForKey:@"nightStartMinute"]];
    self.startTimeNightTextField.text = [self.timeFormatter stringFromDate:date];
    date = [self dateForHour:[groupDefaults integerForKey:@"nightEndHour"] andMinute:[groupDefaults integerForKey:@"nightEndMinute"]];
    self.endTimeNightTextField.text = [self.timeFormatter stringFromDate:date];
    
    [self.startTimeTextField setEnabled:self.colorChangingEnabledSwitch.on];
    [self.endTimeTextField setEnabled:self.colorChangingEnabledSwitch.on];
    
    self.startTimeTextField.textColor = self.colorChangingEnabledSwitch.on ? [UIColor blackColor] : [UIColor grayColor];
    self.endTimeTextField.textColor = self.colorChangingEnabledSwitch.on ? [UIColor blackColor] : [UIColor grayColor];
    
    [self.startTimeNightTextField setEnabled:self.colorChangingNightModeSwitch.on];
    [self.endTimeNightTextField setEnabled:self.colorChangingNightModeSwitch.on];
    
    self.startTimeNightTextField.textColor = self.colorChangingNightModeSwitch.on ? [UIColor blackColor] : [UIColor grayColor];
    self.endTimeNightTextField.textColor = self.colorChangingNightModeSwitch.on ? [UIColor blackColor] : [UIColor grayColor];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}

- (IBAction)enabledSwitchChanged {
    BOOL adjustmentsEnabled = [AppDelegate checkAlertNeededWithViewController:self
                andExecutionBlock:^(UIAlertAction *action) {
                    [groupDefaults setBool:NO forKey:@"dimEnabled"];
                    [groupDefaults setBool:NO forKey:@"rgbEnabled"];
                    [groupDefaults setBool:NO forKey:@"whitePointEnabled"];
                    [groupDefaults setBool:YES forKey:@"enabled"];
                    [GammaController setDarkroomEnabled:NO];
                    [self enabledSwitchChanged];
                }
                forKeys:@"dimEnabled", @"rgbEnabled", @"whitePointEnabled", nil];
    
    if (!adjustmentsEnabled) {
        [groupDefaults setBool:self.enabledSwitch.on forKey:@"enabled"];
        
        if (self.enabledSwitch.on) {
            [GammaController enableOrangenessWithDefaults:NO transition:YES];
        }
        else {
            [GammaController disableOrangeness];
        }
        
        [groupDefaults setBool:NO forKey:@"manualOverride"];
    }
    
    [self updateUI];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        if (indexPath.row == 2) {
            [self.startTimeTextField becomeFirstResponder];
        }
        if (indexPath.row == 3) {
            [self.endTimeTextField becomeFirstResponder];
        }
        if (indexPath.row == 5) {
            [self.startTimeNightTextField becomeFirstResponder];
        }
        if (indexPath.row == 6) {
            [self.endTimeNightTextField becomeFirstResponder];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)toolbarDoneButtonClicked:(UIBarButtonItem *)button {
    [self.startTimeTextField resignFirstResponder];
    [self.endTimeTextField resignFirstResponder];
    [self.startTimeNightTextField resignFirstResponder];
    [self.endTimeNightTextField resignFirstResponder];
    
    [AppDelegate updateNotifications];
}

- (void)timePickerValueChanged:(UIDatePicker *)picker {
    UITextField *currentField = nil;
    NSString *defaultsKeyPrefix = nil;
    if ([self.startTimeTextField isFirstResponder]) {
        currentField = self.startTimeTextField;
        defaultsKeyPrefix = @"autoStart";
    }
    else if ([self.endTimeTextField isFirstResponder]) {
        currentField = self.endTimeTextField;
        defaultsKeyPrefix = @"autoEnd";
    }
    else if ([self.startTimeNightTextField isFirstResponder]) {
        currentField = self.startTimeNightTextField;
        defaultsKeyPrefix = @"nightStart";
    }
    else if ([self.endTimeNightTextField isFirstResponder]) {
        currentField = self.endTimeNightTextField;
        defaultsKeyPrefix = @"nightEnd";
    }
    else {
        return;
    }
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:picker.date];
    currentField.text = [self.timeFormatter stringFromDate:picker.date];
    
    [groupDefaults setInteger:components.hour forKey:[defaultsKeyPrefix stringByAppendingString:@"Hour"]];
    [groupDefaults setInteger:components.minute forKey:[defaultsKeyPrefix stringByAppendingString:@"Minute"]];
    
    [groupDefaults setObject:[NSDate distantPast] forKey:@"lastAutoChangeDate"];
    [GammaController autoChangeOrangenessIfNeededWithTransition:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSDate *date = nil;
    
    if (textField == self.startTimeTextField) {
        date = [self dateForHour:[groupDefaults integerForKey:@"autoStartHour"] andMinute:[groupDefaults integerForKey:@"autoStartMinute"]];
    }
    else if (textField == self.endTimeTextField) {
        date = [self dateForHour:[groupDefaults integerForKey:@"autoEndHour"] andMinute:[groupDefaults integerForKey:@"autoEndMinute"]];
    }
    else if (textField == self.startTimeNightTextField) {
        date = [self dateForHour:[groupDefaults integerForKey:@"nightStartHour"] andMinute:[groupDefaults integerForKey:@"nightStartMinute"]];
    }
    else if (textField == self.endTimeNightTextField) {
        date = [self dateForHour:[groupDefaults integerForKey:@"nightEndHour"] andMinute:[groupDefaults integerForKey:@"nightEndMinute"]];
    }
    else {
        return;
    }
    [(UIDatePicker *)textField.inputView setDate:date animated:NO];
}

- (NSDate *)dateForHour:(NSInteger)hour andMinute:(NSInteger)minute{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.hour = hour;
    comps.minute = minute;
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

- (void)userDefaultsChanged:(NSNotification *)notification {
    [self updateUI];
}


- (IBAction)timeOfDaySegmentedControlChanged {
    [self updateUI];
}

- (IBAction)maxOrangeSliderChanged {
    // Round the slider's value to a nice temperature increment
    self.orangeSlider.value = roundOrangeValue(self.orangeSlider.value);

    NSString *key;
    switch (self.timeOfDaySegmentedControl.selectedSegmentIndex) {
        case 0:
            key = @"dayOrange";
            break;
        case 1:
            key = @"maxOrange";
            break;
        case 2:
            key = @"nightOrange";
            break;
    }
    [groupDefaults setFloat:self.orangeSlider.value forKey:key];

    [GammaController enableOrangenessWithDefaults:NO transition:NO orangeLevel:self.orangeSlider.value];
}

- (IBAction)maxOrangeSliderChangingEnded {
    if (self.colorChangingEnabledSwitch.on || self.colorChangingLocationBasedSwitch.on){
        [groupDefaults setObject:[NSDate distantPast] forKey:@"lastAutoChangeDate"];
        [GammaController autoChangeOrangenessIfNeededWithTransition:NO];
    }
    else if (self.enabledSwitch.on) {
        [GammaController enableOrangenessWithDefaults:NO transition:NO];
    }
    else {
        [GammaController disableOrangeness];
    }
    
    [groupDefaults synchronize];
}

- (IBAction)colorChangingEnabledSwitchChanged:(UISwitch *)sender {
    self.enabledSwitch.enabled = !self.colorChangingEnabledSwitch.on;
    [groupDefaults setBool:self.colorChangingEnabledSwitch.on forKey:@"colorChangingEnabled"];
    [groupDefaults setObject:[NSDate distantPast] forKey:@"lastAutoChangeDate"];
    
    if(self.colorChangingEnabledSwitch.on) {
        // Only one auto temperature change can be activated
        if (self.colorChangingLocationBasedSwitch.on) {
            [self.colorChangingLocationBasedSwitch setOn:NO animated:YES];
        }
        [groupDefaults setBool:NO forKey:@"colorChangingLocationEnabled"];
        
        self.colorChangingNightModeSwitch.enabled = YES;
    }
    else{
        [self.colorChangingNightModeSwitch setOn:NO animated:YES];
        self.colorChangingNightModeSwitch.enabled = NO;

        [groupDefaults setBool:NO forKey:@"colorChangingNightEnabled"];
        
        [self.enabledSwitch setOn:NO animated:YES];
        [groupDefaults setBool:NO forKey:@"enabled"];
        [GammaController disableOrangeness];
    }
    
    [groupDefaults setBool:NO forKey:@"manualOverride"];
    
    [AppDelegate updateNotifications];
    
    [GammaController autoChangeOrangenessIfNeededWithTransition:YES];
    
}

- (IBAction)colorChangingLocationSwitchValueChanged:(UISwitch *)sender{
    
    if (!sender && !self.colorChangingLocationBasedSwitch.on){
        return;
    }

    if(self.colorChangingLocationBasedSwitch.on) {
        // Only one auto temperature change can be activated
        
        BOOL requestedLocationAuthorization = NO;
        
        if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
                [self.locationManager requestWhenInUseAuthorization];
                // Let the location manager delegate take it from here.
                return;
            }
        }
        
        // Only one auto temperature change can be activated
        if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
            // Search for location
            [self.locationManager startUpdatingLocation];
            
            // Update the user location everytime this is switched on
            // This is only here, instead of in every background refresh, in order to prolong battery life.
            CGFloat latitude = self.locationManager.location.coordinate.latitude;
            CGFloat longitude = self.locationManager.location.coordinate.longitude;
            if (latitude != 0 && longitude != 0) { // make sure the location is available
                [groupDefaults setFloat:latitude forKey:@"colorChangingLocationLatitude"];
                [groupDefaults setFloat:longitude forKey:@"colorChangingLocationLongitude"];
            }
            
            [self.colorChangingEnabledSwitch setOn:NO animated:YES];
            
            [groupDefaults setBool:YES forKey:@"colorChangingLocationEnabled"];
            if (self.colorChangingEnabledSwitch.on) {
                [self.colorChangingEnabledSwitch setOn:NO animated:YES];
            }
            [groupDefaults setBool:NO forKey:@"colorChangingEnabled"];
            
            self.colorChangingNightModeSwitch.enabled = YES;
            self.enabledSwitch.enabled = !self.colorChangingLocationBasedSwitch.on;
            [groupDefaults setObject:[NSDate distantPast] forKey:@"lastAutoChangeDate"];
            
        } else if(!requestedLocationAuthorization) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No access to location", @"")
                                                            message:NSLocalizedString(@"You must enable location services in settings.", @"")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                  otherButtonTitles:nil];
            [alert show];
            [self.colorChangingLocationBasedSwitch setOn:NO animated:YES];
        }
        [GammaController autoChangeOrangenessIfNeededWithTransition:YES];
    } else {
        [groupDefaults setBool:NO forKey:@"colorChangingLocationEnabled"];
        self.enabledSwitch.enabled = !self.colorChangingLocationBasedSwitch.on;
        
        [self.colorChangingNightModeSwitch setOn:NO animated:YES];
        self.colorChangingNightModeSwitch.enabled = NO;

        [groupDefaults setBool:NO forKey:@"colorChangingNightEnabled"];
        
        [self.enabledSwitch setOn:NO animated:YES];
        [groupDefaults setBool:NO forKey:@"enabled"];
        [GammaController disableOrangeness];
    }
    
    [groupDefaults setBool:NO forKey:@"manualOverride"];
    
    [groupDefaults synchronize];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusDenied) {
        [self.colorChangingLocationBasedSwitch setOn:NO animated:YES];
        [groupDefaults setBool:NO forKey:@"colorChangingLocationEnabled"];
        [groupDefaults synchronize];
    } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        // revaluate the UISwitch status
        [self colorChangingLocationSwitchValueChanged:nil];
    }
}

- (IBAction)nightModeEnabledSwitchChanged:(UISwitch *)sender {
    [groupDefaults setBool:self.colorChangingNightModeSwitch.on forKey:@"colorChangingNightEnabled"];
    [groupDefaults setObject:[NSDate distantPast] forKey:@"lastAutoChangeDate"];
   
    [AppDelegate updateNotifications];
    
    [GammaController autoChangeOrangenessIfNeededWithTransition:YES];
}

- (IBAction)resetSlider {
    [groupDefaults setFloat:0.3111111111f forKey:@"maxOrange"];
    [groupDefaults setFloat:1.0f forKey:@"dayOrange"];
    [groupDefaults setFloat:0.0f forKey:@"nightOrange"];
    
    switch (self.timeOfDaySegmentedControl.selectedSegmentIndex) {
        case 0:
            self.orangeSlider.value = [groupDefaults floatForKey:@"dayOrange"];
            break;
        case 1:
            self.orangeSlider.value = [groupDefaults floatForKey:@"maxOrange"];
            break;
        case 2:
            self.orangeSlider.value = [groupDefaults floatForKey:@"nightOrange"];
            break;
    }

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.colorChangingEnabledSwitch.on || self.colorChangingLocationBasedSwitch.on){
        [GammaController autoChangeOrangenessIfNeededWithTransition:YES];
    }
    else if (self.enabledSwitch.on) {
        [GammaController setGammaWithTransitionFrom:[groupDefaults floatForKey:@"currentOrange"] to:self.orangeSlider.value];
        [groupDefaults setFloat:self.orangeSlider.value forKey:@"currentOrange"];
    }
}

- (NSArray <id <UIPreviewActionItem>> *)previewActionItems {
    NSString *title = nil;
    
    if (![groupDefaults boolForKey:@"enabled"]) {
        title = NSLocalizedString(@"Enable", @"");
    }
    else if ([groupDefaults boolForKey:@"enabled"]) {
        title = NSLocalizedString(@"Disable", @"");
    }
    
    UIPreviewAction *enableDisableAction = [UIPreviewAction actionWithTitle:title style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self enableOrDisableBasedOnDefaults];
    }];
    UIPreviewAction *cancelButton = [UIPreviewAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {}];
    
    return @[enableDisableAction, cancelButton];
}

- (void)enableOrDisableBasedOnDefaults {
    if (![groupDefaults boolForKey:@"enabled"]) {
        [GammaController enableOrangenessWithDefaults:YES transition:YES];
    }
    else if ([groupDefaults boolForKey:@"enabled"]) {
        [GammaController disableOrangeness];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerText = @"";
    if (tableView) {
        if (section == 1) {
            headerText = [NSString stringWithFormat:NSLocalizedString(@"Temperature (%dK)", @""), (int)((self.orangeSlider.value * 45 + 20) * 10) * 10];
        }
        if (section == 2) {
            headerText = NSLocalizedString(@"Automatic Mode", @"");
        }
    }
    return headerText;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *footerText = @"";
    if (tableView) {
        if (section == 1) {
            footerText = [NSString stringWithFormat:NSLocalizedString(@"Move the slider to adjust the display temperature.\n\nCurrent Temperature: %dK", @""), (int)(([groupDefaults floatForKey:@"currentOrange"] * 45 + 20) * 10)*10];
        }
        if (section == 2) {
            NSDate *lastBackgroundUpdate = [groupDefaults objectForKey:@"lastBackgroundCheck"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"HH:mm dd MMM yyyy"];
            footerText = [NSString stringWithFormat:NSLocalizedString(@"Enable automatic mode to turn on and off GoodNight at a set time. Please note that the change will not take effect immediately.\n\nLast Background Update: %@", @""), [lastBackgroundUpdate isEqualToDate:[NSDate distantPast]] ? NSLocalizedString(@"Never", @"") :  [dateFormatter stringFromDate:lastBackgroundUpdate]];
        }
    }
    return footerText;
}

@end
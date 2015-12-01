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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
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
    
    
    if ([userDefaults boolForKey:@"colorChangingNightEnabled"] && !([userDefaults boolForKey:@"colorChangingEnabled"] || [userDefaults boolForKey:@"colorChangingLocationEnabled"])){
        //Could maybe happen at update from version without night mode
        [userDefaults setBool:NO forKey:@"colorChangingNightEnabled"];
    }
    
    [self updateUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [GammaController autoChangeOrangenessIfNeededWithTransition:YES];
    //Update the header for current temperature
    //Update the footer for last updated background mode if user keeps app open at this level
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
    [self.currentOrangeSlider setValue:[userDefaults floatForKey:@"currentOrange"] animated:YES];
}

- (void)updateUI {
    self.enabledSwitch.on = [userDefaults boolForKey:@"enabled"];
    self.orangeSlider.value = [userDefaults floatForKey:@"maxOrange"];
    
    [self.currentOrangeSlider setValue:[userDefaults floatForKey:@"currentOrange"] animated:YES];

    self.colorChangingEnabledSwitch.on = [userDefaults boolForKey:@"colorChangingEnabled"];
    self.colorChangingLocationBasedSwitch.on = [userDefaults boolForKey:@"colorChangingLocationEnabled"];
    self.colorChangingNightModeSwitch.on = [userDefaults boolForKey:@"colorChangingNightEnabled"];
    
    self.colorChangingNightModeSwitch.enabled = self.colorChangingEnabledSwitch.on || self.colorChangingLocationBasedSwitch.on;
    
    float orange = 1.0f - self.currentOrangeSlider.value;
    
    self.currentOrangeSlider.thumbTintColor = [UIColor colorWithRed:0.8f green:((2.0f-orange)/2.0f)*0.8f blue:(1.0f-orange)*0.8f alpha:0.4];
    
    
    orange = 1.0f - self.orangeSlider.value;
    
    self.orangeSlider.tintColor = [UIColor colorWithRed:0.9f green:((2.0f-orange)/2.0f)*0.9f blue:(1.0f-orange)*0.9f alpha:1.0];
    
    self.enabledSwitch.onTintColor = [UIColor colorWithRed:0.9f green:((2.0f-orange)/2.0f)*0.9f blue:(1.0f-orange)*0.9f alpha:1.0];
    self.colorChangingEnabledSwitch.onTintColor = [UIColor colorWithRed:0.9f green:((2.0f-orange)/2.0f)*0.9f blue:(1.0f-orange)*0.9f alpha:1.0];
    self.colorChangingLocationBasedSwitch.onTintColor = [UIColor colorWithRed:0.9f green:((2.0f-orange)/2.0f)*0.9f blue:(1.0f-orange)*0.9f alpha:1.0];
    self.colorChangingNightModeSwitch.onTintColor = [UIColor colorWithRed:0.8f green:0.495f blue:0.09f alpha:1.0];
    
    NSDate *date = [self dateForHour:[userDefaults integerForKey:@"autoStartHour"] andMinute:[userDefaults integerForKey:@"autoStartMinute"]];
    self.startTimeTextField.text = [self.timeFormatter stringFromDate:date];
    date = [self dateForHour:[userDefaults integerForKey:@"autoEndHour"] andMinute:[userDefaults integerForKey:@"autoEndMinute"]];
    self.endTimeTextField.text = [self.timeFormatter stringFromDate:date];
    date = [self dateForHour:[userDefaults integerForKey:@"nightStartHour"] andMinute:[userDefaults integerForKey:@"nightStartMinute"]];
    self.startTimeNightTextField.text = [self.timeFormatter stringFromDate:date];
    date = [self dateForHour:[userDefaults integerForKey:@"nightEndHour"] andMinute:[userDefaults integerForKey:@"nightEndMinute"]];
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
    [userDefaults setBool:self.enabledSwitch.on forKey:@"enabled"];
    
    if (self.enabledSwitch.on) {
        [GammaController enableOrangenessWithDefaults:NO transition:YES];
    }
    else {
        [GammaController disableOrangeness];
    }
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
    
    [userDefaults setInteger:components.hour forKey:[defaultsKeyPrefix stringByAppendingString:@"Hour"]];
    [userDefaults setInteger:components.minute forKey:[defaultsKeyPrefix stringByAppendingString:@"Minute"]];
    
    [userDefaults setObject:[NSDate distantPast] forKey:@"lastAutoChangeDate"];
    [GammaController autoChangeOrangenessIfNeededWithTransition:NO];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSDate *date = nil;
    
    if (textField == self.startTimeTextField) {
        date = [self dateForHour:[userDefaults integerForKey:@"autoStartHour"] andMinute:[userDefaults integerForKey:@"autoStartMinute"]];
    }
    else if (textField == self.endTimeTextField) {
        date = [self dateForHour:[userDefaults integerForKey:@"autoEndHour"] andMinute:[userDefaults integerForKey:@"autoEndMinute"]];
    }
    else if (textField == self.startTimeNightTextField) {
        date = [self dateForHour:[userDefaults integerForKey:@"nightStartHour"] andMinute:[userDefaults integerForKey:@"nightStartMinute"]];
    }
    else if (textField == self.endTimeNightTextField) {
        date = [self dateForHour:[userDefaults integerForKey:@"nightEndHour"] andMinute:[userDefaults integerForKey:@"nightEndMinute"]];
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

- (IBAction)maxOrangeSliderChanged {
    [userDefaults setFloat:self.orangeSlider.value forKey:@"maxOrange"];
    //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.enabledSwitch.on) {
        [GammaController enableOrangenessWithDefaults:NO transition:NO];
    }
}

- (IBAction)colorChangingEnabledSwitchChanged {
    self.enabledSwitch.enabled = !self.colorChangingEnabledSwitch.on;
    [userDefaults setBool:self.colorChangingEnabledSwitch.on forKey:@"colorChangingEnabled"];
    [userDefaults setObject:[NSDate distantPast] forKey:@"lastAutoChangeDate"];
    
    if(self.colorChangingEnabledSwitch.on) {
        // Only one auto temperature change can be activated
        if (self.colorChangingLocationBasedSwitch.on) {
            [self.colorChangingLocationBasedSwitch setOn:NO animated:YES];
        }
        [userDefaults setBool:NO forKey:@"colorChangingLocationEnabled"];
        
        self.colorChangingNightModeSwitch.enabled = YES;
    }
    else{
        [self.colorChangingNightModeSwitch setOn:NO animated:YES];
        self.colorChangingNightModeSwitch.enabled = NO;
        [userDefaults setBool:NO forKey:@"colorChangingNightEnabled"];
    }
    
    [AppDelegate updateNotifications];
    
    [GammaController autoChangeOrangenessIfNeededWithTransition:YES];
    
}

- (IBAction)colorChangingLocationSwitchValueChanged{
    
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
                [userDefaults setFloat:latitude forKey:@"colorChangingLocationLatitude"];
                [userDefaults setFloat:longitude forKey:@"colorChangingLocationLongitude"];
            }
            
            [self.colorChangingEnabledSwitch setOn:NO animated:YES];
            
            [userDefaults setBool:YES forKey:@"colorChangingLocationEnabled"];
            if (self.colorChangingEnabledSwitch.on) {
                [self.colorChangingEnabledSwitch setOn:NO animated:YES];
            }
            [userDefaults setBool:NO forKey:@"colorChangingEnabled"];
            
            self.colorChangingNightModeSwitch.enabled = YES;
            self.enabledSwitch.enabled = !self.colorChangingLocationBasedSwitch.on;
            [userDefaults setObject:[NSDate distantPast] forKey:@"lastAutoChangeDate"];
            
        } else if(!requestedLocationAuthorization) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No access to location"
                                                            message:@"You must enable location services in settings."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [self.colorChangingLocationBasedSwitch setOn:NO animated:YES];
        }
        [GammaController autoChangeOrangenessIfNeededWithTransition:YES];
    } else {
        [userDefaults setBool:NO forKey:@"colorChangingLocationEnabled"];
        self.enabledSwitch.enabled = !self.colorChangingLocationBasedSwitch.on;
        
        [self.colorChangingNightModeSwitch setOn:NO animated:YES];
        self.colorChangingNightModeSwitch.enabled = NO;
        [userDefaults setBool:NO forKey:@"colorChangingNightEnabled"];
    }
    
    [userDefaults synchronize];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusDenied) {
        [self.colorChangingLocationBasedSwitch setOn:NO animated:YES];
        [userDefaults setBool:NO forKey:@"colorChangingLocationEnabled"];
        [userDefaults synchronize];
    } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        // revaluate the UISwitch status
        [self colorChangingLocationSwitchValueChanged];
    }
}

- (IBAction)nightModeEnabledSwitchChanged {
    [userDefaults setBool:self.colorChangingNightModeSwitch.on forKey:@"colorChangingNightEnabled"];
    [userDefaults setObject:[NSDate distantPast] forKey:@"lastAutoChangeDate"];
    
    [AppDelegate updateNotifications];
    
    [GammaController autoChangeOrangenessIfNeededWithTransition:YES];
}

- (IBAction)resetSlider {
    self.orangeSlider.value = 0.3111111111;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.enabledSwitch.on) {
        [GammaController setGammaWithTransitionFrom:[userDefaults floatForKey:@"maxOrange"] to:self.orangeSlider.value];
    }
    
    [userDefaults setFloat:self.orangeSlider.value forKey:@"maxOrange"];
}

- (NSArray <id <UIPreviewActionItem>> *)previewActionItems {
    NSString *title = nil;
    
    if (![userDefaults boolForKey:@"enabled"]) {
        title = @"Enable";
    }
    else if ([userDefaults boolForKey:@"enabled"]) {
        title = @"Disable";
    }
    
    UIPreviewAction *enableDisableAction = [UIPreviewAction actionWithTitle:title style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self enableOrDisableBasedOnDefaults];
    }];
    UIPreviewAction *cancelButton = [UIPreviewAction actionWithTitle:@"Cancel" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {}];
    
    return @[enableDisableAction, cancelButton];
}

- (void)enableOrDisableBasedOnDefaults {
    if (![userDefaults boolForKey:@"enabled"]) {
        [GammaController enableOrangenessWithDefaults:YES transition:YES];
    }
    else if ([userDefaults boolForKey:@"enabled"]) {
        [GammaController disableOrangeness];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerText = @"";
    if (tableView) {
        if (section == 1) {
            headerText = [NSString stringWithFormat:@"Temperature (%dK) (current: %dK)", (int)((self.orangeSlider.value * 45 + 20) * 10) * 10, (int)(([userDefaults floatForKey:@"currentOrange"] * 45 + 20) * 10)*10];
        }
        if (section == 2) {
            headerText = @"Automatic Mode";
        }
    }
    return headerText;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *footerText = @"";
    if (tableView) {
        if (section == 1) {
            footerText = @"Move the slider to adjust the display temperature.";
        }
        if (section == 2) {
            NSDate *lastBackgroundUpdate = [userDefaults objectForKey:@"lastBackgroundCheck"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"HH:mm dd MMM yyyy"];
            footerText = [NSString stringWithFormat:@"Enable automatic mode to turn on and off GoodNight at a set time. Please note that the change will not take effect immediately.\n\nLast Background Update: %@", [lastBackgroundUpdate isEqualToDate:[NSDate distantPast]] ? @"Never" :  [dateFormatter stringFromDate:lastBackgroundUpdate]];
        }
    }
    return footerText;
}

@end
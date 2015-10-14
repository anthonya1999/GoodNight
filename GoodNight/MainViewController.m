//
//  ViewController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 6/22/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "MainViewController.h"
#import "GammaController.h"

@implementation MainViewController

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
    
    self.timePickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toolbarDoneButtonClicked:)];
    [self.timePickerToolbar setItems:@[doneButton]];
    
    self.endTimeTextField.inputAccessoryView = self.timePickerToolbar;
    self.startTimeTextField.inputAccessoryView = self.timePickerToolbar;
    
    self.endTimeTextField.delegate = self;
    self.startTimeTextField.delegate = self;

    [self updateUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)updateUI {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.enabledSwitch.on = [defaults boolForKey:@"enabled"];
    self.orangeSlider.value = [defaults floatForKey:@"maxOrange"];
    self.colorChangingEnabledSwitch.on = [defaults boolForKey:@"colorChangingEnabled"];
    
    NSDate *date = [self dateForHour:[defaults integerForKey:@"autoStartHour"] andMinute:[defaults integerForKey:@"autoStartMinute"]];
    self.startTimeTextField.text = [self.timeFormatter stringFromDate:date];
    date = [self dateForHour:[defaults integerForKey:@"autoEndHour"] andMinute:[defaults integerForKey:@"autoEndMinute"]];
    self.endTimeTextField.text = [self.timeFormatter stringFromDate:date];}

- (IBAction)enabledSwitchChanged {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"rgbEnabled"] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"dimEnabled"]) {
        [[NSUserDefaults standardUserDefaults] setBool:self.enabledSwitch.on forKey:@"enabled"];
        
        if (self.enabledSwitch.on) {
            [GammaController setGammaWithOrangeness:[[NSUserDefaults standardUserDefaults] floatForKey:@"maxOrange"]];
        }
        else {
            [GammaController setGammaWithOrangeness:0];
        }
    }
    else {
        [self.enabledSwitch setOn:NO animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You may only use one adjustment at a time. Please disable any other adjustments before enabling this one." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        if (indexPath.row == 1) {
            [self.startTimeTextField becomeFirstResponder];
        }
        if (indexPath.row == 2) {
            [self.endTimeTextField becomeFirstResponder];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)toolbarDoneButtonClicked:(UIBarButtonItem *)button {
    [self.startTimeTextField resignFirstResponder];
    [self.endTimeTextField resignFirstResponder];
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
    else {
        return;
    }
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:picker.date];
    currentField.text = [self.timeFormatter stringFromDate:picker.date];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:components.hour forKey:[defaultsKeyPrefix stringByAppendingString:@"Hour"]];
    [defaults setInteger:components.minute forKey:[defaultsKeyPrefix stringByAppendingString:@"Minute"]];
    
    [defaults setObject:[NSDate distantPast] forKey:@"lastAutoChangeDate"];
    [GammaController autoChangeOrangenessIfNeeded];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *date = nil;
    
    if (textField == self.startTimeTextField) {
        date = [self dateForHour:[defaults integerForKey:@"autoStartHour"] andMinute:[defaults integerForKey:@"autoStartMinute"]];
    }
    else if (textField == self.endTimeTextField) {
        date = [self dateForHour:[defaults integerForKey:@"autoEndHour"] andMinute:[defaults integerForKey:@"autoEndMinute"]];
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
    [[NSUserDefaults standardUserDefaults] setFloat:self.orangeSlider.value forKey:@"maxOrange"];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.enabledSwitch.on) {
        [GammaController setGammaWithOrangeness:self.orangeSlider.value];
    }
}

- (IBAction)colorChangingEnabledSwitchChanged {
    [[NSUserDefaults standardUserDefaults] setBool:self.colorChangingEnabledSwitch.on forKey:@"colorChangingEnabled"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate distantPast] forKey:@"lastAutoChangeDate"];
    [GammaController autoChangeOrangenessIfNeeded];
}

- (IBAction)resetSlider {
    self.orangeSlider.value = 0.4;
    [[NSUserDefaults standardUserDefaults] setFloat:self.orangeSlider.value forKey:@"maxOrange"];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.enabledSwitch.on) {
        [GammaController setGammaWithOrangeness:self.orangeSlider.value];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerText = @"";
    if (tableView) {
        if (section == 1) {
            headerText = [NSString stringWithFormat:@"Temperature (%.2f)", (self.orangeSlider.value * 10)];
        }
        if (section == 2) {
            headerText = @"Automatic Mode";
        }
    }
    return headerText;
}

@end
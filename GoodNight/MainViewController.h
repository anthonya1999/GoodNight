//
//  ViewController.h
//  GoodNight
//
//  Created by Anthony Agatiello on 6/22/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MainViewController : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate>

@property NSDateFormatter *timeFormatter;
@property UIDatePicker *timePicker;
@property UIToolbar *timePickerToolbar;

@property (weak, nonatomic) IBOutlet UISwitch *enabledSwitch;
@property (weak, nonatomic) IBOutlet UISlider *orangeSlider, *currentOrangeSlider;
@property (weak, nonatomic) IBOutlet UISwitch *colorChangingEnabledSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *colorChangingLocationBasedSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *colorChangingNightModeSwitch;
@property (weak, nonatomic) IBOutlet UITextField *startTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *endTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *startTimeNightTextField;
@property (weak, nonatomic) IBOutlet UITextField *endTimeNightTextField;

@property CLLocationManager * locationManager;

@end
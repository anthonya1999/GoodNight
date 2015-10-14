//
//  ViewController.h
//  GoodNight
//
//  Created by Anthony Agatiello on 6/22/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate>

@property NSDateFormatter *timeFormatter;
@property UIDatePicker *timePicker;
@property UIToolbar *timePickerToolbar;

@property (weak, nonatomic) IBOutlet UISwitch *enabledSwitch;
@property (weak, nonatomic) IBOutlet UISlider *orangeSlider;
@property (weak, nonatomic) IBOutlet UISwitch *colorChangingEnabledSwitch;
@property (weak, nonatomic) IBOutlet UITextField *startTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *endTimeTextField;

@end
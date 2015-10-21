//
//  SettingsViewController.h
//  GoodNight
//
//  Created by Anthony Agatiello on 10/16/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

@interface SettingsViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISwitch *suspendSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *forceTouchSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *temperatureForceTouch;
@property (weak, nonatomic) IBOutlet UISwitch *dimForceTouch;
@property (weak, nonatomic) IBOutlet UISwitch *rgbForceTouch;

@end
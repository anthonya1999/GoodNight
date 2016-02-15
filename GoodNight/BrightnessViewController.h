//
//  BrightnessViewController.h
//  GoodNight
//
//  Created by Anthony Agatiello on 10/4/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static BOOL warningIgnored;

@interface BrightnessViewController : UITableViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *dimSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *darkroomSwitch;
@property (weak, nonatomic) IBOutlet UISlider *dimSlider;

@end
//
//  WhitePointViewController.h
//  GoodNight
//
//  Created by Anthony Agatiello on 12/18/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WhitePointViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISlider *whitePointSlider;
@property (weak, nonatomic) IBOutlet UISwitch *whitePointSwitch;

@end
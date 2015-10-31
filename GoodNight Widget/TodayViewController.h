//
//  TodayViewController.h
//  GoodNight Widget
//
//  Created by Anthony Agatiello on 10/29/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController : UIViewController <NCWidgetProviding>

@property (weak, nonatomic) IBOutlet UIButton *enableButton;
@property (weak, nonatomic) IBOutlet UIButton *disableButton;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;

@end
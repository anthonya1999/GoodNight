//
//  ShadeViewController.h
//  GoodNight
//
//  Created by Anthony Agatiello on 11/25/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ShadeViewController : NSViewController

@property (strong, nonatomic) IBOutlet NSSlider *brightnessSlider;
@property (strong, nonatomic) IBOutlet NSTextField *percentTextField;

+ (void)showBrightnessAlert;

@end

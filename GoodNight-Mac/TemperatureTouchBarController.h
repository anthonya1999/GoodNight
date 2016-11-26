//
//  TouchBarController.h
//  GoodNight
//
//  Created by Anthony Agatiello on 11/24/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TemperatureTouchBarController : NSTouchBar

@property (strong, nonatomic) IBOutlet NSSliderTouchBarItem *touchBarTemperatureSlider;
@property (strong, nonatomic) IBOutlet NSButton *touchBarResetButton;
@property (strong, nonatomic) IBOutlet NSButton *touchBarDarkroomButton;

+ (instancetype)sharedInstance;

@end

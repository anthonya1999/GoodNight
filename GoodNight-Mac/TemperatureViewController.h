//
//  ViewController.h
//  GoodNight-Mac
//
//  Created by Anthony Agatiello on 11/17/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TemperatureViewController : NSViewController

@property (weak, nonatomic) IBOutlet NSSlider *temperatureSlider;
@property (weak, nonatomic) IBOutlet NSTextField *temperatureLabel;
@property (weak, nonatomic) IBOutlet NSButton *darkroomButton;

+ (void)setGammaWithRed:(float)r green:(float)g blue:(float)b;

@end

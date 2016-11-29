//
//  ViewController.h
//  GoodNight-Mac
//
//  Created by Anthony Agatiello on 11/17/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TemperatureViewController : NSViewController

@property (strong, nonatomic) IBOutlet NSSlider *temperatureSlider;
@property (strong, nonatomic) IBOutlet NSTextField *temperatureLabel;
@property (strong, nonatomic) IBOutlet NSButton *darkroomButton;

+ (void)setGammaWithRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b;
+ (void)setGammaWithOrangeness:(float)percentOrange;
+ (void)setInvertedColorsEnabled:(BOOL)enabled;

@end

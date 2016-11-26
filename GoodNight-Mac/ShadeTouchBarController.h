//
//  ShadeTouchBarController.h
//  GoodNight
//
//  Created by Anthony Agatiello on 11/25/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ShadeTouchBarController : NSTouchBar

@property (strong, nonatomic) IBOutlet NSSliderTouchBarItem *bightnessTouchBarSlider;

+ (instancetype)sharedInstance;

@end

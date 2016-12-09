//
//  WhitePointMacViewController.h
//  GoodNight
//
//  Created by Anthony Agatiello on 12/9/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WhitePointMacViewController : NSViewController

@property (strong, nonatomic) IBOutlet NSSlider *whitePointSlider;
@property (strong, nonatomic) IBOutlet NSTextField *whitePointLabel;

@end

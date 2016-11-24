//
//  ColorViewController.m
//  GoodNight-Mac
//
//  Created by Anthony Agatiello on 11/23/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import "ColorViewController.h"

@implementation ColorViewController

- (IBAction)setColor:(NSButton *)button {
    float redValue = self.redField.floatValue;
    float greenValue = self.greenField.floatValue;
    float blueValue = self.blueField.floatValue;
    
    CGGammaValue redTable[] = {0, redValue};
    CGGammaValue greenTable[] = {0, greenValue};
    CGGammaValue blueTable[] = {0, blueValue};
    
    CGSetDisplayTransferByTable(CGMainDisplayID(), 2, (const float *)&redTable, (const float *)&greenTable, (const float *)&blueTable);
}

- (IBAction)resetColor:(NSButton *)button {
    CGDisplayRestoreColorSyncSettings();
}

@end

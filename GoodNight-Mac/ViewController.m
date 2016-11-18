//
//  ViewController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 11/17/16.
//  Copyright © 2016 Anthony Agatiello. All rights reserved.
//

#import "ViewController.h"
#import <ApplicationServices/ApplicationServices.h>

@implementation ViewController

- (IBAction)setGamma:(NSButton *)sender {
    float redValue = self.redField.floatValue;
    float greenValue = self.greenField.floatValue;
    float blueValue = self.blueField.floatValue;
    
    CGGammaValue redTable[] = {0, redValue};
    CGGammaValue greenTable[] = {0, greenValue};
    CGGammaValue blueTable[] = {0, blueValue};
    
    CGSetDisplayTransferByTable(CGMainDisplayID(), 2, (const float *)&redTable, (const float *)&greenTable, (const float *)&blueTable);
}

- (IBAction)resetGamma:(NSButton *)sender {
    CGDisplayRestoreColorSyncSettings();
}

@end

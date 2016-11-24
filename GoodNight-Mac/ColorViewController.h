//
//  ColorViewController.h
//  GoodNight-Mac
//
//  Created by Anthony Agatiello on 11/23/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ColorViewController : NSViewController

@property (weak, nonatomic) IBOutlet NSTextField *redField;
@property (weak, nonatomic) IBOutlet NSTextField *greenField;
@property (weak, nonatomic) IBOutlet NSTextField *blueField;

@end

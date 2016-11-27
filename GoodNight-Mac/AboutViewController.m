//
//  AboutViewController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 11/26/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import "AboutViewController.h"
#import <Sparkle/Sparkle.h>

@implementation AboutViewController

- (void)viewWillAppear {
    [super viewWillAppear];
    
    self.view.window.titleVisibility = NSWindowTitleHidden;
    self.view.window.titlebarAppearsTransparent = YES;
    self.view.window.styleMask |= NSWindowStyleMaskFullSizeContentView;
}

- (IBAction)updateButtonClicked:(NSButton *)button {
    [[[SUUpdater alloc] init] checkForUpdates:nil];
}

@end

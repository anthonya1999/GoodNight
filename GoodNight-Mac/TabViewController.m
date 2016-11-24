//
//  TabViewController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 11/23/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import "TabViewController.h"

@implementation TabViewController

- (void)viewWillAppear {
    [super viewWillAppear];
    
    self.view.window.titleVisibility = NSWindowTitleHidden;
    self.view.window.titlebarAppearsTransparent = YES;
    self.view.window.styleMask |= NSWindowStyleMaskFullSizeContentView;
    
    if (![userDefaults valueForKey:@"alertShowed"]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Helpful tip!"];
        [alert setInformativeText:@"You must keep GoodNight running in the background to keep the settings you set. However, you can go to File → Close or press ⌘W to close the window and keep the app running."];
        [alert addButtonWithTitle:@"OK"];
        [alert addButtonWithTitle:@"Don't Show Again"];
        
        if ([alert runModal] == NSAlertSecondButtonReturn) {
            [userDefaults setValue:[NSDate date] forKey:@"alertShowed"];
        }
    }
}

@end

//
//  ForceTouchController.h
//  GoodNight
//
//  Created by Anthony Agatiello on 10/20/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static BOOL forceTouchActionEnabled = NO;

@interface ForceTouchController : NSObject

+ (id)sharedForceTouchController;
+ (UIApplicationShortcutItem *)shortcutItemForCurrentState;
+ (void)updateShortcutItems;
+ (BOOL)handleShortcutItem:(UIApplicationShortcutItem *)shortcutItem;
+ (void)exitIfKeyEnabled;

@end
//
//  AppDelegate.h
//  GoodNight
//
//  Created by Anthony Agatiello on 6/22/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

+ (void)updateNotifications;
+ (id)initWithIdentifier:(NSString *)identifier;
+ (BOOL)checkAlertNeededWithViewController:(UIViewController*)vc andExecutionBlock:(void(^)(UIAlertAction *action))block forKeys:(NSString *)firstKey, ...  NS_REQUIRES_NIL_TERMINATION;

@property (strong, nonatomic) UIWindow *window;

@end
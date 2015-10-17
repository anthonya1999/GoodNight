//
//  GammaController.h
//  GoodNight
//
//  Created by Anthony Agatiello on 6/22/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GammaController : NSObject <UIAlertViewDelegate>

typedef struct __IOMobileFramebuffer *IOMobileFramebufferConnection;
typedef kern_return_t IOMobileFramebufferReturn;

+ (void)setGammaWithRed:(float)red green:(float)green blue:(float)blue;
+ (void)setGammaWithOrangeness:(float)percentOrange;
+ (void)autoChangeOrangenessIfNeeded;
+ (void)wakeUpScreenIfNeeded;
+ (void)enableOrangenessWithDefaults:(BOOL)defaults;
+ (void)disableOrangenessWithDefaults:(BOOL)defaults key:(NSString *)key;
+ (void)showFailedAlertWithKey:(NSString *)key;
+ (void)enableDimness;
+ (void)setGammaWithCustomValues;
+ (BOOL)adjustmentForKeysEnabled:(NSString *)key1 key2:(NSString *)key2;

@end
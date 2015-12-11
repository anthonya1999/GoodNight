//
//  GammaController.h
//  GoodNight
//
//  Created by Anthony Agatiello on 6/22/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SBS_PATH "/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices"

typedef kern_return_t SpringBoardServicesReturn;

typedef NS_ENUM(NSInteger, TimeBasedAction) {
    SwitchToOrangeness,
    SwitchToStandard,
    KeepOrangenessEnabled,
    KeepStandardEnabled
};

@interface GammaController : NSObject

+ (void)autoChangeOrangenessIfNeededWithTransition:(BOOL)transition;
+ (void)enableOrangenessWithDefaults:(BOOL)defaults transition:(BOOL)transition;
+ (void)setGammaWithTransitionFrom:(float)oldPercentOrange to:(float)newPercentOrange;
+ (void)disableOrangenessWithDefaults:(BOOL)defaults key:(NSString *)key transition:(BOOL)transition;
+ (void)enableDimness;
+ (void)setGammaWithCustomValues;
+ (void)suspendApp;
+ (void)disableColorAdjustment;
+ (void)disableDimness;
+ (void)disableOrangeness;
+ (void)switchScreenTemperatureBasedOnLocation;
+ (TimeBasedAction)timeBasedActionForPrefix:(NSString*)autoOrNightPrefix;
+ (BOOL)checkCompatibility;
+ (void)setDarkroomEnabled:(BOOL)enable;
+ (BOOL)adjustmentForKeysEnabled:(NSString *)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

@end
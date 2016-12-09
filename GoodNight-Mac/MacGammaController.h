//
//  MacGammaController.h
//  GoodNight
//
//  Created by Anthony Agatiello on 12/7/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MacGammaController : NSObject

+ (void)setGammaWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
+ (void)setGammaWithOrangeness:(float)percentOrange;
+ (void)setInvertedColorsEnabled:(BOOL)enabled;
+ (void)resetAllAdjustments;
+ (void)toggleDarkroom;
+ (void)toggleSystemTheme;
+ (void)setWhitePoint:(float)whitePoint;

@end

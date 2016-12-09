//
//  MacGammaController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 12/7/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import "MacGammaController.h"
#include <dlfcn.h>

@implementation MacGammaController

float quadraticBezier (float x, float a, float b) {
    float epsilon = 0.00001;
    a = MAX(0.0, MIN(1, a));
    b = MAX(0.0, MIN(1, b));
    
    if (a == 0.5) {
        a += epsilon;
    }
    
    float om2a = 1.0f - 2.0f * a;
    float t = (sqrt(a * a + om2a * x) - a) / om2a;
    float y = (1.0f - 2.0f * b) * (t * t) + (2.0f * b) * t;
    return y;
}

float symmetricQuadraticBezier(float x, float bulge) {
    bulge = (bulge / 2.0f) + 0.5f;
    float a = bulge;
    float b = 1.0f - bulge;
    float r = quadraticBezier(x, a, b);
    return r;
}

+ (void)setGammaWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    const CGGammaValue redTable[256] = {0.0, red};
    const CGGammaValue greenTable[256] = {0.0, green};
    const CGGammaValue blueTable[256] = {0.0, blue};
    
    CGSetDisplayTransferByTable(CGMainDisplayID(), 2, redTable, greenTable, blueTable);
}

+ (void)setWhitePoint:(float)whitePoint {
    CGGammaValue table[256] = {0, 0};
    
    for (int i = 0; i < 256; i++) {
        table[i] = symmetricQuadraticBezier(i / 255.0f, (whitePoint * 2) - 1);
    }
    
    CGSetDisplayTransferByTable(CGMainDisplayID(), sizeof(table) / sizeof(table[0]), table, table, table);
}

+ (void)setGammaWithOrangeness:(float)percentOrange {
    if (percentOrange > 1 || percentOrange < 0) {
        return;
    }
    
    float hectoKelvin = percentOrange * 45 + 20;
    float red = 255.0;
    float green = -155.25485562709179 + -0.44596950469579133 * (hectoKelvin - 2) + 104.49216199393888 * log(hectoKelvin - 2);
    float blue = -254.76935184120902 + 0.8274096064007395 * (hectoKelvin - 10) + 115.67994401066147 * log(hectoKelvin - 10);
    
    if (percentOrange == 1) {
        green = 255.0;
        blue = 255.0;
    }
    
    red /= 255.0;
    green /= 255.0;
    blue /= 255.0;
    
    [MacGammaController setGammaWithRed:red green:green blue:blue];
}

+ (void)setInvertedColorsEnabled:(BOOL)enabled {
    void *(*CGDisplaySetInvertedPolarity)(BOOL invertedPolarity) = dlsym(RTLD_DEFAULT, "CGDisplaySetInvertedPolarity");
    NSParameterAssert(CGDisplaySetInvertedPolarity);
    CGDisplaySetInvertedPolarity(enabled);
}

+ (void)toggleSystemTheme {
    if (![userDefaults boolForKey:@"darkThemeEnabled"]) {
        [userDefaults setBool:YES forKey:@"darkThemeEnabled"];
    }
    else {
        [userDefaults setBool:NO forKey:@"darkThemeEnabled"];
    }
    
    NSAppleScript *themeScript = [[NSAppleScript alloc] initWithSource:
                                  @"\
                                  tell application \"System Events\"\n\
                                  tell appearance preferences to set dark mode to not dark mode\n\
                                  end tell"];
    
    NSDictionary *errorDict = [NSDictionary dictionary];
    [themeScript executeAndReturnError:&errorDict];
}

+ (void)toggleDarkroom {
    if (![userDefaults boolForKey:@"darkroomEnabled"]) {
        [userDefaults setBool:YES forKey:@"darkroomEnabled"];
        [userDefaults setFloat:1 forKey:@"orangeValue"];
        [userDefaults setFloat:1 forKey:@"brightnessValue"];
        [userDefaults setFloat:0.5 forKey:@"whitePointValue"];
        CGDisplayRestoreColorSyncSettings();
        [MacGammaController setGammaWithRed:1 green:0 blue:0];
        [MacGammaController setInvertedColorsEnabled:YES];
    }
    else {
        [userDefaults setBool:NO forKey:@"darkroomEnabled"];
        [userDefaults setFloat:1 forKey:@"orangeValue"];
        [userDefaults setFloat:1 forKey:@"brightnessValue"];
        [userDefaults setFloat:0.5 forKey:@"whitePointValue"];
        CGDisplayRestoreColorSyncSettings();
        [MacGammaController setInvertedColorsEnabled:NO];
    }
    [userDefaults synchronize];
}

+ (void)resetAllAdjustments {
    [userDefaults setFloat:1 forKey:@"orangeValue"];
    [userDefaults setFloat:1 forKey:@"brightnessValue"];
    [userDefaults setBool:NO forKey:@"darkroomEnabled"];
    [userDefaults setFloat:0.5 forKey:@"whitePointValue"];
    [userDefaults synchronize];
    CGDisplayRestoreColorSyncSettings();
    [MacGammaController setInvertedColorsEnabled:NO];
}

@end

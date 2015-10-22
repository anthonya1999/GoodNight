//
//  GammaController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 6/22/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "NSDate+Extensions.h"
#include <dlfcn.h>

@implementation GammaController

+ (void)setGammaWithRed:(float)red green:(float)green blue:(float)blue {
    NSUInteger rs = red * 0x100;
    NSParameterAssert(rs <= 0x100);
    
    NSUInteger gs = green * 0x100;
    NSParameterAssert(gs <= 0x100);
    
    NSUInteger bs = blue * 0x100;
    NSParameterAssert(bs <= 0x100);
    
    IOMobileFramebufferConnection fb = NULL;
    
    void *IOMobileFramebuffer = dlopen("/System/Library/PrivateFrameworks/IOMobileFramebuffer.framework/IOMobileFramebuffer", RTLD_LAZY);
    NSParameterAssert(IOMobileFramebuffer);
    
    IOMobileFramebufferReturn (*IOMobileFramebufferGetMainDisplay)(IOMobileFramebufferConnection *connection) = dlsym(IOMobileFramebuffer, "IOMobileFramebufferGetMainDisplay");
    NSParameterAssert(IOMobileFramebufferGetMainDisplay);
    
    IOMobileFramebufferGetMainDisplay(&fb);
    
    NSUInteger data[0xc0c / sizeof(NSUInteger)];
    memset(data, 0, sizeof(data));
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingString:@"/gammatable.dat"];
    FILE *file = fopen([filePath UTF8String], "rb");
    
    if (file == NULL) {
        IOMobileFramebufferReturn (*IOMobileFramebufferGetGammaTable)(IOMobileFramebufferConnection connection, void *data) = dlsym(IOMobileFramebuffer, "IOMobileFramebufferGetGammaTable");
        NSParameterAssert(IOMobileFramebufferGetGammaTable);
        
        IOMobileFramebufferGetGammaTable(fb, data);
        
        file = fopen([filePath UTF8String], "wb");
        NSParameterAssert(file != NULL);
        
        fwrite(data, 1, sizeof(data), file);
        fclose(file);
        
        file = fopen([filePath UTF8String], "rb");
        NSParameterAssert(file != NULL);
    }
    
    fread(data, 1, sizeof(data), file);
    fclose(file);
    
    for (NSInteger i = 0; i < 256; ++i) {
        NSInteger j = 255 - i;
        
        NSInteger r = j * rs >> 8;
        NSInteger g = j * gs >> 8;
        NSInteger b = j * bs >> 8;
        
        data[j + 0x001] = data[r + 0x001];
        data[j + 0x102] = data[g + 0x102];
        data[j + 0x203] = data[b + 0x203];
    }
    
    IOMobileFramebufferReturn (*IOMobileFramebufferSetGammaTable)(IOMobileFramebufferConnection connection, void *data) = dlsym(IOMobileFramebuffer, "IOMobileFramebufferSetGammaTable");
    NSParameterAssert(IOMobileFramebufferSetGammaTable);
    
    IOMobileFramebufferSetGammaTable(fb, data);
    
    dlclose(IOMobileFramebuffer);
}

+ (void)setGammaWithOrangeness:(float)percentOrange {
    if (percentOrange > 1 || percentOrange < 0) {
        return;
    }
    
    float red = 1.0;
    float blue = 1 - percentOrange;
    float green = (red + blue) / 2.0;
    
    if (percentOrange == 0) {
        red = blue = green = 0.99;
    }
    
    if ([self wakeUpScreenIfNeeded]) {
        [self setGammaWithRed:red green:green blue:blue];
    }
}

+ (void)autoChangeOrangenessIfNeededWithTransition:(BOOL)transition {
    if ([userDefaults boolForKey:@"enabled"]) {
        [self enableOrangenessWithDefaults:YES transition:transition];
    }
    
    if (![userDefaults boolForKey:@"colorChangingEnabled"]) {
        return;
    }
    
    NSDate *currentDate = [NSDate date];
    NSDateComponents *autoOnOffComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
    
    autoOnOffComponents.hour = [userDefaults integerForKey:@"autoStartHour"];
    autoOnOffComponents.minute = [userDefaults integerForKey:@"autoStartMinute"];
    NSDate *turnOnDate = [[NSCalendar currentCalendar] dateFromComponents:autoOnOffComponents];
    
    autoOnOffComponents.hour = [userDefaults integerForKey:@"autoEndHour"];
    autoOnOffComponents.minute = [userDefaults integerForKey:@"autoEndMinute"];
    NSDate *turnOffDate = [[NSCalendar currentCalendar] dateFromComponents:autoOnOffComponents];
    
    if ([turnOnDate isLaterThan:turnOffDate]) {
        if ([currentDate isEarlierThan:turnOnDate] && [currentDate isEarlierThan:turnOffDate]) {
            autoOnOffComponents.day = autoOnOffComponents.day - 1;
            turnOnDate = [[NSCalendar currentCalendar] dateFromComponents:autoOnOffComponents];
        }
        else if ([turnOnDate isEarlierThan:currentDate] && [turnOffDate isEarlierThan:currentDate]) {
            autoOnOffComponents.day = autoOnOffComponents.day + 1;
            turnOffDate = [[NSCalendar currentCalendar] dateFromComponents:autoOnOffComponents];
        }
    }
    
    if ([turnOnDate isEarlierThan:currentDate] && [turnOffDate isLaterThan:currentDate]) {
        if ([turnOnDate isLaterThan:[userDefaults objectForKey:@"lastAutoChangeDate"]]) {
            [self enableOrangenessWithDefaults:YES transition:transition];
        }
    }
    else {
        if ([turnOffDate isLaterThan:[userDefaults objectForKey:@"lastAutoChangeDate"]]) {
            [self disableOrangenessWithDefaults:YES key:@"enabled" transition:transition];
        }
    }
    [userDefaults setObject:[NSDate date] forKey:@"lastAutoChangeDate"];
}

+ (void)enableOrangenessWithDefaults:(BOOL)defaults transition:(BOOL)transition {
    if ([self adjustmentForKeysEnabled:@"dimEnabled" key2:@"rgbEnabled"] == NO) {
        float orangeLevel = [userDefaults floatForKey:@"maxOrange"];
        if (transition == YES) {
            [self setGammaWithTransitionFrom:0 to:orangeLevel];
        }
        else {
            [self setGammaWithOrangeness:orangeLevel];
        }
        if (defaults == YES) {
            [userDefaults setObject:[NSDate date] forKey:@"lastAutoChangeDate"];
            [userDefaults setBool:YES forKey:@"enabled"];
        }
        [userDefaults setObject:@"0" forKey:@"keyEnabled"];
    }
    else {
        [self showFailedAlertWithKey:@"enabled"];
    }
    [userDefaults synchronize];
    [ForceTouchController updateShortcutItems];
}

+ (void)setGammaWithTransitionFrom:(float)oldPercentOrange to:(float)newPercentOrange {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (newPercentOrange > oldPercentOrange) {
            for (float i = oldPercentOrange; i <= newPercentOrange; i = i + 0.01) {
                [NSThread sleepForTimeInterval:0.02];
                [self setGammaWithOrangeness:i];
            }
        }
        else {
            for (float i = oldPercentOrange; i >= newPercentOrange; i = i - 0.01) {
                [NSThread sleepForTimeInterval:0.02];
                [self setGammaWithOrangeness:i];
            }
        }
    });
}

+ (void)disableOrangenessWithDefaults:(BOOL)defaults key:(NSString *)key transition:(BOOL)transition {
    if (transition == YES) {
        [self setGammaWithTransitionFrom:[userDefaults floatForKey:@"maxOrange"] to:0];
    }
    else {
        [self setGammaWithOrangeness:0];
    }
    if (defaults == YES) {
        [userDefaults setObject:[NSDate date] forKey:@"lastAutoChangeDate"];
        [userDefaults setBool:NO forKey:key];
    }
    [userDefaults synchronize];
    [ForceTouchController updateShortcutItems];
}

+ (BOOL)wakeUpScreenIfNeeded {
    void *SpringBoardServices = dlopen("/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices", RTLD_LAZY);
    NSParameterAssert(SpringBoardServices);
    mach_port_t (*SBSSpringBoardServerPort)() = dlsym(SpringBoardServices, "SBSSpringBoardServerPort");
    NSParameterAssert(SBSSpringBoardServerPort);
    mach_port_t sbsMachPort = SBSSpringBoardServerPort();
    BOOL isLocked, passcodeEnabled;
    void *(*SBGetScreenLockStatus)(mach_port_t port, BOOL *isLocked, BOOL *passcodeEnabled) = dlsym(SpringBoardServices, "SBGetScreenLockStatus");
    NSParameterAssert(SBGetScreenLockStatus);
    SBGetScreenLockStatus(sbsMachPort, &isLocked, &passcodeEnabled);
    
    if (isLocked) {
        void *(*SBSUndimScreen)() = dlsym(SpringBoardServices, "SBSUndimScreen");
        NSParameterAssert(SBSUndimScreen);
        SBSUndimScreen();
    }

    dlclose(SpringBoardServices);
    return !isLocked;
    
}

+ (void)showFailedAlertWithKey:(NSString *)key {
    [userDefaults setObject:@"1" forKey:@"keyEnabled"];
    [userDefaults setBool:NO forKey:key];
    [userDefaults synchronize];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You may only use one adjustment at a time. Please disable any other adjustments before enabling this one." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

+ (void)enableDimness {
    if ([self adjustmentForKeysEnabled:@"enabled" key2:@"rgbEnabled"] == NO) {
        float dimLevel = [userDefaults floatForKey:@"dimLevel"];
        [self setGammaWithRed:dimLevel green:dimLevel blue:dimLevel];
        [userDefaults setBool:YES forKey:@"dimEnabled"];
        [userDefaults setObject:@"0" forKey:@"keyEnabled"];
    }
    else {
        [self showFailedAlertWithKey:@"dimEnabled"];
    }
    [userDefaults synchronize];
    [ForceTouchController updateShortcutItems];
}

+ (void)setGammaWithCustomValues {
    if ([self adjustmentForKeysEnabled:@"dimEnabled" key2:@"enabled"] == NO) {
        float redValue = [userDefaults floatForKey:@"redValue"];
        float greenValue = [userDefaults floatForKey:@"greenValue"];
        float blueValue = [userDefaults floatForKey:@"blueValue"];
        [self setGammaWithRed:redValue green:greenValue blue:blueValue];
        [userDefaults setBool:YES forKey:@"rgbEnabled"];
        [userDefaults setObject:@"0" forKey:@"keyEnabled"];
    }
    else {
        [self showFailedAlertWithKey:@"rgbEnabled"];
    }
    [userDefaults synchronize];
    [ForceTouchController updateShortcutItems];
}

+ (BOOL)adjustmentForKeysEnabled:(NSString *)key1 key2:(NSString *)key2 {
    if (![userDefaults boolForKey:key1] && ![userDefaults boolForKey:key2]) {
        return NO;
    }
    return YES;
}

@end
//
//  GammaController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 6/22/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "GammaController.h"
#import "ForceTouchController.h"

#import "NSDate+Extensions.h"
#include <dlfcn.h>

#import "Solar.h"
#import "Brightness.h"

@implementation GammaController

+ (void)setGammaWithRed:(float)red green:(float)green blue:(float)blue {
    unsigned rs = red * 0x100;
    NSParameterAssert(rs <= 0x100);
    
    unsigned gs = green * 0x100;
    NSParameterAssert(gs <= 0x100);
    
    unsigned bs = blue * 0x100;
    NSParameterAssert(bs <= 0x100);
    
    IOMobileFramebufferConnection fb = NULL;
    
    void *IOMobileFramebuffer = dlopen("/System/Library/PrivateFrameworks/IOMobileFramebuffer.framework/IOMobileFramebuffer", RTLD_LAZY);
    NSParameterAssert(IOMobileFramebuffer);
    
    IOMobileFramebufferReturn (*IOMobileFramebufferGetMainDisplay)(IOMobileFramebufferConnection *connection) = dlsym(IOMobileFramebuffer, "IOMobileFramebufferGetMainDisplay");
    NSParameterAssert(IOMobileFramebufferGetMainDisplay);
    
    IOMobileFramebufferGetMainDisplay(&fb);
    
    uint32_t data[0xc0c / sizeof(uint32_t)];
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
    
    for (size_t i = 0; i < 256; ++i) {
        size_t j = 255 - i;
        
        size_t r = j * rs >> 8;
        size_t g = j * gs >> 8;
        size_t b = j * bs >> 8;
        
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
    
    [self setGammaWithRed:red green:green blue:blue];
}

+ (void)autoChangeOrangenessIfNeededWithTransition:(BOOL)transition {
    if (![userDefaults boolForKey:@"colorChangingEnabled"] && ![userDefaults boolForKey:@"colorChangingLocationEnabled"]) {
        return;
    }
    
    BOOL nightModeWasEnabled = NO;
    
    if ([userDefaults boolForKey:@"colorChangingNightEnabled"] && [userDefaults boolForKey:@"enabled"]) {
        TimeBasedAction nightAction = [self timeBasedActionForPrefix:@"night"];
        switch (nightAction) {
            case SwitchToOrangeness:
                [GammaController enableOrangenessWithDefaults:YES transition:YES orangeLevel:[userDefaults floatForKey:@"nightOrange"]];
                nightModeWasEnabled = YES;
                break;
            default:
                break;
        }
    }
    
    

    if (!nightModeWasEnabled){
        if ([userDefaults boolForKey:@"colorChangingLocationEnabled"]) {
            [self switchScreenTemperatureBasedOnLocation];
        } else if ([userDefaults boolForKey:@"colorChangingEnabled"]){
            TimeBasedAction autoAction = [self timeBasedActionForPrefix:@"auto"];
            
            switch (autoAction) {
                case SwitchToOrangeness:
                    [self enableOrangenessWithDefaults:YES transition:YES];
                    break;
                case SwitchToStandard:
                    [self disableOrangeness];
                    break;
                case NoSwitchNeeded:
                default:
                    break;
            }
        }
    }
    
    [userDefaults setObject:[NSDate date] forKey:@"lastAutoChangeDate"];
    [userDefaults synchronize];
}

+ (void)enableOrangenessWithDefaults:(BOOL)defaults transition:(BOOL)transition {
    float orangeLevel = [userDefaults floatForKey:@"maxOrange"];
    [self enableOrangenessWithDefaults:defaults transition:transition orangeLevel:orangeLevel];
}

+ (void)enableOrangenessWithDefaults:(BOOL)defaults transition:(BOOL)transition orangeLevel:(float)orangeLevel {
    float currentOrangeLevel = [userDefaults floatForKey:@"currentOrange"];
    if (currentOrangeLevel == orangeLevel) {
        return;
    }
    
    if ([self adjustmentForKeysEnabled:@"dimEnabled" key2:@"rgbEnabled"] == NO) {
        
        [self wakeUpScreenIfNeeded];
        if (transition == YES) {
            [self setGammaWithTransitionFrom:currentOrangeLevel to:orangeLevel];
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
    [userDefaults setFloat:orangeLevel forKey:@"currentOrange"];
    [userDefaults synchronize];
    [ForceTouchController updateShortcutItems];
}

static NSOperationQueue *queue = nil;

+ (void)setGammaWithTransitionFrom:(float)oldPercentOrange to:(float)newPercentOrange {
    
    if (!queue){
        queue = [NSOperationQueue new];
    }
    
    [queue cancelAllOperations];
    
    __block NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        if (newPercentOrange > oldPercentOrange) {
            for (float i = oldPercentOrange; i <= newPercentOrange; i = i + 0.01) {
                if (operation.isCancelled) break;
                [NSThread sleepForTimeInterval:0.02];
                [self setGammaWithOrangeness:i];
            }
        }
        else {
            for (float i = oldPercentOrange; i >= newPercentOrange; i = i - 0.01) {
                if (operation.isCancelled) break;
                if (i < 0.01) {
                    i = 0;
                }
                [NSThread sleepForTimeInterval:0.02];
                [self setGammaWithOrangeness:i];
            }
        }
    }];
    operation.qualityOfService = NSQualityOfServiceUserInteractive;
    operation.queuePriority = NSOperationQueuePriorityVeryHigh;

    [queue addOperation:operation];

}

+ (void)disableOrangenessWithDefaults:(BOOL)defaults key:(NSString *)key transition:(BOOL)transition {
    float currentOrangeLevel = [userDefaults floatForKey:@"currentOrange"];
    if (currentOrangeLevel == 1.0) {
        return;
    }
    
    [self wakeUpScreenIfNeeded];
    if (transition == YES) {
        float currentOrangeLevel = [userDefaults floatForKey:@"currentOrange"];
        [self setGammaWithTransitionFrom:currentOrangeLevel to:1.0];
    }
    else {
        [self setGammaWithOrangeness:1.0];
    }
    if (defaults == YES) {
        [userDefaults setObject:[NSDate date] forKey:@"lastAutoChangeDate"];
        [userDefaults setBool:NO forKey:key];
    }
    [userDefaults setFloat:1.0 forKey:@"currentOrange"];
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

+ (void)disableColorAdjustment {
    [GammaController disableOrangenessWithDefaults:YES key:@"rgbEnabled" transition:NO];
}

+ (void)disableDimness {
    [GammaController disableOrangenessWithDefaults:YES key:@"dimEnabled" transition:NO];
}

+ (void)disableOrangeness {
    [GammaController disableOrangenessWithDefaults:YES key:@"enabled" transition:YES];
}

+ (void)switchScreenTemperatureBasedOnLocation {
    float latitude = [userDefaults floatForKey:@"colorChangingLocationLatitude"];
    float longitude = [userDefaults floatForKey:@"colorChangingLocationLongitude"];
    
    double solarAngularElevation = solar_elevation([[NSDate date] timeIntervalSince1970], latitude, longitude);
    float maxOrange = [userDefaults floatForKey:@"maxOrange"];
    float maxOrangePercentage = maxOrange * 100;
    float orangeness = (calculate_interpolated_value(solarAngularElevation, 0, maxOrangePercentage) / 100);
    
    if(orangeness > 0) {
        float percent = orangeness / maxOrange;
        float diff = 1.0f - maxOrange;
        [GammaController enableOrangenessWithDefaults:YES transition:YES orangeLevel:MIN(1.0f-percent*diff, 1.0f)];
    }
    else if (orangeness <= 0) {
        [GammaController disableOrangeness];
    }
}



+ (TimeBasedAction)timeBasedActionForPrefix:(NSString*)autoOrNightPrefix{
    if (!autoOrNightPrefix || (![autoOrNightPrefix isEqualToString:@"auto"] && ![autoOrNightPrefix isEqualToString:@"night"])){
        autoOrNightPrefix = @"auto";
    }
    
    NSDate *currentDate = [NSDate date];
    NSDateComponents *autoOnOffComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
    autoOnOffComponents.hour = [userDefaults integerForKey:[autoOrNightPrefix stringByAppendingString:@"StartHour"]];
    autoOnOffComponents.minute = [userDefaults integerForKey:[autoOrNightPrefix stringByAppendingString:@"StartMinute"]];
    NSDate *turnOnDate = [[NSCalendar currentCalendar] dateFromComponents:autoOnOffComponents];
    
    autoOnOffComponents.hour = [userDefaults integerForKey:[autoOrNightPrefix stringByAppendingString:@"EndHour"]];
    autoOnOffComponents.minute = [userDefaults integerForKey:[autoOrNightPrefix stringByAppendingString:@"EndMinute"]];
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
            return SwitchToOrangeness;
        }
    }
    else {
        if ([turnOffDate isLaterThan:[userDefaults objectForKey:@"lastAutoChangeDate"]]) {
            return SwitchToStandard;
        }
    }

    return NoSwitchNeeded;

}

+ (void)suspendApp {
    void *SpringBoardServices = dlopen("/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices", RTLD_LAZY);
    NSParameterAssert(SpringBoardServices);
    mach_port_t (*SBSSpringBoardServerPort)() = dlsym(SpringBoardServices, "SBSSpringBoardServerPort");
    NSParameterAssert(SBSSpringBoardServerPort);
    SpringBoardServicesReturn (*SBSuspend)(mach_port_t port) = dlsym(SpringBoardServices, "SBSuspend");
    NSParameterAssert(SBSuspend);
    mach_port_t sbsMachPort = SBSSpringBoardServerPort();
    SBSuspend(sbsMachPort);
    dlclose(SpringBoardServices);
}

+ (BOOL)adjustmentForKeysEnabled:(NSString *)key1 key2:(NSString *)key2 {
    if (![userDefaults boolForKey:key1] && ![userDefaults boolForKey:key2]) {
        return NO;
    }
    return YES;
}

@end
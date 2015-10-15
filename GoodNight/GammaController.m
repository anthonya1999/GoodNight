//
//  GammaController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 6/22/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "GammaController.h"
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
    float green = (red + blue)/2.0;
    
    if (percentOrange == 0) {
        red = blue = green = 0.99;
    }
    
    [self setGammaWithRed:red green:green blue:blue];
}

+ (void)autoChangeOrangenessIfNeeded {
    if ([userDefaults boolForKey:@"enabled"]) {
        [self enableOrangeness];
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
            [GammaController enableOrangeness];
        }
    }
    else {
        if ([turnOffDate isLaterThan:[userDefaults objectForKey:@"lastAutoChangeDate"]]) {
            [GammaController disableOrangeness];
        }
    }
    
    [userDefaults setObject:[NSDate date] forKey:@"lastAutoChangeDate"];
}

+ (void)enableOrangeness {
    [self wakeUpScreenIfNeeded];
    [GammaController setGammaWithOrangeness:[userDefaults floatForKey:@"maxOrange"]];
    [userDefaults setObject:[NSDate date] forKey:@"lastAutoChangeDate"];
    [userDefaults setBool:YES forKey:@"enabled"];
    [userDefaults synchronize];
}

+ (void)disableOrangeness {
    [self wakeUpScreenIfNeeded];
    [GammaController setGammaWithOrangeness:0];
    [userDefaults setObject:[NSDate date] forKey:@"lastAutoChangeDate"];
    [userDefaults setBool:NO forKey:@"enabled"];
    [userDefaults synchronize];
}

+ (void)wakeUpScreenIfNeeded {
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
    
}

@end
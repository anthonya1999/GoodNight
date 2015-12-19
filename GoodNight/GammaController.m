//
//  GammaController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 6/22/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "GammaController.h"
#import <UIKit/UIKit.h>

#import "NSDate+Extensions.h"
#include <dlfcn.h>

#import "Solar.h"
#import "Brightness.h"
#import "IOMobileFramebufferClient.h"
#import "SpringBoardServicesClient.h"
#import "MobileGestaltClient.h"

@implementation GammaController

+ (void)initialize {
    if (self == [GammaController class]) {
        minWhitePointValue = [[IOMobileFramebufferClient sharedInstance] gamutMatrixFunctionIsUsable] ? 30345 : 43110;
    }
}

+ (void)setWhitePoint:(uint32_t)value {
    if (value > IOMobileFramebufferBrightnessCorrectionDefault){
        value = IOMobileFramebufferBrightnessCorrectionDefault;
    }
    if (value < minWhitePointValue){
        value = minWhitePointValue;
    }
    
    if ([[IOMobileFramebufferClient sharedInstance] gamutMatrixFunctionIsUsable]) {
        [userDefaults setBool:NO forKey:@"enabled"];
        [GammaController setGammaWithMatrixAndRed:1 green:1 blue:1];
    }
    
    [[IOMobileFramebufferClient sharedInstance] setBrightnessCorrection:value];
}

+ (void)resetWhitePoint {
    [[IOMobileFramebufferClient sharedInstance] resetBrightnessCorrection];
}

+ (uint32_t)getMinimumWhitePoint {
    return minWhitePointValue;
}

+ (void)setDarkroomEnabled:(BOOL)enable {
    if (enable) {
        [[IOMobileFramebufferClient sharedInstance] setWhiteOnBlackMode:YES];
    }
    else {
        [[IOMobileFramebufferClient sharedInstance] setWhiteOnBlackMode:NO];
    }
}

+ (void)setGammaWithRed:(float)red green:(float)green blue:(float)blue {
    if (![self gammaTableFunctionIsUsable]) {
        [self setGammaWithMatrixAndRed:red green:green blue:blue];
    }
    else {
        [self setGammaWithTableAndRed:red green:green blue:blue];
    }
}

+ (void)setGammaWithMatrixAndRed:(float)red green:(float)green blue:(float)blue {
    IOMobileFramebufferGamutMatrix gamutMatrix;
    memset(&gamutMatrix, 0, sizeof(gamutMatrix));
    
    if ([userDefaults boolForKey:@"enabled"]) {
        red = ((red * 1.3) + 0.05);
        green = (((green * 1.3) / 2.1008403361) + 0.05);
        blue = (((blue * 1.3) / 4.6296296296) + 0.05);
    }
    
    gamutMatrix.content.matrix[0][0] = GamutMatrixValue(red);
    gamutMatrix.content.matrix[1][1] = GamutMatrixValue(green);
    gamutMatrix.content.matrix[2][2] = GamutMatrixValue(blue);
    
    [[IOMobileFramebufferClient sharedInstance] setGamutMatrix:&gamutMatrix];
    [[IOMobileFramebufferClient sharedInstance] gamutMatrix:&gamutMatrix];
}

+ (void)setGammaWithTableAndRed:(float)red green:(float)green blue:(float)blue {
    unsigned rs = red * 0x100;
    NSParameterAssert(rs <= 0x100);
    
    unsigned gs = green * 0x100;
    NSParameterAssert(gs <= 0x100);
    
    unsigned bs = blue * 0x100;
    NSParameterAssert(bs <= 0x100);
    
    IOMobileFramebufferGammaTable data;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingString:@"/gammatable.dat"];
    FILE *file = fopen([filePath UTF8String], "rb");
    
    if (file == NULL) {
        [[IOMobileFramebufferClient sharedInstance] gammaTable:&data];
        file = fopen([filePath UTF8String], "wb");
        NSParameterAssert(file != NULL);
        
        fwrite(&data, 1, sizeof(data), file);
        fclose(file);
        
        file = fopen([filePath UTF8String], "rb");
        NSParameterAssert(file != NULL);
    }
    
    fread(&data, 1, sizeof(data), file);
    fclose(file);
    
    for (size_t i = 0; i < 256; ++i) {
        size_t j = 255 - i;
        
        size_t r = j * rs >> 8;
        size_t g = j * gs >> 8;
        size_t b = j * bs >> 8;
        
        data.values[j + 0x001] = data.values[r + 0x001];
        data.values[j + 0x102] = data.values[g + 0x102];
        data.values[j + 0x203] = data.values[b + 0x203];
    }
    
    [[IOMobileFramebufferClient sharedInstance] setGammaTable:&data];
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
                [userDefaults setBool:NO forKey:@"dimEnabled"];
                [userDefaults setBool:NO forKey:@"rgbEnabled"];
                [userDefaults setBool:NO forKey:@"whitePointEnabled"];
            case KeepOrangenessEnabled:
                [self enableOrangenessWithDefaults:YES transition:transition orangeLevel:[userDefaults floatForKey:@"nightOrange"]];
                nightModeWasEnabled = YES;
                break;
            default:
                break;
        }
    }

    if (!nightModeWasEnabled){
        if ([userDefaults boolForKey:@"colorChangingLocationEnabled"]) {
            [self switchScreenTemperatureBasedOnLocationWithTransition:transition];
        }
        else if ([userDefaults boolForKey:@"colorChangingEnabled"]){
            TimeBasedAction autoAction = [self timeBasedActionForPrefix:@"auto"];
            
            switch (autoAction) {
                case SwitchToOrangeness:
                    [userDefaults setBool:NO forKey:@"dimEnabled"];
                    [userDefaults setBool:NO forKey:@"rgbEnabled"];
                    [userDefaults setBool:NO forKey:@"whitePointEnabled"];
                case KeepOrangenessEnabled:
                    [self enableOrangenessWithDefaults:YES transition:transition orangeLevel:[userDefaults floatForKey:@"maxOrange"]];
                    break;
                case SwitchToStandard:
                    [userDefaults setBool:NO forKey:@"dimEnabled"];
                    [userDefaults setBool:NO forKey:@"rgbEnabled"];
                    [userDefaults setBool:NO forKey:@"whitePointEnabled"];
                case KeepStandardEnabled:
                    [self enableOrangenessWithDefaults:YES transition:transition orangeLevel:[userDefaults floatForKey:@"dayOrange"]];
                    break;
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
    
    [self wakeUpScreenIfNeeded];
    
    [self resetWhitePoint];
    
    if (transition == YES) {
        [self setGammaWithTransitionFrom:currentOrangeLevel to:orangeLevel];
    }
    else {
        [self setGammaWithOrangeness:orangeLevel];
    }
    if (defaults == YES) {
        [userDefaults setObject:[NSDate date] forKey:@"lastAutoChangeDate"];
        [userDefaults setBool:(orangeLevel==1.0f)?NO:YES forKey:@"enabled"];
    }
    
    [userDefaults setObject:@"0" forKey:@"keyEnabled"];
    [userDefaults setFloat:orangeLevel forKey:@"currentOrange"];
    [userDefaults synchronize];
}

+ (void)setGammaWithTransitionFrom:(float)oldPercentOrange to:(float)newPercentOrange {
    static NSOperationQueue *queue = nil;

    if (!queue) {
        queue = [NSOperationQueue new];
    }
    
    [queue cancelAllOperations];
    
    NSBlockOperation *operation = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation *weakOperation = operation;
    [operation addExecutionBlock:^{
        if (newPercentOrange > oldPercentOrange) {
            for (float i = oldPercentOrange; i <= newPercentOrange; i = i + 0.01) {
                if (weakOperation.isCancelled) break;
                if (i > 0.99) {
                    i = 1.0f;
                }
                [NSThread sleepForTimeInterval:0.02];
                [self setGammaWithOrangeness:i];
            }
        }
        else {
            for (float i = oldPercentOrange; i >= newPercentOrange; i = i - 0.01) {
                if (weakOperation.isCancelled) break;
                if (i < 0.01) {
                    i = 0.0f;
                }
                [NSThread sleepForTimeInterval:0.02];
                [self setGammaWithOrangeness:i];
            }
        }
    }];
    
    if ([operation respondsToSelector:@selector(setQualityOfService:)]) {
        [operation setQualityOfService:NSQualityOfServiceUserInteractive];
    }
    else {
        [operation setThreadPriority:1.0f];
    }
    operation.queuePriority = NSOperationQueuePriorityVeryHigh;
    [queue addOperation:operation];
}

+ (void)disableGammaWithTransition:(BOOL)transition {
    if (transition == YES) {
        float currentOrangeLevel = [userDefaults floatForKey:@"currentOrange"];
        [self setGammaWithTransitionFrom:currentOrangeLevel to:1.0];
    }
    else {
        [self setGammaWithOrangeness:1.0];
    }
    [userDefaults setObject:[NSDate date] forKey:@"lastAutoChangeDate"];
    [userDefaults setFloat:1.0 forKey:@"currentOrange"];
    [userDefaults synchronize];
}

+ (BOOL)wakeUpScreenIfNeeded {
    BOOL isLocked = [[SpringBoardServicesClient sharedInstance] SBGetScreenLockStatusIsLocked];
    
    if (isLocked) {
        [[SpringBoardServicesClient sharedInstance] SBSUndimScreen];
    }
    return !isLocked;
    
}

+ (void)enableDimness {
    [self resetWhitePoint];
    
    float dimLevel = [userDefaults floatForKey:@"dimLevel"];
    [self setGammaWithRed:dimLevel green:dimLevel blue:dimLevel];
    [userDefaults setBool:YES forKey:@"dimEnabled"];
    [userDefaults setObject:@"0" forKey:@"keyEnabled"];
    [userDefaults synchronize];
}

+ (void)setGammaWithCustomValues {
    [self resetWhitePoint];
    
    float redValue = [userDefaults floatForKey:@"redValue"];
    float greenValue = [userDefaults floatForKey:@"greenValue"];
    float blueValue = [userDefaults floatForKey:@"blueValue"];
    [self setGammaWithRed:redValue green:greenValue blue:blueValue];
    [userDefaults setBool:YES forKey:@"rgbEnabled"];
    [userDefaults setObject:@"0" forKey:@"keyEnabled"];

    [userDefaults synchronize];
}

+ (void)disableColorAdjustment {
    [self disableGammaWithTransition:NO];
    [userDefaults setBool:NO forKey:@"rgbEnabled"];

}

+ (void)disableDimness {
    [self disableGammaWithTransition:NO];
    [userDefaults setBool:NO forKey:@"dimEnabled"];
}

+ (void)disableOrangeness {
    float currentOrangeLevel = [userDefaults floatForKey:@"currentOrange"];
    if (!(currentOrangeLevel < 1.0f)) {
        return;
    }
    
    [self wakeUpScreenIfNeeded];
    [self disableGammaWithTransition:YES];
    [userDefaults setBool:NO forKey:@"enabled"];
}

+ (void)switchScreenTemperatureBasedOnLocationWithTransition:(BOOL)transition {
    float latitude = [userDefaults floatForKey:@"colorChangingLocationLatitude"];
    float longitude = [userDefaults floatForKey:@"colorChangingLocationLongitude"];
    
    double solarAngularElevation = solar_elevation([[NSDate date] timeIntervalSince1970], latitude, longitude);
    float maxOrange = [userDefaults floatForKey:@"maxOrange"];
    float maxOrangePercentage = maxOrange * 100;
    float dayOrange = [userDefaults floatForKey:@"dayOrange"];
    float dayOrangePercentage = dayOrange * 100;
    
    float orangeness = (calculate_interpolated_value(solarAngularElevation, dayOrangePercentage, maxOrangePercentage) / 100);
    
    if(orangeness > 0) {
        [self enableOrangenessWithDefaults:YES transition:transition orangeLevel:MIN(orangeness, 1.0f)];
    }
    else if (orangeness <= 0) {
        [self disableOrangeness];
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
        return KeepOrangenessEnabled;
    }
    else {
        if ([turnOffDate isLaterThan:[userDefaults objectForKey:@"lastAutoChangeDate"]]) {
            return SwitchToStandard;
        }
        return KeepStandardEnabled;
    }
}

+ (void)suspendApp {
    [[SpringBoardServicesClient sharedInstance] SBSuspend];
}

+ (BOOL)adjustmentForKeysEnabled:(NSString *)firstKey, ... {
    
    BOOL adjustmentsEnabled = NO;
    
    va_list args;
    va_start(args, firstKey);
    for (NSString *arg = firstKey; arg != nil; arg = va_arg(args, NSString*))
    {
        if ([userDefaults boolForKey:arg]){
            adjustmentsEnabled = YES;
            break;
        }
    }
    va_end(args);

    return adjustmentsEnabled;
}

+ (BOOL)gammaTableFunctionIsUsable {
    NSString *hwModelStr = (NSString *)[[MobileGestaltClient sharedInstance] MGGetHWModelStr];
    
    if ([hwModelStr isEqualToString:@"J98aAP"] || [hwModelStr isEqualToString:@"J99aAP"]) {
        return NO;
    }
    return YES;
}

@end
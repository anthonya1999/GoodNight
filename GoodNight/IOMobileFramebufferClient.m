//
//  IOMobileFramebufferClient.m
//  GoodNight
//
//  Created by Manu Wallner on 11.12.2015.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import <dlfcn.h>
#import <UIKit/UIKit.h>
#import "IOMobileFramebufferClient.h"

@implementation IOMobileFramebufferClient

s1516 GamutMatrixValue(double value) {
    const uint8_t fractionalBits = 16;
    const uint8_t integerBits = fractionalBits - 1;
    const double largestInteger = pow(2, integerBits);
    const double largestFraction = pow(2, fractionalBits);
    const double range = largestInteger - 1 + ((largestFraction - 1) / largestFraction) + largestInteger;
    return (((value * range) - (range / 2)) * (largestFraction + 0.5));
}

+ (void)initialize {
    [super initialize];
    IOMobileFramebufferHandle = dlopen(IOMFB_PATH, RTLD_LAZY);
    NSParameterAssert(IOMobileFramebufferHandle);
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken = 0;
    static IOMobileFramebufferClient *sharedFramebufferClient = nil;
    
    dispatch_once(&onceToken, ^{
        sharedFramebufferClient = [[self alloc] init];
    });
    
    return sharedFramebufferClient;
}

+ (IOMobileFramebufferConnection)mainDisplayConnection {
    IOMobileFramebufferConnection connection = NULL;
    IOMobileFramebufferReturn (*IOMobileFramebufferGetMainDisplay)(IOMobileFramebufferConnection *connection) = dlsym(IOMobileFramebufferHandle, "IOMobileFramebufferGetMainDisplay");
    NSParameterAssert(IOMobileFramebufferGetMainDisplay);
    IOMobileFramebufferGetMainDisplay(&connection);
    return connection;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _framebufferConnection = [self.class mainDisplayConnection];
    }
    return self;
}

- (void)dealloc {
    dlclose(IOMobileFramebufferHandle);
}

- (void)callFramebufferFunction:(NSString *)function withFirstParamPointer:(void *)pointer {
    NSParameterAssert(pointer);
    IOMobileFramebufferReturn (*IOMobileFramebufferFunction)(IOMobileFramebufferConnection connection, void *pointer) = dlsym(IOMobileFramebufferHandle, function.UTF8String);
    NSParameterAssert(IOMobileFramebufferFunction);
    IOMobileFramebufferFunction(self.framebufferConnection, pointer);
}

- (void)callFramebufferFunction:(NSString *)function withFirstParamScalar:(uint32_t)scalar {
    IOMobileFramebufferReturn (*IOMobileFramebufferFunction)(IOMobileFramebufferConnection connection, uint32_t scalar) = dlsym(IOMobileFramebufferHandle, function.UTF8String);
    NSParameterAssert(IOMobileFramebufferFunction);
    IOMobileFramebufferFunction(self.framebufferConnection, scalar);
}

- (IOMobileFramebufferColorRemapMode)colorRemapMode {
    IOMobileFramebufferReturn (*IOMobileFramebufferGetColorRemapMode)(IOMobileFramebufferConnection connection, IOMobileFramebufferColorRemapMode *mode) = dlsym(IOMobileFramebufferHandle, "IOMobileFramebufferGetColorRemapMode");
    NSParameterAssert(IOMobileFramebufferGetColorRemapMode);
    IOMobileFramebufferColorRemapMode mode = IOMobileFramebufferColorRemapModeNormal;
    IOMobileFramebufferReturn returnValue = IOMobileFramebufferGetColorRemapMode(self.framebufferConnection, &mode);

    if (returnValue == 0) {
        return mode;
    }

    return IOMobileFramebufferColorRemapModeError;
}

- (void)setColorRemapMode:(IOMobileFramebufferColorRemapMode)mode {
    [self callFramebufferFunction:@"IOMobileFramebufferSetColorRemapMode" withFirstParamScalar:mode];
}

- (void)setGamutMatrix:(IOMobileFramebufferGamutMatrix *)matrix {
    NSString *functionName = nil;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        functionName = @"IOMobileFramebufferSetGamutMatrix";
    }
    else {
        functionName = @"IOMobileFramebufferSetGamutCSC";
    }
    [self callFramebufferFunction:functionName withFirstParamPointer:matrix];
}

- (void)gamutMatrix:(IOMobileFramebufferGamutMatrix *)matrix {
    NSString *functionName = nil;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        functionName = @"IOMobileFramebufferGetGamutMatrix";
    }
    else {
        functionName = @"IOMobileFramebufferGetGamutCSC";
    }
    [self callFramebufferFunction:functionName withFirstParamPointer:matrix];
}

@end

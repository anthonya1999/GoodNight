//
//  SpringBoardServicesClient.m
//  GoodNight
//
//  Created by Mario Korte on 11.12.2015.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import <dlfcn.h>
#import "SpringBoardServicesClient.h"

typedef mach_port_t SpringBoardServicesMachPort;
typedef kern_return_t SpringBoardServicesReturn;

#define SBS_PATH "/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices"

@interface SpringBoardServicesClient ()

@property (nonatomic, readonly) SpringBoardServicesMachPort sbsMachPort;

@end

@implementation SpringBoardServicesClient

static void *SpringBoardServicesHandle = NULL;
+ (void)initialize {
    [super initialize];

    SpringBoardServicesHandle = dlopen(SBS_PATH, RTLD_LAZY);
    NSParameterAssert(SpringBoardServicesHandle);
}

+ (instancetype)sharedSpringBoardServicesClient {
    static dispatch_once_t onceToken = 0;
    static SpringBoardServicesClient *sharedSpringBoardServicesClient = nil;
    
    dispatch_once(&onceToken, ^{
        sharedSpringBoardServicesClient = [[self alloc] init];
    });
    
    return sharedSpringBoardServicesClient;
}

+ (SpringBoardServicesMachPort)mainSpringBoardServicesMachPort {
    SpringBoardServicesMachPort port;
    SpringBoardServicesMachPort (*SBSSpringBoardServerPort)() = dlsym(SpringBoardServicesHandle, "SBSSpringBoardServerPort");
    NSParameterAssert(SBSSpringBoardServerPort);
    port = SBSSpringBoardServerPort();
    return port;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _sbsMachPort = [self.class mainSpringBoardServicesMachPort];
    }
    return self;
}

- (void)dealloc {
    dlclose(SpringBoardServicesHandle);
}

- (void)callSBGetScreenLockStatusWithLocked:(BOOL*)isLocked andPasscodeEnabled:(BOOL*)passcodeEnabled{
    void *(*SBGetScreenLockStatus)(SpringBoardServicesMachPort port, BOOL *isLocked, BOOL *passcodeEnabled) = dlsym(SpringBoardServicesHandle, "SBGetScreenLockStatus");
    NSParameterAssert(SBGetScreenLockStatus);
    SBGetScreenLockStatus(self.sbsMachPort, isLocked, passcodeEnabled);
}


- (BOOL)SBGetScreenLockStatusIsLocked{
    BOOL isLocked, passcodeEnabled;
    [self callSBGetScreenLockStatusWithLocked:&isLocked andPasscodeEnabled:&passcodeEnabled];
    return isLocked;
}

- (BOOL)SBGetScreenLockStatusIsPasscodeEnabled{
    BOOL isLocked, passcodeEnabled;
    [self callSBGetScreenLockStatusWithLocked:&isLocked andPasscodeEnabled:&passcodeEnabled];
    return passcodeEnabled;
}

- (void)SBSuspend{
    SpringBoardServicesReturn (*SBSuspend)(SpringBoardServicesMachPort port) = dlsym(SpringBoardServicesHandle, "SBSuspend");
    NSParameterAssert(SBSuspend);
    SBSuspend(self.sbsMachPort);
}

- (void)SBSUndimScreen{
    void *(*SBSUndimScreen)() = dlsym(SpringBoardServicesHandle, "SBSUndimScreen");
    NSParameterAssert(SBSUndimScreen);
    SBSUndimScreen();
}

@end

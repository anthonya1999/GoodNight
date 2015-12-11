//
//  IOMobileFramebufferClient.m
//  GoodNight
//
//  Created by Manu Wallner on 11.12.2015.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import <dlfcn.h>
#import "IOMobileFramebufferClient.h"

typedef struct __IOMobileFramebuffer *IOMobileFramebufferConnection;
typedef kern_return_t IOMobileFramebufferReturn;

#define IOMFB_PATH "/System/Library/PrivateFrameworks/IOMobileFramebuffer.framework/IOMobileFramebuffer"

@interface IOMobileFramebufferClient ()

@property (nonatomic, readonly) IOMobileFramebufferConnection framebufferConnection;

@end

@implementation IOMobileFramebufferClient

static void * IOMobileFramebufferHandle = NULL;
+ (void)initialize {
    [super initialize];

    IOMobileFramebufferHandle = dlopen(IOMFB_PATH, RTLD_LAZY);
    NSParameterAssert(IOMobileFramebufferHandle);
}

+ (IOMobileFramebufferConnection)mainDisplayConnection {
    IOMobileFramebufferConnection connection;
    IOMobileFramebufferReturn (*IOMobileFramebufferGetMainDisplay)(IOMobileFramebufferConnection *) = dlsym(IOMobileFramebufferHandle, "IOMobileFramebufferGetMainDisplay");
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

- (void)callFramebufferFunction:(NSString *)function withFirstParamPointer:(void *)pointer {
    NSParameterAssert(pointer);
    IOMobileFramebufferReturn (*IOMobileFramebufferFunction)(IOMobileFramebufferConnection, void *) = dlsym(IOMobileFramebufferHandle, function.UTF8String);
    NSParameterAssert(IOMobileFramebufferFunction);

    IOMobileFramebufferFunction(self.framebufferConnection, pointer);
}

- (void)callFramebufferFunction:(NSString *)function withFirstParamScalar:(uint32_t)scalar {
    IOMobileFramebufferReturn (*IOMobileFramebufferFunction)(IOMobileFramebufferConnection, uint32_t) = dlsym(IOMobileFramebufferHandle, function.UTF8String);
    NSParameterAssert(IOMobileFramebufferFunction);

    IOMobileFramebufferFunction(self.framebufferConnection, scalar);
}

- (IOMobileFramebufferColorRemapMode)colorRemapMode {
    IOMobileFramebufferReturn (*IOMobileFramebufferGetColorRemapMode)(IOMobileFramebufferConnection, IOMobileFramebufferColorRemapMode *) = dlsym(IOMobileFramebufferHandle, "IOMobileFramebufferGetColorRemapMode");
    NSParameterAssert(IOMobileFramebufferGetColorRemapMode);

    IOMobileFramebufferColorRemapMode mode;
    IOMobileFramebufferReturn ret = IOMobileFramebufferGetColorRemapMode(self.framebufferConnection, &mode);

    if (ret == 0) return mode;

    return IOMobileFramebufferColorRemapModeError;
}

- (void)setColorRemapMode:(IOMobileFramebufferColorRemapMode)mode {
    [self callFramebufferFunction:@"IOMobileFramebufferSetColorRemapMode" withFirstParamScalar:mode];
}

- (void)gammaTable:(IOMobileFramebufferGammaTable *)table {
    [self callFramebufferFunction:@"IOMobileFramebufferGetGammaTable" withFirstParamPointer:table];
}

- (void)setGammaTable:(IOMobileFramebufferGammaTable *)table {
    [self callFramebufferFunction:@"IOMobileFramebufferSetGammaTable" withFirstParamPointer:table];
}

- (void)setGamutMatrix:(IOMobileFramebufferGamutMatrix *)matrix {
    [self callFramebufferFunction:@"IOMobileFramebufferSetGamutMatrix" withFirstParamPointer:matrix];
}

- (void)gamutMatrix:(IOMobileFramebufferGamutMatrix *)matrix {
    [self callFramebufferFunction:@"IOMobileFramebufferGetGamutMatrix" withFirstParamPointer:matrix];
}

@end

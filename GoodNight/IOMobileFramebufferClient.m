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

- (IOMobileFramebufferColorRemapMode)colorRemapMode {
    IOMobileFramebufferReturn (*IOMobileFramebufferGetColorRemapMode)(IOMobileFramebufferConnection connection, IOMobileFramebufferColorRemapMode *mode) = dlsym(IOMobileFramebufferHandle, "IOMobileFramebufferGetColorRemapMode");
    NSParameterAssert(IOMobileFramebufferGetColorRemapMode);

    IOMobileFramebufferColorRemapMode mode;
    IOMobileFramebufferReturn ret = IOMobileFramebufferGetColorRemapMode(self.framebufferConnection, &mode);

    if (ret == 0) return mode;

    return IOMobileFramebufferColorRemapModeError;
}

- (void)setColorRemapMode:(IOMobileFramebufferColorRemapMode)mode {
    IOMobileFramebufferReturn (*IOMobileFramebufferSetColorRemapMode)(IOMobileFramebufferConnection connection, IOMobileFramebufferColorRemapMode mode) = dlsym(IOMobileFramebufferHandle, "IOMobileFramebufferSetColorRemapMode");
    NSParameterAssert(IOMobileFramebufferSetColorRemapMode);

    IOMobileFramebufferSetColorRemapMode(self.framebufferConnection, mode);
}

- (void)gammaTable:(IOMobileFramebufferGammaTable *)table {
    IOMobileFramebufferReturn (*IOMobileFramebufferGetGammaTable)(IOMobileFramebufferConnection connection, IOMobileFramebufferGammaTable *) = dlsym(IOMobileFramebufferHandle, "IOMobileFramebufferGetGammaTable");
    NSParameterAssert(IOMobileFramebufferGetGammaTable);

    IOMobileFramebufferGetGammaTable(self.framebufferConnection, table);
}

- (void)setGammaTable:(IOMobileFramebufferGammaTable *)table {
    IOMobileFramebufferReturn (*IOMobileFramebufferSetGammaTable)(IOMobileFramebufferConnection connection, IOMobileFramebufferGammaTable *) = dlsym(IOMobileFramebufferHandle, "IOMobileFramebufferSetGammaTable");
    NSParameterAssert(IOMobileFramebufferSetGammaTable);

    IOMobileFramebufferSetGammaTable(self.framebufferConnection, table);
}


@end

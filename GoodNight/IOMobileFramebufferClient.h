//
//  IOMobileFramebufferClient.h
//  GoodNight
//
//  Created by Manu Wallner on 11.12.2015.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, IOMobileFramebufferColorRemapMode) {
    IOMobileFramebufferColorRemapModeError = -1,
    IOMobileFramebufferColorRemapModeNormal = 0,
    IOMobileFramebufferColorRemapModeInverted = 1,
    IOMobileFramebufferColorRemapModeGrayscale = 2,
    IOMobileFramebufferColorRemapModeGrayscaleIncreaseContrast = 3,
    IOMobileFramebufferColorRemapModeInvertedGrayscale = 4
};

typedef struct {
    uint32_t values[0xc0c/sizeof(uint32_t)];
} IOMobileFramebufferGammaTable;

@interface IOMobileFramebufferClient : NSObject

- (IOMobileFramebufferColorRemapMode)colorRemapMode;
- (void)setColorRemapMode:(IOMobileFramebufferColorRemapMode)mode;

- (void)gammaTable:(IOMobileFramebufferGammaTable *)table;
- (void)setGammaTable:(IOMobileFramebufferGammaTable *)table;

@end

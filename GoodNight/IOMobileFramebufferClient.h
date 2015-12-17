//
//  IOMobileFramebufferClient.h
//  GoodNight
//
//  Created by Manu Wallner on 11.12.2015.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

static void *IOMobileFramebufferHandle = NULL;
typedef struct __IOMobileFramebuffer *IOMobileFramebufferConnection;
typedef kern_return_t IOMobileFramebufferReturn;

#define IOMFB_PATH "/System/Library/PrivateFrameworks/IOMobileFramebuffer.framework/IOMobileFramebuffer"

typedef NS_ENUM(int, IOMobileFramebufferColorRemapMode) {
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

typedef long s1516;
extern s1516 GamutMatrixValue(double value);

typedef struct {
    union {
        s1516 matrix[3][3];
    } content;
} IOMobileFramebufferGamutMatrix;

typedef NS_ENUM(uint32_t, IOMobileFramebufferBrightnessCorrectionValue) {
    IOMobileFramebufferBrightnessCorrectionReducedWhitepointValue = 57344,
    IOMobileFramebufferBrightnessCorrectionDefaultValue = 65535
};

@interface IOMobileFramebufferClient : NSObject

@property (nonatomic, readonly) IOMobileFramebufferConnection framebufferConnection;

+ (instancetype)sharedInstance;

- (IOMobileFramebufferColorRemapMode)colorRemapMode;
- (void)setColorRemapMode:(IOMobileFramebufferColorRemapMode)mode;

- (void)setBrightnessCorrection:(IOMobileFramebufferBrightnessCorrectionValue)correction;
- (void)resetBrightnessCorrection;

- (void)gamutMatrix:(IOMobileFramebufferGamutMatrix *)matrix;
- (void)setGamutMatrix:(IOMobileFramebufferGamutMatrix *)matrix;
- (void)gammaTable:(IOMobileFramebufferGammaTable *)table;
- (void)setGammaTable:(IOMobileFramebufferGammaTable *)table;

@end

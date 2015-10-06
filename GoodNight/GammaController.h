//
//  GammaController.h
//  GoodNight
//
//  Created by Anthony Agatiello on 6/22/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GammaController : NSObject

typedef struct __IOMobileFramebuffer *IOMobileFramebufferConnection;
typedef kern_return_t IOMobileFramebufferReturn;

+ (void)setGammaWithRed:(float)red green:(float)green blue:(float)blue;
+ (void)setGammaWithOrangeness:(float)percentOrange;

@end
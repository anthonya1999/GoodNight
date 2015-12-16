//
//  MobileGestaltClient.h
//  GoodNight
//
//  Created by Mario Korte on 11.12.2015.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

static void *MobileGestaltClientHandle = NULL;
static CFStringRef HWModelString = NULL;

#define LMG_PATH "/usr/lib/libMobileGestalt.dylib"

@interface MobileGestaltClient : NSObject

+ (instancetype)sharedInstance;

- (CFStringRef)MGGetHWModelStr;

@end
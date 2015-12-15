//
//  SpringBoardServicesClient.h
//  GoodNight
//
//  Created by Mario Korte on 11.12.2015.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

static void *SpringBoardServicesHandle = NULL;
typedef kern_return_t SpringBoardServicesReturn;

@interface SpringBoardServicesClient : NSObject

@property (nonatomic, readonly) mach_port_t sbsMachPort;

+ (instancetype)sharedInstance;
- (BOOL)SBGetScreenLockStatusIsLocked;
- (BOOL)SBGetScreenLockStatusIsPasscodeEnabled;
- (void)SBSuspend;
- (void)SBSUndimScreen;

@end
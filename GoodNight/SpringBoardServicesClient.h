//
//  SpringBoardServicesClient.h
//  GoodNight
//
//  Created by Mario Korte on 11.12.2015.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpringBoardServicesClient : NSObject

+ (instancetype)sharedSpringBoardServicesClient;

- (BOOL)SBGetScreenLockStatusIsLocked;
- (BOOL)SBGetScreenLockStatusIsPasscodeEnabled;
- (void)SBSuspend;
- (void)SBSUndimScreen;

@end

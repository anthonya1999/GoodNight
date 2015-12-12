//
//  MobileGestaltClient.m
//  GoodNight
//
//  Created by Mario Korte on 11.12.2015.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import <dlfcn.h>
#import "MobileGestaltClient.h"

#define LMG_PATH "/usr/lib/libMobileGestalt.dylib"

@implementation MobileGestaltClient

static void *MobileGestaltClientHandle = NULL;
+ (void)initialize {
    [super initialize];

    MobileGestaltClientHandle = dlopen(LMG_PATH, RTLD_GLOBAL | RTLD_LAZY);
    NSParameterAssert(MobileGestaltClientHandle);
}

+ (instancetype)sharedMobileGestaltClient {
    static dispatch_once_t onceToken = 0;
    static MobileGestaltClient *sharedMobileGestaltClient = nil;
    
    dispatch_once(&onceToken, ^{
        sharedMobileGestaltClient = [[self alloc] init];
    });
    
    return sharedMobileGestaltClient;
}

- (void)dealloc {
    dlclose(MobileGestaltClientHandle);
}

- (NSString*)callMGCopyAnswer:(NSString*)input{
    CFStringRef (*MGCopyAnswer)(CFStringRef model) = dlsym(MobileGestaltClientHandle, "MGCopyAnswer");
    NSParameterAssert(MGCopyAnswer);
    NSString *answer = CFBridgingRelease(MGCopyAnswer((__bridge CFStringRef)input));
    return answer;
}

- (NSString*)MGGetHWModelStr{
    return [self callMGCopyAnswer:@"HWModelStr"];
}

@end

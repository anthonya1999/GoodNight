//
//  MobileGestaltClient.m
//  GoodNight
//
//  Created by Mario Korte on 11.12.2015.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import <dlfcn.h>
#import "MobileGestaltClient.h"

@implementation MobileGestaltClient

+ (void)initialize {
    [super initialize];

    MobileGestaltClientHandle = dlopen(LMG_PATH, RTLD_GLOBAL | RTLD_LAZY);
    NSParameterAssert(MobileGestaltClientHandle);
}

+ (instancetype)sharedInstance {
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

- (CFStringRef)callMGCopyAnswer:(CFStringRef)input {
    CFStringRef (*MGCopyAnswer)(CFStringRef model) = dlsym(MobileGestaltClientHandle, "MGCopyAnswer");
    NSParameterAssert(MGCopyAnswer);
    CFStringRef answer = MGCopyAnswer(input);
    return answer;
}

- (CFStringRef)MGGetHWModelStr {
    if (!HWModelString) {
        HWModelString = [self callMGCopyAnswer:CFSTR("HWModelStr")];
    }
    return HWModelString;
}

@end
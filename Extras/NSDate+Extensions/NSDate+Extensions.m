//
//  NSDate+Extensions.m
//  GoodNight
//
//  Created by Anthony Agatiello on 10/13/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "NSDate+Extensions.h"

@implementation NSDate (Extensions)

- (BOOL)isEarlierThan:(NSDate *)date {
    return [self earlierDate:date] == self;
}

- (BOOL)isLaterThan:(NSDate *)date {
    return [self laterDate:date] == self;
}

@end
//
//  NSDate+Extensions.h
//  GoodNight
//
//  Created by Anthony Agatiello on 10/13/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extensions)

- (BOOL)isEarlierThan:(NSDate *)date;
- (BOOL)isLaterThan:(NSDate *)date;

@end
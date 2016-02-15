//
//  Brightness.h
//  GoodNight
//
//  Created by Anthony Agatiello on 6/22/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#ifndef brightness_h
#define brightness_h

#include <stdio.h>
#include "Solar.h"

#define TRANSITION_LOW     SOLAR_CIVIL_TWILIGHT_ELEV
#define TRANSITION_HIGH    3.0

float calculate_interpolated_value(double elevation, float day, float night);

#endif /* brightness_h */


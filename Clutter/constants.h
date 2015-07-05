//
//  constants.h
//  Clutter
//
//  Created by Andy Locascio on 7/3/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#ifndef Clutter_constants_h
#define Clutter_constants_h

#define clRGBA(r,g,b,a) colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a
#define clRGB(r,g,b) clRGBA(r,g,b,1.0)

// global colors
#define clBackground clRGB(31, 35, 41)
#define clBackgroundAccentMedium clRGB(40, 45, 50)
#define clBackgroundAccentLight clRGB(51, 55, 60)
#define clBackgroundAccentLighter clRGB(61, 65, 70)

#define clBackgroundAccentDark clRGB(27, 30, 36)
#define clTextGray clRGB(153, 154, 157)
#define clTextWhite clRGB(235, 236, 239)


#define clBlue clRGB(24, 52, 102)

#endif

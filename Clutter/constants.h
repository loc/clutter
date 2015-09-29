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
#define clBackground clRGB(206, 209, 214)
#define clBackgroundAccentMedium clRGBA(50, 50, 50, 0.7)
#define clBackgroundAccentLight clRGBA(50, 50, 50, 0.7)
#define clBackgroundAccentLighter clRGBA(100, 100, 100, 0.05)

#define clBackgroundAccentDark clRGB(223, 225, 228)
#define clBackgroundAccentDarker clRGBA(70, 70, 75, .7)
#define clTextGray clRGB(55, 60, 73)
#define clTextWhite clRGB(235, 236, 239)

#define clMainText clRGB(55, 60, 73)
#define clHighlightedText clRGB(255, 255, 255)

//#define clBlue clRGB(24, 52, 102)
#define clBlue clRGB(93, 147, 197)
#define clColorAccent clRGB(39,51,68)

#endif

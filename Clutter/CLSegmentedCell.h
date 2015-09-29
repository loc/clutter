//
//  CLSegmentedCell.h
//  Clutter
//
//  Created by Andy Locascio on 7/5/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "constants.h"
IB_DESIGNABLE

@interface CLSegmentedCell : NSSegmentedCell

@property NSColor * deselectedColor;

+ (NSFont*) cellFont;

@end

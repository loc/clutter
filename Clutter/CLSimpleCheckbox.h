//
//  CLSimpleCheckbox.h
//  Clutter
//
//  Created by Andy Locascio on 9/30/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "constants.h"
@import QuartzCore;

@interface CLSimpleCheckbox : NSButton

@end

@interface CLSimpleCheckboxCell : NSButtonCell

@property () CAShapeLayer * checkLayer;
- (void) setupLayer;

@end

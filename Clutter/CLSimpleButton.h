//
//  CLSimpleButton.h
//  Clutter
//
//  Created by Andy Locascio on 9/27/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "constants.h"

@interface CLSimpleButton : NSButton

- (void) setEnabled:(BOOL)enabled;

@end

#define CL_INACTIVE 0
#define CL_HOVER 1
#define CL_ACTIVE 2
#define CL_DISABLED 3

@interface CLSimpleButtonCell : NSButtonCell

@property () BOOL isEnabled;
@property () BOOL isMouseInside;

@end

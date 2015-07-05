//
//  CLResizeView.h
//  Clutter
//
//  Created by Andy Locascio on 7/3/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "constants.h"
IB_DESIGNABLE

@interface CLResizeView : NSView {
    long startY;
    long startHeight;
    long startBottom;
}

@property BOOL isPressed;
@property NSTrackingArea * trackingArea;
@property IBInspectable NSSize handleSize;
@property IBInspectable NSInteger handleTween;


@end

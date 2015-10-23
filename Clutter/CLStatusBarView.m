//
//  CLStatusBarView.m
//  Clutter
//
//  Created by Andy Locascio on 9/30/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import "CLStatusBarView.h"

@implementation CLStatusBarView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    if (self.isActive) {
        [[NSColor clBlue] setFill];
    } else {
        [[NSColor clRGBA(0,0,0,.1)] setFill];
    }
    NSRectFill(dirtyRect);
    
    // Drawing code here.
}

- (void)mouseDown:(NSEvent *)event {
    [self setMouseDown:YES];
    [self setActive:![self isActive]];
    [self setNeedsDisplay:YES];
    [[self target] performSelector:_action withObject:[NSNumber numberWithBool:self.isActive]];
}

- (void) rightMouseDown:(NSEvent *)theEvent {
    
}
- (void) mouseUp:(NSEvent *)theEvent {
    [self setMouseDown:NO];
    [self setNeedsDisplay:YES];
}

@end

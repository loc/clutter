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
        NSRectFill(dirtyRect);
    }
    
    NSRect imageRect;
    imageRect.size = self.image.size;
    imageRect.origin.x = self.bounds.size.width - self.image.size.width;
    imageRect.origin.y = self.bounds.size.height - self.image.size.height;
    
    imageRect.origin.x -= 2;
    
    [(self.isActive ? self.altImage : self.image) drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    
    // Drawing code here.
}

- (void)mouseDown:(NSEvent *)event {
    [self setMouseDown:YES];
    [self setActive:![self isActive]];
    [self setNeedsDisplay:YES];
    [[self target] performSelector:_action withObject:[NSNumber numberWithBool:NO]];
}

- (void) rightMouseDown:(NSEvent *)theEvent {
    [[self target] performSelector:_action withObject:[NSNumber numberWithBool:YES]];
}
- (void) mouseUp:(NSEvent *)theEvent {
    [self setMouseDown:NO];
    [self setNeedsDisplay:YES];
}

@end

//
//  CLResizeView.m
//  Clutter
//
//  Created by Andy Locascio on 7/3/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import "CLResizeView.h"




@implementation CLResizeView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        //self.autoresizingMask = NSViewWidthSizable |  NSViewHeightSizable;
        //self.mouseDownCanMoveWindow = NO;
        self.isPressed = NO;
        _trackingArea = [[NSTrackingArea alloc] initWithRect: self.bounds
                                                    options: (NSTrackingActiveInKeyWindow | NSTrackingCursorUpdate)
                                                      owner: self
                                                   userInfo: nil];
        [self addTrackingArea:_trackingArea];
    }
    return self;
}

- (BOOL) mouseDownCanMoveWindow {
    return NO;
}

- (void)drawRect:(NSRect)dirtyRect
{
    
    // draw background
    NSColor *fill = self.isPressed ? [NSColor clBackgroundAccentMedium] : [NSColor clBackgroundAccentDark];
    [fill setFill];
    NSRectFill(self.bounds);
    
    // draw handles
    [self drawHandles];
}

- (void) cursorUpdate:(NSEvent *)event {
    [[NSCursor resizeUpDownCursor] set];
}

- (void) mouseDown:(NSEvent *)theEvent {
    self.isPressed = YES;
    [self setNeedsDisplay:YES];
    self->startY = [NSEvent mouseLocation].y;
    self->startHeight = self.window.frame.size.height;
    self->startBottom = self.window.frame.origin.y;
    //[[NSCursor resizeUpDownCursor] set];
}
- (void) mouseUp:(NSEvent *)theEvent {
    self.isPressed = NO;
    [self setNeedsDisplay:YES];
    //[[NSCursor currentSystemCursor] set];
}

- (void) mouseDragged:(NSEvent*) event {
    NSRect windowFrame = [[self window] frame];
    long diff = (self->startY - [NSEvent mouseLocation].y);
    
    if (self->startHeight + diff < 150) {
        diff = 150 - self->startHeight;
    }
    
    windowFrame.size.height = self->startHeight + diff;
    windowFrame.origin.y = self->startBottom - diff;
    //windowFrame.origin
    [[self window] setFrame:windowFrame display:YES];
    //[[NSCursor resizeUpDownCursor] set];
}

- (void) drawHandles {
    NSRect container = [self bounds];
    NSRect topHandle, bottomHandle;
    NSSize handleSize = _handleSize;
    long tween = _handleTween;
    
    float totalHeight = (handleSize.height * 2) + tween;
    int left = floor((container.size.width - handleSize.width) / 2.0);
    int top = floor((container.size.height - totalHeight) / 2.0);
    NSPoint topOrigin = {left, top};
    NSPoint bottomOrigin = {left, top + totalHeight - handleSize.height};
    
    topHandle.origin = topOrigin;
    bottomHandle.origin = bottomOrigin;
    
    topHandle.size = bottomHandle.size = handleSize;
    NSRect handles[] = {topHandle, bottomHandle};
    NSColor *fill = self.isPressed ? [NSColor clBackgroundAccentLighter] : [NSColor clBackgroundAccentLight];
    [fill setFill];
    NSRectFillList(handles, 2);
}


@end

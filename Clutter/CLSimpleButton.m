//
//  CLSimpleButton.m
//  Clutter
//
//  Created by Andy Locascio on 9/27/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import "CLSimpleButton.h"

bool mouseInside = false;
bool isEnabled = false;

@implementation CLSimpleButton

+ (Class)cellClass {
    return [CLSimpleButtonCell class];
}
- (void)updateTrackingAreas {
    
}

- (void) setEnabled:(BOOL)enabled {
    [_cell setIsEnabled:enabled];
    [self setNeedsDisplay];
}

@end

@implementation CLSimpleButtonCell

- (BOOL)showsBorderOnlyWhileMouseInside {
    return YES;
}

- (void)mouseEntered:(NSEvent *)event {
    [self setIsMouseInside:true];
    [[self controlView] setNeedsDisplay:YES];
}
- (void)mouseExited:(NSEvent *)event {
    [self setIsMouseInside:false];
    [[self controlView] setNeedsDisplay:YES];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView withState: (NSUInteger)state {
    NSColor *borderColor, *textColor, *backgroundColor;
    NSBezierPath* path = [NSBezierPath alloc];

    borderColor = [NSColor whiteColor];
    textColor = [NSColor whiteColor];
    backgroundColor = [NSColor clRGBA(0,0,0,.05)];
    
    //clear
    [[NSColor clBlue] setFill];
    NSRectFill(cellFrame);
    
    if (state == CL_INACTIVE) {
        // pass
    } else if (state == CL_ACTIVE) {
        backgroundColor = [NSColor clRGBA(0,0,0,.2)];
    } else if (state == CL_HOVER) {
        backgroundColor = [NSColor clRGBA(0,0,0,.1)];
    } else if (state == CL_DISABLED) {
        borderColor = [NSColor clRGBA(255,255,255,.43)];
        textColor = [NSColor clRGBA(255,255,255,.43)];
        backgroundColor = [NSColor clearColor];
    }
    
    [path appendBezierPathWithRoundedRect: cellFrame xRadius:5.0 yRadius:5.0];
    [path setClip];
    
    [borderColor setStroke];
    [backgroundColor setFill];
    [path fill];
    [path setLineWidth:2.0];
    [path stroke];
    
    NSMutableParagraphStyle* pStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [pStyle setAlignment:NSCenterTextAlignment];
    [pStyle setLineSpacing:0];
    NSFont* font = [NSFont fontWithName:@"Seravek" size:15.0];
    NSDictionary* attrs = @{ NSFontAttributeName: font,
                             NSForegroundColorAttributeName: textColor,
                             NSParagraphStyleAttributeName: pStyle
                             };
    CGSize size = [self.title sizeWithAttributes:attrs];
    NSRect text;
    text.size = size;
    text.origin.x = floor((cellFrame.size.width - size.width) / 2);
    text.origin.y = floor((cellFrame.size.height - size.height) / 2) - 2;
    
    [self.title drawInRect:text withAttributes:attrs];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    int state;
    state = [self isMouseInside] ? CL_HOVER : CL_INACTIVE;
    if (![self isEnabled]) state = CL_DISABLED;
    [self drawWithFrame:cellFrame inView:controlView withState: state];
}
- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    if (flag && [self isEnabled]) {
        [self drawWithFrame:cellFrame inView:controlView withState: CL_ACTIVE];
    }
}

@end

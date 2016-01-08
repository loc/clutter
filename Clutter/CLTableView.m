//
//  CLTableView.m
//  Clutter
//
//  Created by Andy Locascio on 11/13/15.
//  Copyright © 2015 Bubble Tea Apps. All rights reserved.
//

#import "CLTableView.h"
#import "constants.h"

@implementation CLTableView

//- (BOOL)resignFirstResponder {

//    return NO;
//}

@end

@implementation CLTableContainerView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end

@implementation CLTableRowView

- (void)drawSelectionInRect:(NSRect)dirtyRect {
    [[NSColor clBlue] setFill];
    NSRectFill(self.bounds);
}

@end

@implementation CLTableCellView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self.textField setTextColor:[NSColor clRGB(72, 74, 78)]];
        [self.textField setFont:[NSFont fontWithName:@"Seravek-Light" size:15.0]];
    }
    
    return self;
}


- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
    [super setBackgroundStyle:backgroundStyle];
    
    id view = [self superview];
    
    while (view && [view isKindOfClass:[NSTableRowView class]] == false) {
        view = [self superview];
    }
    
    if ([(NSTableRowView*)view isSelected]) {
        [self.textField setTextColor:[NSColor clRGB(212, 214, 218)]];
    } else {
        [self.textField setTextColor:[NSColor clRGB(72, 74, 78)]];
    }
}

@end

@implementation CLTableHeaderView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

@end

@implementation CLTableHeaderCell

- (instancetype)initTextCell:(NSString *)aString {
    self = [super initTextCell:aString];
    [self setTextColor:[NSColor clRGB(80, 80, 80)]];
    
    [self setFont:[NSFont fontWithName:@"Seravek-Light" size:12.0]];
    return self;
}

- (void) drawWithFrame: (CGRect) cellFrame
           highlighted: (BOOL) isHighlighted
                inView: (NSView*) view {
    [[NSColor clRGB(190,192,194)] setFill];
    NSRectFill(cellFrame);
    [self drawInteriorWithFrame:cellFrame inView:view];
    
    NSBezierPath* sep = [[NSBezierPath alloc] init];
    [sep moveToPoint:NSMakePoint(cellFrame.origin.x + cellFrame.size.width - .5, 4)];
    [sep lineToPoint:(NSPoint){cellFrame.origin.x + cellFrame.size.width - .5, cellFrame.size.height - 4}];
    
    [[NSColor clRGB(170,170,170)] setStroke];
    [sep stroke];
    
    NSBezierPath* bottom = [[NSBezierPath alloc] init];
    [bottom moveToPoint:(NSPoint){cellFrame.origin.x, 0}];
    [bottom lineToPoint:(NSPoint){cellFrame.origin.x + cellFrame.size.width, 0}];
    [bottom stroke];
    
    NSBezierPath* top = [[NSBezierPath alloc] init];
    [top moveToPoint:(NSPoint){cellFrame.origin.x, cellFrame.size.height}];
    [top lineToPoint:(NSPoint){cellFrame.origin.x + cellFrame.size.width, cellFrame.size.height}];
    [top stroke];
    
    
}

- (NSRect)titleRectForBounds:(NSRect)theRect {
    NSSize size = [[self attributedStringValue] size];
    NSRect titleRect = [super titleRectForBounds:theRect];
    
    titleRect.origin.x += 8;
    titleRect.origin.y = theRect.origin.y + (theRect.size.height - size.height) / 2.0;
    
    // stupid font
    titleRect.origin.y -= 2;
    
    return titleRect;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSRect titleFrame = [self titleRectForBounds:cellFrame];
    [[self attributedStringValue] drawInRect:titleFrame];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    [self drawWithFrame:cellFrame highlighted:NO inView:controlView];
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    [self drawWithFrame:cellFrame highlighted:YES inView:controlView];
}

@end
//
//  CLPanel.m
//  
//
//  Created by Andy Locascio on 10/4/15.
//
//

#import "CLPanel.h"
#import "AppDelegate.h"

@implementation CLPanel

- (instancetype) initWithContentSize: (NSSize)size relativeToPoint:(NSPoint)point {
    self = [super initWithContentRect:NSMakeRect(1, 1, 1, 1) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    
    _point = point;
    _size = size;
    
    NSRect windowRect = [self windowRectGivenContentSize:size];
    NSRect contentRect = (NSRect){.size=size};
    NSRect arrowRect;
    arrowRect.size = NSMakeSize(windowRect.size.width, windowRect.size.height - contentRect.size.height);
    arrowRect.origin = NSMakePoint(0, contentRect.size.height);
    
    [self setFrame:windowRect display:YES];
    self.panelView = [[CLPanelView alloc] initWithFrame:contentRect];
    self.arrowView = [[CLArrowView alloc] initWithFrame:arrowRect];
    
    [self setAlphaValue:1.0];
    [self setOpaque:NO];
    [self setHasShadow:YES];
    [self setBackgroundColor:[NSColor clearColor]];
    
    [self.contentView addSubview:self.panelView];
    [self.contentView addSubview:self.arrowView];
    
    return self;
}

- (void)reposition {
    [self setFrame:[self windowRectGivenContentSize:_size] display:YES];
}

- (NSRect) windowRectGivenContentSize:(NSSize) contentSize {
    NSRect containerFrame;
    float arrowHeight = 20;
    
    containerFrame.size.height = contentSize.height + arrowHeight;
    containerFrame.size.width = contentSize.width;
    containerFrame.origin.y = _point.y - contentSize.height;
    containerFrame.origin.x = _point.x - (contentSize.width / 2);
    
    return containerFrame;
}

- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (BOOL)canBecomeMainWindow {
    return YES;
}

@end


@implementation CLPanelView

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer = _layer;
        self.wantsLayer = YES;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 6;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor clBackground] setFill];
    NSRectFill(dirtyRect);
}
- (void)mouseDown:(NSEvent *)theEvent {
    AppDelegate* appDelegate = [NSApp delegate];
    [appDelegate.window makeFirstResponder:nil];
}

- (BOOL)isFlipped {
    return true;
}

@end

@implementation CLArrowView

- (void)drawRect:(NSRect)dirtyRect {
    NSBezierPath * path = [[NSBezierPath alloc] init];
    
    float arrowWidth = 26;
    float xMid = dirtyRect.size.width / 2;
    float xMin = xMid - (arrowWidth / 2);
    float xMax = xMin + arrowWidth;
    
    [path moveToPoint:(NSPoint){xMin, 0}];
    [path lineToPoint:(NSPoint){xMid, dirtyRect.size.height - 5}];
    [path lineToPoint:(NSPoint){xMax, 0}];
    [path lineToPoint:(NSPoint){xMin, 0}];
    
    [[NSColor clBackground] setFill];
    [path fill];
}

@end


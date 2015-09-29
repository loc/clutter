//
//  CLFileActionView.m
//  Clutter
//
//  Created by Andy Locascio on 9/17/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import "CLFileActionView.h"

@implementation CLFileActionView

- (instancetype)initWithFrame:(NSRect)frameRect andTitle:(NSString*) title {
    self = [super initWithFrame:frameRect];
    _values = nil;
    _hasFolderPicker = NO;

    int controlHeight = 30;
    
    CGSize triangleSize = NSMakeSize(8.0, 5.0);
    CGPoint triangleOrigin = NSMakePoint(frameRect.size.width - 30 - triangleSize.width / 2, (frameRect.size.height - triangleSize.height) / 2);
    
    triangleFrame = NSMakeRect(triangleOrigin.x, triangleOrigin.y, triangleSize.width, triangleSize.height);
    
    _backgroundColor = [NSColor clearColor];
    
    _choiceControl = [[CLSegmentedControl alloc] initWithFrame:NSMakeRect(110, (frameRect.size.height - controlHeight) / 2, 325, controlHeight)];
    [self addSubview:_choiceControl];
    [_choiceControl setTarget:self];
    [_choiceControl setAction:@selector(tabSwitched)];

    NSDictionary* fontDict = @{NSFontAttributeName: [NSFont fontWithName:@"Seravek-Medium" size:18],
                               NSForegroundColorAttributeName: [NSColor clRGB(80, 81, 82)]
                               };
    _titleLabel = [[NSTextField alloc] init];
    [_titleLabel setEditable:NO];
    [_titleLabel setDrawsBackground:NO];
    [_titleLabel setSelectable:NO];
    [_titleLabel setBezeled:NO];
    [self addSubview:_titleLabel];
    NSAttributedString* styledTitle = [[NSAttributedString alloc] initWithString:title attributes:fontDict];
    [_titleLabel setAttributedStringValue:styledTitle];
    [_titleLabel sizeToFit];
    [_titleLabel setFrameOrigin:NSMakePoint(90 - _titleLabel.frame.size.width, (frameRect.size.height - _titleLabel.frame.size.height) / 2)];
    
    self->lastSelected = -1;

    return self;
}
//- (instancetype)initWithFrame:(NSRect)frameRect {
//    self = [super initWithFrame:frameRect];
//    _choiceControl = [[CLSegmentedControl alloc] initWithFrame:NSMakeRect(0, 0, 180, 30)];
//    [self addSubview:_choiceControl];
//    return self;
//}
- (void) setHasFolderPicker:(BOOL)hasFolderPicker {
    _hasFolderPicker = hasFolderPicker;
}

- (void) clearSelection {
    [_choiceControl setSelectedSegment:-1];
}

- (void) triggerDialog {
    NSOpenPanel* panel = [[NSOpenPanel alloc] init];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setPrompt:@"Pick a folder"];
    if ([panel runModal] == NSOKButton) {
        NSLog(@"%@", [panel directoryURL]);
    }
}

- (void)mouseDown:(NSEvent *)theEvent {
    BOOL inside = NSPointInRect([self convertPoint:[theEvent locationInWindow] fromView:nil], triangleFrame);
    if (inside && _hasFolderPicker) {
        [self triggerDialog];
    }
}

- (void) setLabels: (NSArray*) labels {
    [_choiceControl setLabels:labels];
}
- (void) tabSwitched {
    if ([_choiceControl selectedSegment] == self->lastSelected) {
        [_choiceControl setSelectedSegment:-1];
        self->lastSelected = -1;
    }
    else {
        self->lastSelected = [_choiceControl selectedSegment];
    }
    
//    if (_action != nil && _target != nil) {
//        //[_target performSelector:_action withObject:nil];
//    }
    NSString* label;
    if (lastSelected == -1) {
        label = nil;
    } else {
        label = [_choiceControl labelForSegment:lastSelected];
    }
    [_delegate actionChanged:label from:self];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [_backgroundColor setFill];
    NSRectFill(dirtyRect);
    
    if (_hasFolderPicker) {
        // draw carot
        float yStart = triangleFrame.origin.y;
        float yEnd = yStart + triangleFrame.size.height;
        float xStart = triangleFrame.origin.x;
        float xMid = xStart + triangleFrame.size.width / 2;
        float xEnd = xStart + triangleFrame.size.width;
        
        NSBezierPath * triangle = [[NSBezierPath alloc] init];
        [triangle moveToPoint:NSMakePoint(xStart, yStart)];
        [triangle lineToPoint:NSMakePoint(xEnd, yStart)];
        [triangle lineToPoint:NSMakePoint(xMid, yEnd)];
        [triangle lineToPoint:NSMakePoint(xStart, yStart)];
        
        [[NSColor clRGBA(0,0,0,.5)] setFill];
        [triangle fill];
    }
    
    
}

-(BOOL)isFlipped {
    return YES;
}
@end
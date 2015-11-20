//
//  CLFileActionView.m
//  Clutter
//
//  Created by Andy Locascio on 9/17/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import "CLFileActionView.h"

@implementation CLFileActionView

- (instancetype)initWithTitle:(NSString*) title {
    self = [super init];
    _values = nil;
    _hasFolderPicker = NO;

    int controlHeight = 30;
    
//    CGSize triangleSize = NSMakeSize(8.0, 5.0);
//    CGPoint triangleOrigin = NSMakePoint(frameRect.size.width - 30 - triangleSize.width / 2, (frameRect.size.height - triangleSize.height) / 2);
//    
//    triangleFrame = NSMakeRect(triangleOrigin.x, triangleOrigin.y, triangleSize.width, triangleSize.height);
    
    _backgroundColor = [NSColor clearColor];
    
    _choiceControl = [[CLSegmentedControl alloc] init];
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
    
    [_titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_choiceControl setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:_titleLabel];
    [self addSubview:_choiceControl];
    
    NSAttributedString* styledTitle = [[NSAttributedString alloc] initWithString:title attributes:fontDict];
    [_titleLabel setAttributedStringValue:styledTitle];
    [_titleLabel sizeToFit];
    
    self->lastSelected = -1;
    
    NSDictionary* views = @{@"title": _titleLabel,
                            @"choice": _choiceControl};
    NSMutableArray* constraints = [[NSMutableArray alloc] init];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[title(50)]-30-[choice]-30-|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[title]-|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[choice(==28)]" options:0 metrics:nil views:views]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem: _choiceControl
                                                        attribute: NSLayoutAttributeCenterY
                                                        relatedBy: NSLayoutRelationEqual
                                                           toItem: self
                                                        attribute: NSLayoutAttributeCenterY
                                                       multiplier: 1 constant:0]];
    
    [NSLayoutConstraint activateConstraints:constraints];

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
    self->lastSelected = -1;
    [_choiceControl setSelectedSegment:-1];
}

- (id) getSelectedValue {
     return [_values objectAtIndex:[_choiceControl selectedSegment]];
}
- (BOOL) isSelected {
    return [_choiceControl selectedSegment] > -1;
}

- (void) triggerDialog {
    NSOpenPanel* panel = [[NSOpenPanel alloc] init];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setPrompt:@"Pick a folder"];
    [(AppDelegate*)[NSApp delegate] watchForKeyWindowChange:NO];
    if ([panel runModal] == NSModalResponseOK) {
        NSMutableArray* labels = [NSMutableArray arrayWithArray:[_choiceControl labels]];
        NSMutableArray* values = [NSMutableArray arrayWithArray:[self values]];
        [self clearSelection];
        [labels replaceObjectAtIndex:[labels count] - 1 withObject:[[panel URL] lastPathComponent]];
        [values replaceObjectAtIndex:[values count] - 1 withObject:[panel URL]];
        [self setLabels:labels andValues:values];
        [_choiceControl setSelectedSegment:[labels count] - 1];
        // trigger the callback manual  ly
        [self tabSwitched];
    }
    [(AppDelegate*)[NSApp delegate] watchForKeyWindowChange:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
    BOOL inside = NSPointInRect([self convertPoint:[theEvent locationInWindow] fromView:nil], triangleFrame);
    if (inside && _hasFolderPicker) {
        [self triggerDialog];
    }
    [super mouseDown:theEvent];
}

- (void) setLabels:(NSArray*)labels andValues: (NSArray*) values {
    [_choiceControl setLabels:labels];
    _values = values;
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
    if (self->lastSelected == -1) {
        label = nil;
    } else {
        label = [_choiceControl labelForSegment:self->lastSelected];
    }
    [_delegate actionChanged:label from:self];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [_backgroundColor setFill];
    NSRectFill(dirtyRect);
    
    if (_hasFolderPicker) {
        // draw carot
//        float yStart = triangleFrame.origin.y;
//        float yEnd = yStart + triangleFrame.size.height;
//        float xStart = triangleFrame.origin.x;
//        float xMid = xStart + triangleFrame.size.width / 2;
//        float xEnd = xStart + triangleFrame.size.width;
//        
//        NSBezierPath * triangle = [[NSBezierPath alloc] init];
//        [triangle moveToPoint:NSMakePoint(xStart, yStart)];
//        [triangle lineToPoint:NSMakePoint(xEnd, yStart)];
//        [triangle lineToPoint:NSMakePoint(xMid, yEnd)];
//        [triangle lineToPoint:NSMakePoint(xStart, yStart)];
//        
//        [[NSColor clRGBA(0,0,0,.5)] setFill];
//        [triangle fill];
    }
}

-(BOOL)isFlipped {
    return YES;
}
@end
//
//  CLActionConfirmView.m
//  Clutter
//
//  Created by Andy Locascio on 9/27/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import "CLActionConfirmView.h"
#import "constants.h"

@implementation CLActionConfirmView

float borderHeight = 3;

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _confirmButton = [[CLSimpleButton alloc] init];
        [_confirmButton setTitle:@"Confirm"];
        [_confirmButton setAction:@selector(confirmClicked:)];
        [_confirmButton setTarget:self];
//        [[_confirmButton cell] setBackgroundColor:[NSColor clearColor]];
        [self addSubview:_confirmButton];
        [_confirmButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        NSDictionary* views = @{@"confirm": _confirmButton};
        NSMutableArray* constraints = [[NSMutableArray alloc] init];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[confirm(100)]-20-|" options:0 metrics:nil views:views]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[confirm(34)]" options:0 metrics:nil views:views]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_confirmButton
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1
                                                             constant:0]];
        
        [NSLayoutConstraint activateConstraints:constraints];
    }
    return self;
}

- (void) enableButton: (BOOL) shouldEnable {
    [_confirmButton setEnabled:shouldEnable];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[NSColor clBlue] setFill];
    NSRectFill(dirtyRect);
    
    [[NSColor clRGB(31,51,68)] setFill];
    NSRectFill(NSMakeRect(0, 0, dirtyRect.size.width, borderHeight));
    
    // Drawing code here.
}

- (void) confirmClicked: (NSEvent*) event {
    [[self target] performSelector:_action];
}

- (BOOL)isFlipped {
    return YES;
}

@end

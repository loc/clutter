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
    CGSize buttonSize = NSMakeSize(100, 34);
    NSRect buttonRect = NSMakeRect(frame.size.width - buttonSize.width - 20, (frame.size.height - buttonSize.height + borderHeight) / 2, buttonSize.width, buttonSize.height);
    self = [super initWithFrame:frame];
    if (self) {
        _confirmButton = [[CLSimpleButton alloc] initWithFrame:buttonRect];
        [_confirmButton setTitle:@"Confirm"];
//        [[_confirmButton cell] setBackgroundColor:[NSColor clearColor]];
        [self addSubview:_confirmButton];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[NSColor clBlue] setFill];
    NSRectFill(dirtyRect);
    
    [[NSColor clRGB(31,51,68)] setFill];
    NSRectFill(NSMakeRect(0, 0, dirtyRect.size.width, borderHeight));
    
    // Drawing code here.
}
- (BOOL)isFlipped {
    return YES;
}

@end

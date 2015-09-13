//
//  CLSegmentedCell.m
//  Clutter
//
//  Created by Andy Locascio on 7/5/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import "CLSegmentedCell.h"

#define borderRadius 2.5

@implementation CLSegmentedCell

- (instancetype) init {
    self = [super init];
    
    if (!self.deselectedColor) {
        self.deselectedColor = [NSColor clBackgroundAccentMedium];
    }
    
    return self;
}

- (void) drawSegment:(NSInteger)segment inFrame:(NSRect)frame withView:(NSView *)controlView {
    
    NSRect newFrame = frame;
    NSColor * fontColor = [NSColor clRGB(158, 165, 175)];
    NSShadow * textShadow = [[NSShadow alloc] init];
    
    newFrame.origin.x += 1;
    newFrame.origin.y += 1;
    newFrame.size.height -= 1;

    NSBezierPath * path = [NSBezierPath bezierPathWithRect:NSInsetRect(newFrame, 0, 0)];
    NSBezierPath * edge = [[NSBezierPath alloc] init];
    
    if (segment == 0 || segment == self.segmentCount - 1) {
        NSPoint topLeft = NSMakePoint(newFrame.origin.x, newFrame.origin.y + newFrame.size.height);
        NSPoint topRight = NSMakePoint(newFrame.origin.x + newFrame.size.width, newFrame.origin.y + newFrame.size.height);
        NSPoint bottomRight = NSMakePoint(newFrame.origin.x + newFrame.size.width, newFrame.origin.y);
        NSPoint bottomLeft = newFrame.origin;

        if (segment == 0) {
            [edge moveToPoint:topRight];
            [edge lineToPoint:bottomRight];
            [edge appendBezierPathWithArcFromPoint:bottomLeft toPoint:topLeft radius:borderRadius];
            [edge appendBezierPathWithArcFromPoint:topLeft toPoint:topRight radius:borderRadius];
            [edge lineToPoint:topRight];
        }
        else {
            [edge moveToPoint:bottomLeft];
            [edge lineToPoint:topLeft];
            [edge appendBezierPathWithArcFromPoint:topRight toPoint:bottomRight radius:borderRadius];
            [edge appendBezierPathWithArcFromPoint:bottomRight toPoint:bottomLeft radius:borderRadius];
            [edge lineToPoint:bottomLeft];
        }
        
        path = edge;
    }
    
    if (self.selectedSegment == segment) {
        [[NSColor clBlue] set];
        fontColor = [NSColor colorWithCalibratedWhite:1.0 alpha:.8];
        textShadow.shadowColor = [NSColor blackColor];
        textShadow.shadowBlurRadius = 2.0;
        textShadow.shadowOffset = CGSizeMake(0.0, -1.0);
    }
    else {
        [self.deselectedColor set];
    }
    
    [path fill];
    
    NSFont *font = [NSFont fontWithName:@"Seravek-ExtraLight" size:14];
    NSMutableParagraphStyle * aParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [aParagraphStyle setAlignment:NSCenterTextAlignment];
    NSDictionary *attrs = @{NSForegroundColorAttributeName : fontColor,
                            NSParagraphStyleAttributeName: aParagraphStyle,
                            NSFontAttributeName: font,
                            NSShadowAttributeName: textShadow};
    
    NSRect textFrame = controlView.bounds;
    textFrame.size.width = newFrame.size.width;
    textFrame.origin.x = newFrame.origin.x;

    CGFloat height = [self heightOfString:[self labelForSegment:segment] withFont:font];
    textFrame.origin.y = (textFrame.origin.y - .5 + (textFrame.size.height - height) / 2.0) - 1;
    textFrame.size.height = height;
    
    [[self labelForSegment:segment] drawInRect:textFrame withAttributes:attrs];
    
    
}

- (CGFloat)heightOfString:(NSString *)string withFont:(NSFont *)font {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:0];
    NSDictionary *attributes = @{NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: style};
    return [[[NSAttributedString alloc] initWithString:@"___" attributes:attributes] size].height;
}


- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    [self drawInteriorWithFrame:cellFrame inView:controlView];
    NSBezierPath * outer = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(controlView.bounds, .5, .5) xRadius:3.0 yRadius:3.0];
    NSBezierPath * inner = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(controlView.bounds, 1.5, 1.5) xRadius:3.0 yRadius:3.0];
    [[NSColor colorWithCalibratedWhite:1.0 alpha:.08] set];
    [inner setLineWidth:1];
    [inner stroke];
    
    [[NSColor clBackgroundAccentDarker] set];
    [outer setLineWidth:.5];
    [outer stroke];
    
}

@end

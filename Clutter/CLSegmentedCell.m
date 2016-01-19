//
//  CLSegmentedCell.m
//  Clutter
//
//  Created by Andy Locascio on 7/5/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import "CLSegmentedCell.h"

#define borderRadius 4.0

@implementation CLSegmentedCell

- (instancetype) init {
    self = [super init];
    
    self.deselectedColor = [NSColor clearColor];
    self.deselectedTextColor = [NSColor clMainText];
    self.highlightTextColor = [NSColor clHighlightedText];
    self.highlightColor = [NSColor clBlue];
    self.highlightStrokeColor = [NSColor clColorAccent];
    self.shouldBoldHighlight = YES;
    
    return self;
}

+ (NSFont*) cellFont {
    return [NSFont fontWithName:@"Seravek-Light" size:14];
}

- (void) drawSegment:(NSInteger)segment inFrame:(NSRect)frame withView:(NSView *)controlView {
    
    NSRect newFrame = frame;
    NSColor * fontColor = self.deselectedTextColor;
    NSFont *font = [CLSegmentedCell cellFont];
    
    newFrame.origin.x += 0;
    newFrame.origin.y += 0;
    newFrame.size.height += 0;
    newFrame.size.width += 1;

    NSBezierPath * path = [NSBezierPath bezierPathWithRect:NSInsetRect(newFrame, 0, 0)];
    NSBezierPath * edge = [[NSBezierPath alloc] init];
    NSBezierPath * rightEdge = [[NSBezierPath alloc] init];
    NSPoint topLeft = NSMakePoint(newFrame.origin.x, newFrame.origin.y + newFrame.size.height);
    NSPoint topRight = NSMakePoint(newFrame.origin.x + newFrame.size.width, newFrame.origin.y + newFrame.size.height);
    NSPoint bottomRight = NSMakePoint(newFrame.origin.x + newFrame.size.width, newFrame.origin.y);
    NSPoint bottomLeft = NSMakePoint(newFrame.origin.x, newFrame.origin.y);
    
    [[NSColor yellowColor] setFill];
//    [path fill];
    
    [rightEdge moveToPoint:NSMakePoint(topRight.x, topRight.y)];
    [rightEdge lineToPoint:NSMakePoint(bottomRight.x, bottomRight.y)];
    
    if (segment == 0 || segment == self.segmentCount - 1) {
        if (segment == 0) {
            [edge moveToPoint:topRight];
            [edge lineToPoint:bottomRight];
            [edge appendBezierPathWithArcFromPoint:bottomLeft toPoint:topLeft radius:borderRadius];
            [edge appendBezierPathWithArcFromPoint:topLeft toPoint:topRight radius:borderRadius];
            [edge lineToPoint:topRight];
        }
        else {
            bottomRight.x += 1.5;
            topRight.x += 1.5;
            [edge moveToPoint:bottomLeft];
            [edge lineToPoint:topLeft];
            [edge appendBezierPathWithArcFromPoint:topRight toPoint:bottomRight radius:borderRadius];
            [edge appendBezierPathWithArcFromPoint:bottomRight toPoint:bottomLeft radius:borderRadius];
            [edge lineToPoint:bottomLeft];
        }
        
        path = edge;
    }
    
    if (segment < self.segmentCount - 1) {
        [[NSColor clRGBA(0,0,0,.3)] setStroke];
//       [path setClip];
        [path setLineWidth:1];
        [rightEdge stroke];
    }
    
    if (self.selectedSegment == segment) {
        [self.highlightColor set];
        fontColor = self.highlightTextColor;
        if (self.shouldBoldHighlight) {
            font = [NSFont fontWithName:@"Seravek-Medium" size:14];
        } else {
            font = [CLSegmentedCell cellFont];
        }
        
        [path fill];
        
        // Set the shown path as the clip
        [path setClip];
        [path setLineWidth:2];
        [self.highlightStrokeColor setStroke];
        [path stroke];
    }
    else {
        [self.deselectedColor setFill];
        [path fill];
    }
    
    
    
    NSMutableParagraphStyle * aParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [aParagraphStyle setAlignment:NSCenterTextAlignment];
    NSDictionary *attrs = @{NSForegroundColorAttributeName : fontColor,
                            NSParagraphStyleAttributeName: aParagraphStyle,
                            NSFontAttributeName: font};
    
    NSRect textFrame = controlView.bounds;
    textFrame.size.width = newFrame.size.width;
    textFrame.origin.x = newFrame.origin.x;

    CGFloat height = [self heightOfString:[self labelForSegment:segment] withFont:font];
    textFrame.origin.y = (textFrame.origin.y - .5 + (textFrame.size.height - height) / 2.0);
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
//    [inner stroke];
    
    [[NSColor clRGBA(0,0,0,.2)] set];
    [outer setLineWidth:1];
    [outer stroke];
    
}

@end

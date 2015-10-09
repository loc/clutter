//
//  CLSimpleCheckbox.m
//  Clutter
//
//  Created by Andy Locascio on 9/30/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import "CLSimpleCheckbox.h"

@implementation CLSimpleCheckbox

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    self.layer = [CALayer layer];
    self.wantsLayer = YES;
    self.layer.delegate = self;
    self.layer.frame = frameRect;
    
    [[self cell] setupLayer];
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    [super drawLayer:layer inContext:ctx];
}

+ (Class)cellClass {
    return [CLSimpleCheckboxCell class];
}

- (NSViewLayerContentsRedrawPolicy)layerContentsRedrawPolicy {
    return NSViewLayerContentsRedrawOnSetNeedsDisplay;
}

@end


@implementation CLSimpleCheckboxCell

- (instancetype)init {
    self = [super init];
    

    
    return self;
}

- (void) setupLayer {
    CGMutablePathRef check = CGPathCreateMutable();
    _checkLayer = [CAShapeLayer layer];
    
    CGPathMoveToPoint(check, nil, 10, 12);
    CGPathAddLineToPoint(check, nil, 10, 0);
    CGPathAddLineToPoint(check, nil, 7, 0);
    CGPathAddLineToPoint(check, nil, 7, 9);
    CGPathAddLineToPoint(check, nil, 3, 9);
    CGPathAddLineToPoint(check, nil, 3, 12);
    CGPathCloseSubpath(check);
    
    _checkLayer.path = check;
    _checkLayer.fillColor = [NSColor clRGB(68, 68, 68)].CGColor;
    _checkLayer.frame = CGRectMake(0, ([self.controlView frame].size.height - 14) / 2, 14, 14);
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DTranslate(transform, -.5, 0, 0);
    transform = CATransform3DRotate(transform, 45.0 / 180.0 * M_PI, 0.0, 0.0, 1.0);
    transform = CATransform3DScale(transform, .75, .75, 1);
    
//    _checkLayer.transform = CATransform3DMakeRotation(45.0 / 180.0 * M_PI, 0.0, 0.0, 1.0);
    _checkLayer.transform = transform;
    _checkLayer.delegate = self;
    [self.controlView.layer addSublayer:_checkLayer];
}


- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
//    [[NSColor clearColor] set];
//    [[NSColor greenColor] set];
//    NSRectFill(cellFrame);
    NSBezierPath* box = [[NSBezierPath alloc] init];
    NSRect textRect;
    
    textRect.origin = NSMakePoint(23, -2);
    textRect.size = cellFrame.size;
    textRect.size.width -= 23;
    
    [box appendBezierPathWithRoundedRect:NSMakeRect(0, (cellFrame.size.height - 14) / 2, 14, 14) xRadius:2. yRadius:2.0];
    
    if ([self state]) {
        [_checkLayer setHidden:NO];
    } else {
        [_checkLayer setHidden:YES];
    }
    [[NSColor clRGB(249,250,250)] setFill];
    [box fill];
    
    [self.title drawInRect:textRect withAttributes:@{NSFontAttributeName: [NSFont fontWithName:@"Seravek-Light" size:16],
                                                     NSKernAttributeName: @1.0,
                                                     NSForegroundColorAttributeName: [NSColor clMainText]}];
}
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    [super drawLayer:layer inContext:ctx];
}

@end
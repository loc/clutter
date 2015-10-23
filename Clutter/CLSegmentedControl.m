//
//  CLSegmentedControl.m
//  Clutter
//
//  Created by Andy Locascio on 7/5/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import "CLSegmentedControl.h"

@implementation CLSegmentedControl

//- (CLSegmentedControl * ) initWithFrame:(NSRect)frameRect {
//    NSRect newFrame = frameRect;
//    newFrame.size.height = 50;
//    [self setFrame:newFrame];
//    self = [super initWithFrame:newFrame];
//    return self;
//}
- (instancetype) initWithLabels:(NSArray*) labels {
    self = [super init];
    
    return self;
}

- (void) setWidthsForLabels: (NSArray*) labels {
    __block NSUInteger totalWidth = 0;
    float padding;
    
    [labels enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        NSString* label = obj;
        NSSize size = [label sizeWithAttributes:@{NSFontAttributeName: [CLSegmentedCell cellFont]}];
        [self setWidth:size.width forSegment:index];
        totalWidth += size.width;
    }];
    
    padding = (self.frame.size.width - ([labels count] * 2) - totalWidth) / (float)[labels count];
    
    for (int i = 0; i < [labels count]; i++) {
        [self setWidth:[self widthForSegment:i] + padding forSegment:i];
    }
}

- (void) setLabels:(NSArray *)labels {
    _labels = labels;
    [self setSegmentCount:[labels count]];
    [labels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self setLabel:obj forSegment:idx];
    }];
    [self setWidthsForLabels:labels];
}

- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

//- (NSString*) getSelectedValue {
//    return [self labelForSegment:[self selectedSegment]];
//}

//- (BOOL) isSelected {
//    
//}

+ (Class)cellClass {
    return [CLSegmentedCell class];
}

//+ (NSSegmentedCell) cellClass {
//    
//}

@end

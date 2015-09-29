//
//  CLSegmentedControl.h
//  Clutter
//
//  Created by Andy Locascio on 7/5/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CLSegmentedCell.h"

@interface CLSegmentedControl : NSSegmentedControl
@property (nonatomic, retain) NSArray* labels;
- (void) setLabels:(NSArray *)labels;
@end

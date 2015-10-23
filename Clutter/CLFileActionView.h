//
//  CLFileActionView.h
//  Clutter
//
//  Created by Andy Locascio on 9/17/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CLSegmentedControl.h"
#import "AppDelegate.h"

@class CLFileActionView;

@protocol CLFileActionDelegate <NSObject>
- (void) actionChanged:(NSString*) label from:(id) sender;
@optional
- (void) folderPicked: (NSURL*) folder from:(id) sender;
@end

@interface CLFileActionView : NSView {
    NSUInteger lastSelected;
    NSRect triangleFrame;
}

@property (nonatomic, retain) CLSegmentedControl* choiceControl;
@property (nonatomic, assign) SEL action;
@property (nonatomic, assign) id <CLFileActionDelegate> delegate;
@property (nonatomic, retain) NSTextField* titleLabel;
@property (nonatomic, retain) NSColor* backgroundColor;
@property (nonatomic, retain) NSArray* values;
@property BOOL hasFolderPicker;

- (void) setLabels:(NSArray*) labels andValues:(NSArray*) values;
- (instancetype) initWithFrame:(NSRect)frameRect andTitle: (NSString *) title;
- (void) clearSelection;
- (id) getSelectedValue;
- (BOOL) isSelected;

@end

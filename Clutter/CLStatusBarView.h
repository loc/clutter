//
//  CLStatusBarView.h
//  Clutter
//
//  Created by Andy Locascio on 9/30/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "constants.h"

@interface CLStatusBarView : NSView

@property (nonatomic, assign, getter=isActive) BOOL active;
@property (nonatomic, assign, getter=isMouseDown) BOOL mouseDown;
@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL action;

@end

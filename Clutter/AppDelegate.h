//
//  AppDelegate.h
//  Clutter
//
//  Created by Andy Locascio on 6/28/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CoreWrapper.h"
#import "constants.h"
#import "CLStatusBarView.h"
#import "CLPanel.h"


@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSWindowController * controller;
    CLPanel * window;
}

@property (nonatomic, retain) NSStatusItem* statusItem;
@property (nonatomic, strong) CLStatusBarView* statusView;
@property (nonatomic, strong) NSPopover* popover;
@property (assign, getter=isActive, setter=setActive:) BOOL active;

- (void) statusItemClicked: (NSNumber*) isActive;
- (void) togglePanel: (BOOL) shouldOpen;
- (void)windowDidResignKey: (NSNotification*)event;

@end


//
//  AppDelegate.m
//  Clutter
//
//  Created by Andy Locascio on 6/28/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import "AppDelegate.h"
#import "CLMainController.h"

@implementation AppDelegate

- (void) statusItemClicked: (NSNumber*) isActiveNum {
    BOOL isActive = [isActiveNum boolValue];
    [self togglePanel:isActive];
}
- (void) togglePanel: (BOOL) shouldOpen {
    if ([self isActive] == shouldOpen) return;
    
    if (shouldOpen) {
        [self setActive:YES];
        [window setPoint:[self calcWindowOrigin]];
        [_statusView setActive:YES];
        [_statusView setNeedsDisplay:YES];
        [window setIsVisible:YES];
        [window makeKeyAndOrderFront:self];
        [NSApp activateIgnoringOtherApps:YES];
    } else {
        [_statusView setActive:NO];
        [_statusView setNeedsDisplay:YES];
        [window setIsVisible:NO];
        [self setActive:NO];
    }
}

- (NSPoint) calcWindowOrigin {
    NSRect windowFrame = [[_statusView window] frame];
    NSPoint origin = NSMakePoint(windowFrame.origin.x + (windowFrame.size.width / 2), windowFrame.origin.y);
    return origin;
}

- (void) applicationDidFinishLaunching:(NSNotification *)notification  {
    
    NSStatusBar* statusBar = [NSStatusBar systemStatusBar];
    int length = 25;
    _statusItem = [statusBar statusItemWithLength:length];
    _statusView = [[CLStatusBarView alloc] initWithFrame:(NSRect){.size={length, length}}];
    [_statusItem setView:_statusView];
    [_statusView setTarget:self];
    [_statusView setAction:@selector(statusItemClicked:)];
    
    window = [[CLPanel alloc] initWithContentSize:(CGSize){480, 355} relativeToPoint:[self calcWindowOrigin]];

    
    controller = [[CLMainController alloc] initWithWindow:window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResignKey:) name:NSWindowDidResignKeyNotification object:window];


    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [[CoreWrapper sharedInstance] loop];
    });
}
- (void) windowDidResignKey: (NSNotification*) event {
    
    if (_statusView.isActive) {
        [window setIsVisible:NO];
        [_statusView setActive:NO];
        [_statusView setNeedsDisplay:YES];
        [self setActive: NO];
    }
}

//- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
//{
//    if ([[aTableColumn identifier] isEqual:@"Name"]) {
//        [aCell setBackgroundColor: [NSColor yellowColor]];
//        [aCell setDrawsBackground:YES];
//    }
//}



@end


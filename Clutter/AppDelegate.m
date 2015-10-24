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

- (void) statusItemClicked {
    NSEvent* theEvent = [NSApp currentEvent];
    if ([theEvent modifierFlags] & NSControlKeyMask){
        NSMenu* menu = [[NSMenu alloc] initWithTitle:@"context"];
        [menu addItemWithTitle:@"Check for updates..." action:@selector(checkForUpdatesOkay) keyEquivalent:@""];
        [menu addItemWithTitle:@"Quit" action:@selector(quitIt) keyEquivalent:@""];
        
        [_statusItem popUpStatusItemMenu:menu];
    } else {
        [self togglePanel:![self isActive]];
    }
    
}
- (void) togglePanel: (BOOL) shouldOpen {
//    if ([self isActive] == shouldOpen) return;
    
    if (shouldOpen) {
        [self setActive:YES];
        [_window setPoint:[self calcWindowOrigin]];
        
        [_window reposition];
        [_statusView setActive:YES];
        [_statusView setNeedsDisplay:YES];
        [_window setIsVisible:YES];
        [_window makeKeyAndOrderFront:self];
        [NSApp activateIgnoringOtherApps:YES];
    } else {
        [_statusView setActive:NO];
        [_statusView setNeedsDisplay:YES];
        [_window setIsVisible:NO];
        [self setActive:NO];
    }
}

- (NSPoint) calcWindowOrigin {
    NSRect windowFrame = [[_statusItem valueForKey:@"window"] frame];
    NSPoint origin = NSMakePoint(windowFrame.origin.x + (windowFrame.size.width / 2), windowFrame.origin.y);
    return origin;
}

- (void) applicationDidFinishLaunching:(NSNotification *)notification  {
    
    NSStatusBar* statusBar = [NSStatusBar systemStatusBar];
    NSImage* blackIcon = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"images/icon" ofType:@"png"]];
    NSImage* altIcon = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"images/icon_alt" ofType:@"png"]];
    _statusItem = [statusBar statusItemWithLength:blackIcon.size.width + 5];
    [_statusItem.button setTarget:self];
    [_statusItem.button setAction:@selector(statusItemClicked)];
    
    [_statusItem.button setImage:blackIcon];
    [_statusItem.button setAlternateImage:altIcon];
    [[_statusItem.button cell] setImageScaling:NSImageScaleProportionallyDown];
    
//    [[_statusItem.button cell] attachPopUpWithFrame:[_statusItem.button frame] inView:_statusItem.view];
    
    _window = [[CLPanel alloc] initWithContentSize:(CGSize){480, 355} relativeToPoint:[self calcWindowOrigin]];
    
    controller = [[CLMainController alloc] initWithWindow:_window];
    
    [self watchForKeyWindowChange:YES];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [[CoreWrapper sharedInstance] loop];
    });
}
- (void) windowDidResignKey: (NSNotification*) event {
    
    if (self.isActive) {
        [_window setIsVisible:NO];
        [self setActive:NO];
    }
}

- (void) watchForKeyWindowChange: (BOOL) shouldWatch {
    if (shouldWatch) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResignKey:) name:NSWindowDidResignKeyNotification object:_window];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:_window];
    }
}
         
- (void) quitIt {
    [NSApp terminate:nil];
}
- (void) checkForUpdatesOkay {
    [[SUUpdater sharedUpdater] checkForUpdates:nil];
}

//- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
//{
//    if ([[aTableColumn identifier] isEqual:@"Name"]) {
//        [aCell setBackgroundColor: [NSColor yellowColor]];
//        [aCell setDrawsBackground:YES];
//    }
//}



@end

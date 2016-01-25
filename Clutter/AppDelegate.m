//
//  AppDelegate.m
//  Clutter
//
//  Created by Andy Locascio on 6/28/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import "AppDelegate.h"
#import "CLMainController.h"

NSString* const CLNotificationConfirmShouldChange = @"CLNotificationConfirmShouldChange";

@implementation AppDelegate

- (void) statusItemClicked: (NSNumber*) wasRightClicked {
    
    if (![wasRightClicked boolValue]) {
        [self togglePanel:![self isActive]];
    } else {
        NSMenu* menu = [[NSMenu alloc] initWithTitle:@"context"];
        [menu addItemWithTitle:@"Check for updates..." action:@selector(checkForUpdatesOkay) keyEquivalent:@""];
        [menu addItemWithTitle:@"Quit" action:@selector(quitIt) keyEquivalent:@""];
        
        [_statusItem popUpStatusItemMenu:menu];
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
        if ([[QLPreviewPanel sharedPreviewPanel] isVisible]) {
            [[QLPreviewPanel sharedPreviewPanel] orderOut:nil];
        }
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
    _statusView = [[CLStatusBarView alloc] init];

    _statusView.image = blackIcon;
    _statusView.altImage = altIcon;
    [_statusView setTarget:self];
    [_statusView setAction:@selector(statusItemClicked:)];
    [_statusItem setView:_statusView];
    
//    [_statusItem.button setTarget:self];
//    [_statusItem.button setAction:@selector(statusItemClicked)];
    

//    [_statusItem.button setImage:blackIcon];
//    [_statusItem.button setAlternateImage:altIcon];
//    [[_statusItem.button cell] setImageScaling:NSImageScaleProportionallyDown];
    
//    [[_statusItem.button cell] attachPopUpWithFrame:[_statusItem.button frame] inView:_statusItem.view];
    
    _window = [[CLPanel alloc] initWithContentSize:(CGSize){480, 480} relativeToPoint:[self calcWindowOrigin]];
    
    _controller = [[CLMainController alloc] initWithWindow:_window];
    
    self.ignoreLoseFocus = YES;
    
    system("pluginkit -e use -i com.bubble.tea.Clutter.FinderExtension");

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [[CoreWrapper sharedInstance] loop];
    });
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
//    [self setActive:YES];
}
- (void)applicationDidResignActive:(NSNotification *)notification {
    if ([[QLPreviewPanel sharedPreviewPanel] isVisible]) {
        [[QLPreviewPanel sharedPreviewPanel] orderOut:nil];
    }
//    [_window setIsVisible:NO];
    [self togglePanel:NO];
    [self setActive:NO];
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


//
//  CLMainController.m
//  Clutter
//
//  Created by Andy Locascio on 9/3/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import "CLMainController.h"
#import "CoreWrapper.h"

@interface CLMainController ()

@end

@implementation CLMainController

- (id)initWithWindow:(CLPanel *)window {
    self = [super initWithWindow:window];
    //= [super initWithWindowNibName:@"Window" owner:self];
    
    [[CoreWrapper sharedInstance] setDelegate:self];
    
    
    self.downloadView = [[CLDownloadView alloc] init];
    
//    [window.panelView addSubview:self.downloadView.view];
//    NSArray* constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[download]|" options:0 metrics:nil views:@{@"download": self.downloadView.view}];
//    [NSLayoutConstraint activateConstraints:constraints];
//    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[download]|" options:0 metrics:nil views:@{@"download": self.downloadView.view}];
//    [NSLayoutConstraint activateConstraints:constraints];

    self.expiringView = [[CLExpiringView alloc] init];
    
    [window.panelView addSubview:self.expiringView.view];

    NSDictionary* views = @{@"expiring": self.expiringView.view};
    NSMutableArray* constraints = [[NSMutableArray alloc] init];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[expiring]|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[expiring]|" options:0 metrics:nil views:views]];
    
    [NSLayoutConstraint activateConstraints:constraints];
    
    return self;
}

// ** ClutterClient methods **
- (void)newFile:(NSURL *)url {
    [self.downloadView updatePanelWithFile:url];
}

- (void) renamedFile: (NSURL*) oldPath toNewPath: (NSURL*)newPath {
    //    BOOL isPanelOpen = [(AppDelegate*)[[NSApplication sharedApplication] delegate] isActive];

    if ([oldPath isEqualTo:[self.downloadView activeFile]]) {
        [self.downloadView updatePanelWithFile:newPath];
    }
}

- (void) expirationChangedForFile:(NSURL*)url {
    [self.expiringView updateExpirationTable];
}



//- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
//    return [[CLTableRowView alloc] init];
//}

//- (void)tableViewSelectionDidChange:(NSNotification *)notification{
//    NSIndexSet * selected = [[notification object] selectedRowIndexes];
//    NSMutableArray * files = [[NSMutableArray alloc] init];
//    [selected enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop){
//        NSArray * vals = [_filesList objectAtIndex:index];
//        NSDictionary * dict = @{
//            @"url": [[[CoreWrapper sharedInstance] url] URLByAppendingPathComponent: [vals objectAtIndex:0]],
//            @"size": [vals objectAtIndex:1]
//        };
//        [files addObject:dict];
//    }];
//    
//    [_preview filesSelected:files];
//}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    
    if ([[tableColumn identifier] isEqual:@"Name"]) {
        // Get an existing cell with the MyView identifier if it exists
        NSTableCellView *result = [self->tableView makeViewWithIdentifier:@"NameView" owner:self];
        [result.textField setStringValue:[[_filesList objectAtIndex:row] objectAtIndex:0]];
        return result;
    }
    else if ([[tableColumn identifier] isEqual:@"Check"]) {
        NSTableCellView *result = [self->tableView makeViewWithIdentifier:@"CheckView" owner:self];
        return result;
    }
    else if ([[tableColumn identifier] isEqual:@"Slider"]) {
        NSTableCellView *result = [self->tableView makeViewWithIdentifier:@"SliderView" owner:self];
        return result;
    }
    
    // Return the result
    return nil;
}


@end

@implementation CLDarkScroller
- (void) drawRect: (NSRect) dirtyRect
{
    [[NSColor clearColor] setFill];
    NSRectFill(dirtyRect);
    [self drawKnob];
}

- (void)drawKnob
{
    NSRect knobRect = [self rectForPart:NSScrollerKnob];
    NSRect newRect = NSMakeRect((knobRect.size.width - 7) / 2, knobRect.origin.y, 7, knobRect.size.height);
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:newRect xRadius:3 yRadius:3];
    [[NSColor colorWithCalibratedWhite:255 alpha:.6] set];
    [path fill];
}
@end;




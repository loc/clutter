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
    
    
//    NSArray* constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[download]|" options:0 metrics:nil views:@{@"download": self.downloadView.view}];
//    [NSLayoutConstraint activateConstraints:constraints];
//    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[download]|" options:0 metrics:nil views:@{@"download": self.downloadView.view}];
//    [NSLayoutConstraint activateConstraints:constraints];

    self.expiringView = [[CLExpiringView alloc] init];
    
    [window.panelView addSubview:self.expiringView.view];
    [window.panelView addSubview:self.downloadView.view];

    NSDictionary* views = @{@"expiring": self.expiringView.view,
                            @"download": self.downloadView.view};
    
    NSMutableArray* constraints = [[NSMutableArray alloc] init];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[expiring]|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[download]|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[expiring][download(300)]|" options:0 metrics:nil views:views]];
    
    [NSLayoutConstraint activateConstraints:constraints];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowBecameKey:) name:NSWindowDidBecomeKeyNotification object:nil];
    
    _filesExpiredQueue = [[NSArray alloc] init];
    
    return self;
}

- (void) windowBecameKey: (NSNotification*) note {
    [self.expiringView updateExpirationTable];
//    [self.downloadView updatePanelWithFile:url];
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

- (void) expiredFile:(NSDictionary*)info {
    CoreWrapper* wrapper = [CoreWrapper sharedInstance];
    CLExpiringView* expirationTableView = self.expiringView;
    
    if (expirationDebounceSource != nil) {
        dispatch_source_cancel(expirationDebounceSource);
    }
    
    _filesExpiredQueue = [_filesExpiredQueue arrayByAddingObject:info];
    
    // debounce the notification so we can aggregate and say "5 files expired"
    expirationDebounceSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(expirationDebounceSource, DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(expirationDebounceSource, ^{
        NSUserNotification* notification = [[NSUserNotification alloc] init];
        NSURL* fileURL = _filesExpiredQueue[0][@"fileURL"];
        NSString* informativeText;
        
        if ([_filesExpiredQueue count] > 1) {
            [notification setTitle:[NSString stringWithFormat:@"%lu files expired", (unsigned long)[_filesExpiredQueue count]]];
            NSString* subtitle = [CoreWrapper truncFileName:[fileURL lastPathComponent] withLength:20];
            NSString* otherFilesString = [NSString stringWithFormat:@" & %lu other files", [_filesExpiredQueue count]];
            [subtitle stringByAppendingString:otherFilesString];
            __block unsigned long long bytes;
            [_filesExpiredQueue enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary* fileInfo = (NSDictionary*)obj;
                bytes += [fileInfo[@"fileSize"] unsignedLongLongValue];
            }];
            
            informativeText = [NSString stringWithFormat:@"%@ total", [NSByteCountFormatter stringFromByteCount:bytes countStyle:NSByteCountFormatterCountStyleFile]];
            [notification setActionButtonTitle: @"Restore All"];
        } else {
            NSDictionary* firstFileInfo = _filesExpiredQueue[0];
            [notification setTitle:@"A file has expired"];
            [notification setSubtitle:[fileURL lastPathComponent]];
            informativeText = [NSByteCountFormatter stringFromByteCount:[firstFileInfo[@"fileSize"] unsignedLongLongValue] countStyle:NSByteCountFormatterCountStyleFile];
            if ([firstFileInfo[@"downloadUrl"] length]) {
                informativeText = [informativeText stringByAppendingFormat:@" - %@", firstFileInfo[@"downloadUrl"]];
            }
            [notification setActionButtonTitle: @"Restore"];
        }
        
        [notification setInformativeText:informativeText];
        [notification setOtherButtonTitle: @"Okay"];
        [notification setHasActionButton: YES];
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        
        [expirationTableView updateExpirationTable];
        
        dispatch_source_cancel(expirationDebounceSource);
    });
    dispatch_resume(expirationDebounceSource);
    
    NSURL* url = info[@"fileURL"];
    NSURL* archiveDirectory = [[wrapper supportURL] URLByAppendingPathComponent:@"Archives" isDirectory:YES];
    [[NSFileManager defaultManager] createDirectoryAtPath:[archiveDirectory path] withIntermediateDirectories:YES attributes:nil error:nil];
    NSString* fileName = [url lastPathComponent];
    
    if ([[NSFileManager defaultManager] isReadableFileAtPath:[url path]]) {
        NSString* uniqueFileName = [fileName stringByAppendingFormat:@"%@", info[@"inode"]];
        NSURL* newURL = [archiveDirectory URLByAppendingPathComponent:uniqueFileName];
        NSError* error;
        [[NSFileManager defaultManager] moveItemAtURL:url toURL:newURL error:&error];
    }
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




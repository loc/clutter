//
//  CLMainController.m
//  Clutter
//
//  Created by Andy Locascio on 9/3/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import "CLMainController.h"
#import "CoreWrapper.h"

NSString* const CLViewModeUnsorted = @"Unsorted";
NSString* const CLViewModeFresh = @"Fresh";
NSString* const CLViewModeExpired = @"Expired";
NSString* const CLViewModeAll = @"[All Modes]";
NSString* const CLNotificationViewModeChanged = @"CLNotificationViewModeChanged";
NSString* const CLNotificationConfirmClicked = @"CLNotificationConfirmClicked";

@interface CLMainController ()

@end

@implementation CLMainController

- (id)initWithWindow:(CLPanel *)window {
    self = [super initWithWindow:window];
    //= [super initWithWindowNibName:@"Window" owner:self];
    
    [[CoreWrapper sharedInstance] setDelegate:self];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    self.downloadView = [[CLDownloadView alloc] init];
    
    _viewModeControl = [[CLSegmentedControl alloc] init];
    [_viewModeControl setTarget:self];
    [_viewModeControl setAction:@selector(viewModeControlClicked:)];
    [_viewModeControl setLabels:@[CLViewModeUnsorted, CLViewModeFresh, CLViewModeExpired]];
    
    
    // [NSColor clRGBA(165,165,165, .8)]
    // [NSColor clRGB(65,65,65)]
    [(CLSegmentedCell*)_viewModeControl.cell setHighlightColor:[NSColor clRGBA(235,235,235, .45)]];
    [(CLSegmentedCell*)_viewModeControl.cell setHighlightTextColor:[NSColor clBlue]];
    [(CLSegmentedCell*)_viewModeControl.cell setHighlightStrokeColor:[NSColor clBlue]];
    [(CLSegmentedCell*)_viewModeControl.cell setDeselectedColor:[NSColor clRGBA(215,215,215, .65)]];
    [(CLSegmentedCell*)_viewModeControl.cell setDeselectedTextColor:[NSColor clRGBA(55,55,60, .3)]];
    [(CLSegmentedCell*)_viewModeControl.cell setShouldBoldHighlight:YES];
    
    NSView* bgView = [[NSView alloc] init];
    [bgView setWantsLayer:YES];
    [bgView.layer setBackgroundColor:[NSColor clRGB(196, 199, 204)].CGColor];
    
    
//    NSArray* constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[download]|" options:0 metrics:nil views:@{@"download": self.downloadView.view}];
//    [NSLayoutConstraint activateConstraints:constraints];
//    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[download]|" options:0 metrics:nil views:@{@"download": self.downloadView.view}];
//    [NSLayoutConstraint activateConstraints:constraints];

    self.expiringView = [[CLExpiringView alloc] init];
    
    NSButton* settingsButton = [[NSButton alloc] init];
    settingsButton.image = [NSImage imageNamed:NSImageNameActionTemplate];
    settingsButton.bordered = NO;
    [settingsButton setButtonType:NSMomentaryChangeButton];
    [[settingsButton cell] setImageScaling:NSImageScaleProportionallyUpOrDown];

    
    [window.panelView addSubview:bgView];
    [window.panelView addSubview:self.expiringView.view];
    [window.panelView addSubview:self.downloadView.view];
    [window.panelView addSubview:self.viewModeControl];
//    [window.panelView addSubview:settingsButton];
    
    [self.viewModeControl setTranslatesAutoresizingMaskIntoConstraints:NO];
    [bgView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [settingsButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSDictionary* views = @{@"expiring": self.expiringView.view,
                            @"download": self.downloadView.view,
                            @"viewMode": self.viewModeControl,
//                            @"settings": settingsButton,
                            @"background": bgView};
    
    NSMutableArray* constraints = [[NSMutableArray alloc] init];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[viewMode(280)]" options:0 metrics:nil views:views]];
//    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[settings(16)]-15-|" options:0 metrics:nil views:views]];
//    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[settings(16)]" options:0 metrics:nil views:views]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.viewModeControl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:window.panelView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[background]|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[background]" options:0 metrics:nil views:views]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[expiring]|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[download]|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[viewMode(25)]-15-[expiring][download(300)]|" options:0 metrics:nil views:views]];
    
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:bgView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.expiringView.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
    [NSLayoutConstraint activateConstraints:constraints];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowBecameKey:) name:NSWindowDidBecomeMainNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:CLNotificationConfirmClicked object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        if ([(AppDelegate*)[NSApp delegate] shouldSustainOnConfirm]) {
            [self.expiringView updateExpirationTableForMode:CLViewModeAll];
        } else {
            [(AppDelegate*)[NSApp delegate] togglePanel:NO];
        }
    }];
    
    _filesExpiredQueue = [[NSArray alloc] init];
    
    [self setViewMode:CLViewModeUnsorted];
    
    return self;
}

- (void) windowBecameKey: (NSNotification*) note {
    [self.expiringView updateExpirationTableForMode:CLViewModeAll];
//    [self.downloadView updatePanelWithFile:url];
}

// ** ClutterClient methods **
- (void)newFile:(CLFile *)file {
    [self setViewMode:CLViewModeUnsorted];
    [self.downloadView updatePanelWithFile:file];
}

- (void) renamedFile: (CLFile*) file {
    //    BOOL isPanelOpen = [(AppDelegate*)[[NSApplication sharedApplication] delegate] isActive];

    if ([file.previousURL isEqualTo:self.downloadView.activeFile.url]) {
        [self.downloadView updatePanelWithFile:file];
    }
}

- (void) expirationChangedForFile:(CLFile*)file {
    [self.expiringView updateExpirationTableForMode:CLViewModeFresh];
}

- (void) setViewMode:(NSString *)viewMode {
    NSString* old = _viewMode;
    _viewMode = viewMode;
    
    [_viewModeControl setSelectedSegment:[_viewModeControl.labels indexOfObject:viewMode]];
    
    if (![viewMode isEqualToString: old]) {
        // notify others in the application (expiration table for example) that this has changed!
        [[NSNotificationCenter defaultCenter] postNotificationName:CLNotificationViewModeChanged object:_viewMode];
    }
}

- (void) viewModeControlClicked: (id) sender {
    long clickedSegment = [sender selectedSegment];
    NSString* label = [self.viewModeControl labelForSegment:clickedSegment];
    
    self.downloadView.preview.name.editable = YES;
    
    NSTableColumn* lastColumn = self.expiringView.expirationTable.tableView.tableColumns.lastObject;
    if (label == CLViewModeUnsorted) {
        [lastColumn.headerCell setStringValue:@"Last Modified"];
    } else if (label == CLViewModeFresh) {
        [lastColumn.headerCell setStringValue:@"Time Left"];
    } else if (label == CLViewModeExpired) {
        [lastColumn.headerCell setStringValue:@"Time Expired"];
        self.downloadView.preview.name.editable = NO;
    }
    
    [self setViewMode:label];
}

- (void) expiredFile:(CLFile*) file {
    CoreWrapper* wrapper = [CoreWrapper sharedInstance];
    CLExpiringView* expirationTableView = self.expiringView;
    
    if (expirationDebounceSource != nil) {
        dispatch_source_cancel(expirationDebounceSource);
    }
    
    _filesExpiredQueue = [_filesExpiredQueue arrayByAddingObject:file];
    
    // debounce the notification so we can aggregate and say "5 files expired"
    expirationDebounceSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(expirationDebounceSource, DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(expirationDebounceSource, ^{
        NSUserNotification* notification = [[NSUserNotification alloc] init];
        CLFile* firstFile = _filesExpiredQueue[0];
        NSString* informativeText;
        
        if ([_filesExpiredQueue count] > 1) {
            [notification setTitle:[NSString stringWithFormat:@"%lu files expired", (unsigned long)[_filesExpiredQueue count]]];
            NSString* subtitle = [firstFile truncName:20];
            NSString* otherFilesString = [NSString stringWithFormat:@" & %lu other files", [_filesExpiredQueue count]];
            [subtitle stringByAppendingString:otherFilesString];
            __block unsigned long long bytes;
            [_filesExpiredQueue enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CLFile* aFile = (CLFile*)obj;
                bytes += aFile.size;
            }];
            
            
            informativeText = [NSString stringWithFormat:@"%@ total", [NSByteCountFormatter stringFromByteCount:bytes countStyle:NSByteCountFormatterCountStyleFile]];
            [notification setActionButtonTitle: @"Restore All"];
        } else {
            [notification setTitle:@"A file has expired"];
            [notification setSubtitle: firstFile.name];
            informativeText = [NSByteCountFormatter stringFromByteCount:firstFile.size countStyle:NSByteCountFormatterCountStyleFile];
            if ([firstFile.downloadURL length]) {
                informativeText = [informativeText stringByAppendingFormat:@" - %@", firstFile.downloadURL];
            }
            [notification setActionButtonTitle: @"Restore"];
        }
        
        [notification.userInfo setValue:_filesExpiredQueue forKey:@"files"];
        
        [notification setInformativeText:informativeText];
        [notification setOtherButtonTitle: @"Okay"];
        [notification setHasActionButton: YES];
        
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        
        [expirationTableView updateExpirationTableForMode:CLViewModeAll];
        
        dispatch_source_cancel(expirationDebounceSource);
    });
    dispatch_resume(expirationDebounceSource);
    
//    NSURL* archiveDirectory = [[wrapper supportURL] URLByAppendingPathComponent:@"Archives" isDirectory:YES];
//    [[NSFileManager defaultManager] createDirectoryAtPath:[archiveDirectory path] withIntermediateDirectories:YES attributes:nil error:nil];
//    
//    if ([[NSFileManager defaultManager] isReadableFileAtPath:[file.url path]]) {
//        NSURL* newURL = [archiveDirectory URLByAppendingPathComponent:file.archiveName];
//        NSError* error;
//        [[NSFileManager defaultManager] moveItemAtURL:file.url toURL:newURL error:&error];
//    }
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

// user clicked Restore or Restore All on the notification
- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    AppDelegate* delegate = [NSApp delegate];
    
    if (notification.activationType == NSUserNotificationActivationTypeActionButtonClicked) {
        NSArray* files = notification.userInfo[@"files"];
        [files enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CLFile* file = (CLFile*)obj;
            
            [[CoreWrapper sharedInstance] extendFile:file forDays:-1 withName:file.name];
            [delegate togglePanel:YES];
            [self setViewMode:CLViewModeUnsorted];
        }];
    } else if (notification.activationType == NSUserNotificationActivationTypeContentsClicked) {
        [delegate togglePanel:YES];
        [self setViewMode:CLViewModeExpired];
    }
    
}

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




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

    [[CoreWrapper sharedInstance] runBlockOnChange:^{
        //[listController setList:[wrapper listFiles]];
//        [self updateTable:[[CoreWrapper sharedInstance] listFiles]];
    }];
    
    NSUInteger previewHeight = 150, actionHeight = 75, confirmHeight = 55;
    NSRect windowFrame = [self.window frame];
    NSSize windowSize = {480, previewHeight + actionHeight * 2 + confirmHeight};
    windowFrame.size = windowSize;
    
    [self updateTable:[[CoreWrapper sharedInstance] listFiles]];
    
    [self->tabSwitcher setTarget:self];
    [self->tabSwitcher setAction:@selector(tabSwitched)];
    
    _preview = [[CLPreviewController alloc] init];
    _moveActionView = [[CLFileActionView alloc] initWithFrame:NSMakeRect(0, previewHeight, windowSize.width, actionHeight) andTitle:@"Move:"];
    [_moveActionView setDelegate:self];
    [_moveActionView setBackgroundColor:[NSColor clRGB(223,225,228)]];
    [_moveActionView setHasFolderPicker:YES];
    
    _keepActionView = [[CLFileActionView alloc] initWithFrame:NSMakeRect(0, previewHeight + actionHeight, windowSize.width, actionHeight) andTitle:@"Keep:"];
    [_keepActionView setDelegate:self];
    [_keepActionView setBackgroundColor:[NSColor clRGB(242,242,243)]];
    
    NSArray* folderUrls = [self getDefaultFolders];
    NSMutableArray* folderNames = [[NSMutableArray alloc] initWithCapacity:[folderUrls count]];
    [folderUrls enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [folderNames addObject:[(NSURL*) obj lastPathComponent]];
    }];
    
    [_moveActionView setLabels:folderNames andValues:folderUrls];
    [_keepActionView setLabels:@[@"1 day", @"2 weeks", @"1 month", @"Forever"] andValues:@[@1, @14, @30, [NSNull null]]];
    
    [_preview.view setFrameSize:CGSizeMake(windowSize.width, previewHeight)];
    [_preview.view setFrameOrigin:CGPointMake(0, 0)];
    
    _confirmActionView = [[CLActionConfirmView alloc] initWithFrame:NSMakeRect(0, previewHeight + actionHeight * 2, windowSize.width, confirmHeight)];
    [_confirmActionView setTarget:self];
    [_confirmActionView setAction:@selector(confirmed)];
    
    [window.panelView addSubview:_preview.view];
    [window.panelView addSubview:_moveActionView];
    [window.panelView addSubview:_keepActionView];
    [window.panelView addSubview:_confirmActionView];
    
//    NSArray * vals = [_filesList objectAtIndex:50];
    
    return self;
}

- (void) confirmed {
    if (self.activeFile == nil) {
        [_moveActionView clearSelection];
        [_keepActionView clearSelection];
    }
    else {
        // TODO: better validation?
        NSString* newName = [_preview.name.stringValue stringByReplacingOccurrencesOfString:@"/" withString:@""];
        
        if ([_moveActionView isSelected]) {
            NSURL* folder = [_moveActionView getSelectedValue];
            [[CoreWrapper sharedInstance] moveFile:[self activeFile] toFolder:folder withName:newName];
        } else if ([_keepActionView isSelected]) {
            NSNumber* days = [_keepActionView getSelectedValue];
            [[CoreWrapper sharedInstance] keepFile:[self activeFile] forDays:[days unsignedIntegerValue] withName:newName];
//            NSLog(@"days: %@", days);
        }
        [self setActiveFile:nil];
    }
    
    [(AppDelegate*)[NSApp delegate] togglePanel:NO];
}

- (NSArray*) getRelevantFoldersForFile:(NSString*) fileName {
    return [self getDefaultFolders];
}

- (NSArray*) getDefaultFolders {
    NSFileManager* manager = [NSFileManager defaultManager];
    NSInteger directories[] = {NSDocumentDirectory, NSPicturesDirectory, NSDesktopDirectory, NSMusicDirectory};
    NSArray * managerUrls;
    NSMutableArray * folders = [[NSMutableArray alloc] init];

    for (int i=0; i < 4; i++) {
        managerUrls = [manager URLsForDirectory:directories[i] inDomains:NSUserDomainMask];
        [folders addObject:[managerUrls firstObject]];
    }
    
    return folders;
}

- (void) moveTargetChanged {
    NSLog(@"move switched outside");
}

- (void) keepTargetChanged {
    NSLog(@"keep switched outside");
}

// file action methods
- (void)actionChanged:(NSString *)label from:(id)sender {
    if (!label) {
        [_confirmActionView enableButton:NO];
        return;
    }
    if (sender == _moveActionView) {
        [_keepActionView clearSelection];
    } else {
        [_moveActionView clearSelection];
        // _keepActionView
    }
    [_confirmActionView enableButton:YES];
}
- (void) folderPicked:(NSURL *)folder from:(id)sender {
    
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _filesList.count;
}

-(void)updateTable:(NSArray*)data {
    _filesList = data;
    [self->tableView reloadData];
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    return [[CLTableRowView alloc] init];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSIndexSet * selected = [[notification object] selectedRowIndexes];
    NSMutableArray * files = [[NSMutableArray alloc] init];
    [selected enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop){
        NSArray * vals = [_filesList objectAtIndex:index];
        NSDictionary * dict = @{
            @"url": [[[CoreWrapper sharedInstance] url] URLByAppendingPathComponent: [vals objectAtIndex:0]],
            @"size": [vals objectAtIndex:1]
        };
        [files addObject:dict];
    }];
    
    [_preview filesSelected:files];
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

- (void) tabSwitched {
    NSLog(@"switch");
}


// ** ClutterClient methods **
- (void)newFile:(NSURL *)url {
    [self updatePanelWithFile:url];
}

- (void) renamedFile: (NSURL*) oldPath toNewPath: (NSURL*)newPath {
//    BOOL isPanelOpen = [(AppDelegate*)[[NSApplication sharedApplication] delegate] isActive];
    
    if ([oldPath isEqualTo:[self activeFile]]) {
        [self updatePanelWithFile:newPath];
    }
}

- (void) updatePanelWithFile: (NSURL*) path {
    NSDictionary * dict = @{
                            @"url": path,
                            @"size": @1
                            };
    [_preview filesSelected: [NSArray arrayWithObject:dict]];
    [self setActiveFile:path];
    [(AppDelegate*)[[NSApplication sharedApplication] delegate] togglePanel:YES];
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




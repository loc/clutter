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

- (id)init {
    self = [super initWithWindowNibName:@"Window" owner:self];

    [[CoreWrapper sharedInstance] runBlockOnChange:^{
        //[listController setList:[wrapper listFiles]];
        [self updateTable:[[CoreWrapper sharedInstance] listFiles]];
    }];
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [[self window] setBackgroundColor:[NSColor clBackground]];
    
    [self updateTable:[[CoreWrapper sharedInstance] listFiles]];
    
    [self->tabSwitcher setTarget:self];
    [self->tabSwitcher setAction:@selector(tabSwitched)];
    
    NSUInteger previewHeight = 150, actionHeight = 75, confirmHeight = 55;
    CGFloat titleBarHeight = self.window.frame.size.height - ((NSView*)self.window.contentView).frame.size.height;
    NSRect windowFrame = self.window.frame;
    windowFrame.size = NSMakeSize(windowFrame.size.width, previewHeight + actionHeight * 2 + confirmHeight + titleBarHeight);
    NSSize windowSize = windowFrame.size;
    [self.window setFrame:windowFrame display:YES];
    
    _preview = [[CLPreviewController alloc] init];
    _moveActionView = [[CLFileActionView alloc] initWithFrame:NSMakeRect(0, previewHeight, windowSize.width, actionHeight) andTitle:@"Move:"];
    [_moveActionView setDelegate:self];
    [_moveActionView setBackgroundColor:[NSColor clRGB(223,225,228)]];
    [_moveActionView setHasFolderPicker:YES];
    
    _keepActionView = [[CLFileActionView alloc] initWithFrame:NSMakeRect(0, previewHeight + actionHeight, windowSize.width, actionHeight) andTitle:@"Keep:"];
    [_keepActionView setDelegate:self];
    [_keepActionView setBackgroundColor:[NSColor clRGB(242,242,243)]];
    
    [_moveActionView setLabels:@[@"Documents", @"PDFs", @"Desktop", @"Pictures"]];
    [_keepActionView setLabels:@[@"1 day", @"2 weeks", @"1 month", @"Forever"]];
    
    [_preview.view setFrameSize:CGSizeMake(windowSize.width, previewHeight)];
    [_preview.view setFrameOrigin:CGPointMake(0, 0)];
    
    _confirmActionView = [[CLActionConfirmView alloc] initWithFrame:NSMakeRect(0, previewHeight + actionHeight * 2, windowSize.width, confirmHeight)];
    
    [self.window.contentView addSubview:_preview.view];
    [self.window.contentView addSubview:_moveActionView];
    [self.window.contentView addSubview:_keepActionView];
    [self.window.contentView addSubview:_confirmActionView];
    
    
    NSArray * vals = [_filesList objectAtIndex:52];
    NSDictionary * dict = @{
                            @"url": [[[CoreWrapper sharedInstance] url] URLByAppendingPathComponent: [vals objectAtIndex:0]],
                            @"size": [vals objectAtIndex:1]
                            };
    [_preview filesSelected: [NSArray arrayWithObject:dict]];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void) moveTargetChanged {
    NSLog(@"move switched outside");
}

- (void) keepTargetChanged {
    NSLog(@"keep switched outside");
}

// file action methods
- (void)actionChanged:(NSString *)label from:(id)sender {
    if (!label) return;
    if (sender == _moveActionView) {
        [_keepActionView clearSelection];
    } else {
        [_moveActionView clearSelection];
        // _keepActionView
    }
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


@implementation CLMainView

- (void) mouseDown:(NSEvent *)theEvent {
    [[self window] makeFirstResponder:nil];
}
- (BOOL)isFlipped {
    return YES;
}

@end

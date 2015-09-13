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
        NSLog(@"something happened");
        //[listController setList:[wrapper listFiles]];
        [self updateTable:[[CoreWrapper sharedInstance] listFiles]];
    }];

    _preview = [[CLPreviewController alloc] init];
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [[self window] setBackgroundColor:[NSColor clBackground]];
    NSLog(@"hello world");
    
    [self updateTable:[[CoreWrapper sharedInstance] listFiles]];
    
    [self->tabSwitcher setTarget:self];
    [self->tabSwitcher setAction:@selector(tabSwitched)];
    
    [[[self window] contentView] addSubview:_preview.view];
    NSSize windowSize = ([[[self window] contentView] bounds]).size;
    NSPoint topLeft = CGPointMake(0, 50);
    [_preview.view setFrameOrigin:topLeft];
    [_preview.view setFrameSize:CGSizeMake(windowSize.width, 150)];
    [_preview.view setAutoresizingMask:NSViewMaxYMargin];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
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


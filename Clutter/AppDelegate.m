//
//  AppDelegate.m
//  Clutter
//
//  Created by Andy Locascio on 6/28/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void) awakeFromNib {

}
- (void) applicationDidFinishLaunching:(NSNotification *)notification  {
    [_window setBackgroundColor:[NSColor clBackground]];
    
    _wrapper = [[CoreWrapper alloc] initWithCallback:^{
        NSLog(@"something happened");
        //[listController setList:[wrapper listFiles]];
        [self updateTable:[_wrapper listFiles]];
    }];
    
    [self updateTable:[_wrapper listFiles]];
    NSLog(@"hello");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [_wrapper loop];
    });
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _list.count;
}

-(void)updateTable:(NSArray*)data {
    _list = data;
    [self->tableView reloadData];
}

//- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
//{
//    if ([[aTableColumn identifier] isEqual:@"Name"]) {
//        [aCell setBackgroundColor: [NSColor yellowColor]];
//        [aCell setDrawsBackground:YES];
//    }
//}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    return [[CLTableRowView alloc] init];
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    
    if ([[tableColumn identifier] isEqual:@"Name"]) {
        // Get an existing cell with the MyView identifier if it exists
        NSTableCellView *result = [self->tableView makeViewWithIdentifier:@"NameView" owner:self];
        [result.textField setStringValue:[[_list objectAtIndex:row] objectAtIndex:0]];
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

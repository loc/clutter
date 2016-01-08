//
//  CLExpiringView.m
//  Clutter
//
//  Created by Andy Locascio on 11/10/15.
//  Copyright © 2015 Bubble Tea Apps. All rights reserved.
//

#import "CLExpiringView.h"
#import "CLGenericFlippedView.h"
#import "CoreWrapper.h"
#import "CLTableView.h"

@interface CLExpiringView ()

@end

@implementation CLExpiringView

- (void)loadView {
    self.view = [[CLGenericFlippedView alloc] init];
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    NSMutableArray* topLevelObjs = [[NSMutableArray alloc] init];
    BOOL success = [[NSBundle mainBundle] loadNibNamed:@"CLTableView" owner:self topLevelObjects:&topLevelObjs];
    
    NSInteger tableIndex = [topLevelObjs indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj isKindOfClass:[CLTableContainerView class]];
    }];
    
    self.expirationTable = topLevelObjs[tableIndex];
    [self.expirationTable.tableView setDataSource:self];
    [self.expirationTable.tableView setDelegate:self];
    
    for (NSTableColumn *column in [self.expirationTable.tableView tableColumns]) {
        [column setHeaderCell: [[CLTableHeaderCell alloc] initTextCell:[[column headerCell] stringValue]]];
    }
    
    [self.view addSubview:self.expirationTable];
    
    [self.expirationTable setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self updateExpirationTable];
    
    NSDictionary* views = @{@"table": self.expirationTable};
    NSMutableArray* constraints = [[NSMutableArray alloc] init];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[table]-10-|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[table]-15-|" options:0 metrics:nil views:views]];
    
    [NSLayoutConstraint activateConstraints:constraints];
//    [self.expirationTable regist]
}

- (void) updateExpirationTable {
    NSSortDescriptor* dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"expiration" ascending:YES];
    NSPredicate* noNulls = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ![[evaluatedObject objectForKey:@"expiration"] isEqualTo:[NSNull null]];
    }];
    _files = [[[[CoreWrapper sharedInstance] listFiles] filteredArrayUsingPredicate:noNulls] sortedArrayUsingDescriptors:@[dateDescriptor]];
    
    [self.expirationTable.tableView reloadData];
    NSNotification* note = [NSNotification notificationWithName:@"fakeSelection" object:nil];
    [self tableViewSelectionDidChange:note];
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger row = [self.expirationTable.tableView selectedRow];
    if (row < 0) return;
    
    NSString* fileName = _files[row][@"name"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"activeFileChanged" object:fileName];
    
    NSLog(@"%@", fileName);
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    CLTableRowView* rowView = [tableView makeViewWithIdentifier:@"RowView" owner:self];
    if (!rowView) {
        rowView = [[CLTableRowView alloc] initWithFrame:NSZeroRect];
        
        rowView.identifier = @"RowView";
    }
    return rowView;
}

- (id)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView* view = [tableView makeViewWithIdentifier:@"CLID" owner:self];
    
//    if (view == nil) {
//        view = [[NSTableCellView alloc] initWithFrame:NSMakeRect(0, 0, 100, 10)];
//        view.identifier = @"CLID";
//        
//        [view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
//    }
    
    if ([@"Name" isEqualToString:tableColumn.identifier]) {
        view.textField.stringValue = [CoreWrapper truncFileName:_files[row][@"name"] withLength:25];
        [view.textField setToolTip:_files[row][@"name"]];
    }
    else if ([@"Size" isEqualToString:tableColumn.identifier]) {
        NSNumber* size = _files[row][@"fileSize"];
        view.textField.stringValue = [NSByteCountFormatter stringFromByteCount:[size unsignedLongLongValue] countStyle:NSByteCountFormatterCountStyleFile];
    }
    else if ([@"Time Left" isEqualToString:tableColumn.identifier]) {
        if (_files[row][@"expiration"] != (id)[NSNull null]) {
            view.textField.stringValue = [CoreWrapper timeLeftWords:_files[row][@"expiration"]];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [view.textField setToolTip:[dateFormat stringFromDate: _files[row][@"expiration"]]];
        }
    }
    
//    if ([[tableView selectedRowIndexes] containsIndex:row]) {
//    [view.textField setBackgroundColor:[NSColor blueColor]];
//    [view setBackgroundStyle:NSBackgroundStyleLight];
//    }
    
    return view;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_files count];
}

@end

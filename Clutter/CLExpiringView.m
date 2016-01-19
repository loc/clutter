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
#import "CLMainController.h"

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
    
    _filesForMode = [[NSMutableDictionary alloc] init];
    
    NSDictionary* views = @{@"table": self.expirationTable};
    NSMutableArray* constraints = [[NSMutableArray alloc] init];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[table]-10-|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[table]-15-|" options:0 metrics:nil views:views]];
    
    [NSLayoutConstraint activateConstraints:constraints];
//    [self.expirationTable regist]
    
    [[NSNotificationCenter defaultCenter] addObserverForName:CLNotificationViewModeChanged object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        _tableMode = [note object];
        [self updateExpirationTableForMode:nil];
    }];
}

- (void) updateExpirationTableForMode:(NSString *)mode {
    NSSortDescriptor* sortDescriptor;
    
    // if mode is nil, we just want to reload the table
    if (mode != nil) {
        NSPredicate* noNulls = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return ((CLFile*)evaluatedObject).expiration != nil;
        }];
        NSPredicate* onlyNulls = [NSCompoundPredicate notPredicateWithSubpredicate:noNulls];
        NSArray* unfilteredFiles = [[CoreWrapper sharedInstance] listFiles];
        
        
        if ([mode isEqualToString:CLViewModeUnsorted] || [mode isEqualToString: CLViewModeAll]) {
            [_filesForMode setObject:[unfilteredFiles filteredArrayUsingPredicate: onlyNulls] forKey:CLViewModeUnsorted];
        }
        if ([mode isEqualToString:CLViewModeFresh] || [mode isEqualToString: CLViewModeAll]) {
            [_filesForMode setObject:[unfilteredFiles filteredArrayUsingPredicate:noNulls] forKey:CLViewModeFresh];
        }
        if ([mode isEqualToString:CLViewModeExpired] || [mode isEqualToString: CLViewModeAll]) {
            NSArray* expiredFiles = [[CoreWrapper sharedInstance] listArchives];
            [_filesForMode setObject:expiredFiles forKey:CLViewModeExpired];
        }
    }
    
    if (self.tableMode == CLViewModeUnsorted) {
        sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastModified" ascending:NO];
    } else if (self.tableMode == CLViewModeFresh) {
        sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"expiration" ascending:YES];
    } else if (self.tableMode == CLViewModeExpired) {
        sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"expiration" ascending:NO];
    }
    
    _files = [[_filesForMode objectForKey:self.tableMode] sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    [self.expirationTable.tableView reloadData];
    NSNotification* note = [NSNotification notificationWithName:@"fakeSelection" object:nil];
    [self tableViewSelectionDidChange:note];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger row = [self.expirationTable.tableView selectedRow];
    if (row < 0) return;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"activeFileChanged" object:_files[row]];
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
    
    CLFile* currentFile = _files[row];
    
    if ([@"Name" isEqualToString:tableColumn.identifier]) {
        view.textField.stringValue = [currentFile truncName:25];
        [view.textField setToolTip:currentFile.name];
    }
    else if ([@"Size" isEqualToString:tableColumn.identifier]) {
        NSNumber* size = [NSNumber numberWithUnsignedLongLong: currentFile.size];
        view.textField.stringValue = [NSByteCountFormatter stringFromByteCount:[size unsignedLongLongValue] countStyle:NSByteCountFormatterCountStyleFile];
    }
    else if ([@"Time Left" isEqualToString:tableColumn.headerCell.stringValue]) {
        if (currentFile.expiration != nil) {
            view.textField.stringValue = [CoreWrapper timeLeftWords:currentFile.expiration];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [view.textField setToolTip:[dateFormat stringFromDate: currentFile.expiration]];
        }
    } else if ([@"Last Modified" isEqualToString:tableColumn.headerCell.stringValue]) {
        
        view.textField.stringValue = [CoreWrapper timeSinceDaysWords:currentFile.lastModified ];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [view.textField setToolTip:[dateFormat stringFromDate: currentFile.lastModified]];
    } else if ([@"Time Expired" isEqualToString:tableColumn.headerCell.stringValue]) {
        
        view.textField.stringValue = [CoreWrapper timeSinceDaysWords:currentFile.expiration ];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [view.textField setToolTip:[dateFormat stringFromDate: currentFile.lastModified]];
    }
    
    return view;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_files count];
}

@end

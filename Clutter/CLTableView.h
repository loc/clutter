//
//  CLTableView.h
//  Clutter
//
//  Created by Andy Locascio on 11/13/15.
//  Copyright © 2015 Bubble Tea Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CLTableView : NSTableView

@end

@interface CLTableContainerView : NSView

@property (strong) IBOutlet CLTableView* tableView;

@end

@interface CLTableCellView : NSTableCellView

@end

@interface CLTableHeaderView : NSTableHeaderView

@end

@interface CLTableHeaderCell : NSTableHeaderCell

@end

@interface CLTableRowView : NSTableRowView

@end
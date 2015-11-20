//
//  CLExpiringView.h
//  Clutter
//
//  Created by Andy Locascio on 11/10/15.
//  Copyright © 2015 Bubble Tea Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CLTableView.h"

@interface CLExpiringView : NSViewController <NSTableViewDelegate, NSTableViewDataSource>

@property (strong) IBOutlet CLTableContainerView* expirationTable;
@property (strong) NSArray* files;
//@property (strong) IBOutlet CLTableView* tableView;

- (void) updateExpirationTable;

@end

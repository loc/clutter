//
//  CLExpiringView.h
//  Clutter
//
//  Created by Andy Locascio on 11/10/15.
//  Copyright © 2015 Bubble Tea Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CLTableView.h"

@class CLMainController;

@interface CLExpiringView : NSViewController <NSTableViewDelegate, NSTableViewDataSource>

@property (assign) CLMainController* controller;
@property (strong) IBOutlet CLTableContainerView* expirationTable;
@property (strong) NSMutableDictionary* filesForMode;
@property (strong) NSArray* files;
@property (strong) NSString* tableMode;
//@property (strong) IBOutlet CLTableView* tableView;

- (void) updateExpirationTableForMode:(NSString*) mode;

@end

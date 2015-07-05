//
//  AppDelegate.h
//  Clutter
//
//  Created by Andy Locascio on 6/28/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CoreWrapper.h"
#import "CLTableRowView.h"
#import "CLResizeView.h"
#import "constants.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate> {
    IBOutlet NSTableView * tableView;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet CLResizeView* snaggie;
@property CoreWrapper * wrapper;
@property NSArray * list;

@end

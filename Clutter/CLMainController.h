//
//  CLMainController.h
//  Clutter
//
//  Created by Andy Locascio on 9/3/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"
#import "CLTableRowView.h"
#import "CLResizeView.h"
#import "CLPreviewController.h"
#import "CLFileActionView.h"
#import "CLActionConfirmView.h"
#import "CLPanel.h"
#import "CoreWrapper.h"


@interface CLMainController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, CLFileActionDelegate, ClutterClient> {
    IBOutlet NSSegmentedControl * tabSwitcher;
    IBOutlet NSTableView * tableView;
}

@property (assign) IBOutlet CLResizeView* snaggie;
@property NSArray * filesList;
//@property (nonatomic, retain) NSView* contentView;
@property (nonatomic, retain) IBOutlet CLPreviewController *preview;
@property (nonatomic, retain) CLFileActionView* moveActionView;
@property (nonatomic, retain) CLFileActionView* keepActionView;
@property (nonatomic, retain) CLActionConfirmView* confirmActionView;
@property (nonatomic, retain) NSURL* activeFile;

- (id)initWithWindow:(CLPanel *)window;

@end

@interface CLDarkScroller : NSScroller
@end